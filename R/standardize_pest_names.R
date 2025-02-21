#' Standardize Pest Names
#'
#' This function uses pestr to standardize pest names and retrieve hosts, 
#' and scrapes taxonomic data from the EPPO website
#' 
#' @return tibble of aggregated crop data with preferred pest name, EPPO code, hosts, and taxonomy
#' 
#' @import pestr
#' @import dplyr
#' @importFrom withr with_dir
#'
#' @examples
#'
#' @param eppo_index_processed
#' @param ippc_table_processed
#' @param nappo_table_processed
#' 
#' @export
standardize_pest_names <- function(database_directory, 
                                   eppo_index_processed, ippc_table_processed, 
                                   nappo_table_processed, eppo_database_downloaded, 
                                   crop_disease_names_manual, 
                                   duplicate_crop_disease_names_to_remove, 
                                   eppo_token = Sys.getenv("EPPO_TOKEN")) {
  
  # this pipeline uses the pestr package to standardize the disease names in our database
  # pestr uses a database from EPPO of pest names and codes
  # the package handles executing join queries in the database to get disease preferred names and EPPO codes
  # it has the added feature of fuzzy matching when looking up pest names, which can help for manual standardization

  # aggregate data from EPPO, IPPC, and NAPPO
  crop_data_aggregated <- dplyr::bind_rows(eppo_index_processed, ippc_table_processed, nappo_table_processed) |>
    dplyr::select(-c(cites_nappo, eppo_code, kingdom, phylum, class, order, family, genus, species))
  
  crop_data_aggregated <- crop_data_aggregated |>
    dplyr::mutate(pest = ifelse(pest == "", NA, pest))
  
  crop_data_aggregated <- crop_data_aggregated |>
    dplyr::mutate(pest = stringr::str_replace_all(pest, pattern = "f\\.sp\\.", replacement = "f. sp."))
  
  # change Liberibacter spp. and Phytoplasma spp. names
  crop_data_aggregated <- crop_data_aggregated |>
    dplyr::mutate(pest = stringr::str_replace_all(pest, pattern = "Candidatus\\sLiberibacter", replacement = "Liberibacter")) |>
    dplyr::mutate(pest = stringr::str_replace_all(pest, pattern = "Candidatus\\sPhytoplasma", replacement = "Phytoplasma"))
  
  # first standardize names with manual lookup table, this allows a lot of our disease names to match with the database
  crop_disease_names_manual <- read.csv(crop_disease_names_manual)
  
  crop_data_aggregated <- crop_data_aggregated |>
    dplyr::left_join(crop_disease_names_manual, by = dplyr::join_by(pest)) |>
    dplyr::mutate(pest = ifelse(!is.na(pest_new), pest_new, pest)) |>
    dplyr::select(-pest_new)
  
  # get list of all pest names
  pest_names <- na.omit(unique(crop_data_aggregated$pest))
  # pest_names <- pest_names[pest_names != ""]
  
  # split vector of pest names because SQLite maximum depth of an expression tree is 1000
  # use 500 because it speeds things up later with EPPO API calls
  pest_names_split <- (split(pest_names, ceiling(seq_along(pest_names) / 500)))
  
  # connect to the database
  conn <- pestr::eppo_database_connect(filepath = database_directory)
  
  # Check which pest names are present in EPPO SQLite Database
  # Creates list which contains: 
  # exist_in_DB data frame with matching names in database and their codeids, 
  # not_in_DB character vector of names from names_vector which do not match any entry in database
  # pref_names data frame with preferred names and their codeids
  # all_associated_names data frame containing all names matching codeids of preferred names. Last data frame contains also column with preferred (binary), codelang (two letter character with language code), and EPPOcode.
  pest_names_matched <- purrr::map(pest_names_split, ~pestr::eppo_names_tables(., conn))
  
  # create table of names that exist in db, remove duplicate rows
  # exist_in_DB will return all potential matches, including those that aren't exact (uses LIKE query)
  pest_names_matched_code_id <- purrr::map_dfr(pest_names_matched, ~.$exist_in_DB) |> 
    dplyr::distinct() |> 
    dplyr::rename(pest_name = fullname)
  
  # create table of names with EPPO codes, remove duplicate rows
  pest_names_matched_eppo_code <- purrr::map_dfr(pest_names_matched, ~.$pref_name) |> 
    dplyr::distinct() |> 
    dplyr::rename(preferred_name = fullname)
  
  # add the eppo codes to the matched names that exist in the db
  pest_names_matched_full <- dplyr::left_join(pest_names_matched_code_id, pest_names_matched_eppo_code,
                                              by = dplyr::join_by("codeid")) # was 4794, now 4849
  pest_names_matched_full <- pest_names_matched_full |>
    dplyr::filter(!is.na(eppocode)) # was 4714, now 4769
  
  # # find duplicate pest names
  # n_occur <- data.frame(table(pest_names_matched_full$pest_name))
  # n_occur <- n_occur[n_occur$Freq > 1,]
  # # which of these pest names also occur in the aggregated data?
  # n_occur <- n_occur |>
  #   dplyr::mutate(to_fix = Var1 %in% crop_data_aggregated$pest)
  # length(which(n_occur$to_fix == TRUE))
  # # duplicate names need to be removed so the pestr output can be joined to the aggregated data without a many-to-many warning
  
  # some names occur multiple times in the db because they have more than one EPPO code
  # read lookup table of duplicate names and EPPO codes to remove
  duplicate_crop_disease_names_to_remove <- read.csv(duplicate_crop_disease_names_to_remove) # 64
  
  pest_names_matched_full <- pest_names_matched_full |>
    dplyr::anti_join(duplicate_crop_disease_names_to_remove) # was 4650, now 4705
  
  distinct(pest_names_matched_full, pest_name, preferred_name)
  
  # register with EPPO Data Services (https://data.eppo.int/) to get a token (pestr::eppo_tabletools_hosts uses EPPO API)
  eppo_token <- pestr::create_eppo_token(eppo_token)
  
  # get alternate names and hosts for diseases
  pest_table_combined <- purrr::map_dfr(pest_names_matched, function(names_tables){
    compact_names <- pestr::eppo_tabletools_names(names_tables)
    compact_hosts <- pestr::eppo_tabletools_hosts(names_tables, eppo_token) 
    dplyr::full_join(compact_names[[2]], compact_hosts[[2]], by = "eppocode")
  }) 
  
  pest_table_combined <- pest_table_combined[!duplicated(pest_table_combined), ] # was 3237, now 3286
  
  # disconnect from the database
  RSQLite::dbDisconnect(conn)
  
  # join pest_names_matched_full, which contains the pest names as they appear in our database, with 
  # the additional names and hosts in pest_table_combined
  pest_table_full <- dplyr::left_join(pest_names_matched_full, pest_table_combined, 
                                      by = dplyr::join_by(codeid, eppocode, preferred_name == Preferred_name))
  
  pest_table_full <- pest_table_full |>
    dplyr::rename(code_id = codeid, 
                  eppo_code = eppocode, 
                  other_names = Other_names) |>
    dplyr::relocate(eppo_code, .after = code_id)
  
  
  # some final cleaning
  pest_table_full <- pest_table_full |>
    dplyr::mutate(pest_name = stringr::str_replace_all(pest_name, pattern = "\\s\\(no\\slonger\\sin\\suse\\)", replacement = "")) |>
    dplyr::mutate(preferred_name = stringr::str_replace_all(preferred_name, pattern = "\\s\\(no\\slonger\\sin\\suse\\)", replacement = ""))
  
  
  # join pestr output to aggregated data
  crop_data_aggregated <- crop_data_aggregated |>
    dplyr::left_join(pest_table_full, by = dplyr::join_by(pest == pest_name)) |>
    dplyr::relocate(preferred_name, .after = pest)
  
  return(crop_data_aggregated)

}
