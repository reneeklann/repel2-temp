#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param pest_names_standardized
#' @return
#' @author Emma Mendelsohn
#' @export
standardize_pest_taxonomy <- function(pest_names_standardized, 
                                      pest_names_not_standardized, 
                                      crop_disease_taxonomy_manual) {
  
  # assertthat::assert_that(nrow(pest_names_not_standardized) == 0, msg = paste("There are", nrow(pest_names_not_standardized), "pest names that need to be standardized manually"))
  if(nrow(pest_names_not_standardized) > 0) {
    warning(paste("The following disease names are not standardized and will be filtered out:", stringr::str_flatten(pest_names_not_standardized$pest, collapse = ", ")))
  }
  
  # create vector of urls to scrape (based on unique EPPO codes from pestr output)
  eppo_code_urls <- na.omit(unique(pest_names_standardized$eppo_code))
  eppo_code_urls <- paste0("https://gd.eppo.int/taxon/", eppo_code_urls)
  
  # scrape taxonomy for each EPPO code
  pest_taxonomy <- purrr::map_dfr(eppo_code_urls, function(eppo_code_url){
    pest_page_html <- rvest::read_html(eppo_code_url)
    pest_taxonomy <- pest_page_html |> rvest::html_element(".ptable") |> rvest::html_text() |> stringr::str_squish()
    tibble::tibble(eppo_code = basename(eppo_code_url), taxonomy = pest_taxonomy)
  })
  
  # separate taxonomy into variables kingdom, phylum, class, order, family, genus, species
  pest_taxonomy <- pest_taxonomy |>
    # KINGDOM
    dplyr::mutate(kingdom = stringr::str_extract(taxonomy, pattern = "(?:Kingdom\\s[A-Za-z]+\\s\\(|Kingdom\\s[A-Za-z]+\\s[a-z]+\\s[a-z]+)")) |>
    dplyr::mutate(kingdom = stringr::str_replace_all(kingdom, pattern = "Kingdom\\s", replacement = "")) |>
    dplyr::mutate(kingdom = stringr::str_replace_all(kingdom, pattern = "\\s\\(", replacement = "")) |>
    # PHYLUM
    dplyr::mutate(phylum = stringr::str_extract(taxonomy, pattern = "Phylum\\s[A-Za-z]+")) |>
    dplyr::mutate(phylum = stringr::str_replace_all(phylum, pattern = "Phylum\\s", replacement = "")) |>
    # CLASS
    dplyr::mutate(class = stringr::str_extract(taxonomy, pattern = "Class\\s[A-Za-z]+")) |>
    dplyr::mutate(class = stringr::str_replace_all(class, pattern = "Class\\s", replacement = "")) |>
    # ORDER
    dplyr::mutate(order = stringr::str_extract(taxonomy, pattern = "Order\\s[A-Za-z]+")) |>
    dplyr::mutate(order = stringr::str_replace_all(order, pattern = "Order\\s", replacement = "")) |>
    # FAMILY
    dplyr::mutate(family = stringr::str_extract(taxonomy, pattern = "Family\\s[A-Za-z]+")) |>
    dplyr::mutate(family = stringr::str_replace_all(family, pattern = "Family\\s", replacement = "")) |>
    # GENUS
    dplyr::mutate(genus = stringr::str_extract(taxonomy, pattern = "Genus\\s[A-Za-z]+")) |>
    dplyr::mutate(genus = stringr::str_replace_all(genus, pattern = "Genus\\s", replacement = "")) |>
    dplyr::mutate(genus = stringr::str_replace_all(genus, pattern = "Elsino", replacement = "Elsinoë")) |>
    # SPECIES - multiple words, can contain characters other than letters
    dplyr::mutate(species = stringr::str_extract(taxonomy, pattern = "Species\\s.*\\s\\(")) |>
    dplyr::mutate(species = stringr::str_replace_all(species, pattern = "Species\\s", replacement = "")) |>
    dplyr::mutate(species = stringr::str_replace_all(species, pattern = "\\s\\(no\\slonger\\sin\\suse\\)", replacement = "")) |>
    dplyr::mutate(species = stringr::str_replace_all(species, pattern = "\\s\\(", replacement = ""))
  
  # remove names that are not standardized from dataset
  crop_data_aggregated <- pest_names_standardized |>
    dplyr::filter(!pest %in% pest_names_not_standardized$pest)
  
  # join taxonomy into dataset
  crop_data_aggregated <- crop_data_aggregated |>
    dplyr::left_join(pest_taxonomy, by = dplyr::join_by(eppo_code))
  
  # manually add taxonomy
  crop_disease_taxonomy_manual <- read.csv(crop_disease_taxonomy_manual)
  crop_data_aggregated <- crop_data_aggregated |>
    dplyr::left_join(crop_disease_taxonomy_manual, by = dplyr::join_by(pest))
  
  crop_data_aggregated <- crop_data_aggregated |>
    dplyr::mutate(preferred_name.x = ifelse(!is.na(preferred_name.y), preferred_name.y, preferred_name.x)) |>
    dplyr::mutate(eppo_code.x = ifelse(!is.na(eppo_code.y), eppo_code.y, eppo_code.x)) |>
    dplyr::mutate(kingdom.x = ifelse(!is.na(kingdom.y), kingdom.y, kingdom.x)) |>
    dplyr::mutate(phylum.x = ifelse(!is.na(phylum.y), phylum.y, phylum.x)) |>
    dplyr::mutate(class.x = ifelse(!is.na(class.y), class.y, class.x)) |>
    dplyr::mutate(order.x = ifelse(!is.na(order.y), order.y, order.x)) |>
    dplyr::mutate(family.x = ifelse(!is.na(family.y), family.y, family.x)) |>
    dplyr::mutate(genus.x = ifelse(!is.na(genus.y), genus.y, genus.x)) |>
    dplyr::mutate(species.x = ifelse(!is.na(species.y), species.y, species.x)) |>
    dplyr::select(-c(preferred_name.y, eppo_code.y, kingdom.y, phylum.y, class.y, order.y, family.y, genus.y, species.y)) |>
    dplyr::rename(preferred_name = preferred_name.x,
                  eppo_code = eppo_code.x,
                  kingdom = kingdom.x,
                  phylum = phylum.x,
                  class = class.x,
                  order = order.x,
                  family = family.x,
                  genus = genus.x,
                  species = species.x
    )
  
  # # check for records with no preferred name
  # pest_names_not_matched <- crop_data_aggregated |>
  #   dplyr::relocate(preferred_name, .after = pest) |>
  #   dplyr::relocate(eppo_code, .after = preferred_name) |>
  #   dplyr::filter(pest != "" &
  #                 !is.na(crop_data_aggregated$pest) &
  #                 is.na(crop_data_aggregated$preferred_name))
  
  # # check for records with preferred name but no taxonomy
  # pest_names_missing_taxonomy <- crop_data_aggregated |>
  #   dplyr::relocate(preferred_name, .after = pest) |>
  #   dplyr::relocate(eppo_code, .after = preferred_name) |>
  #   dplyr::filter(!is.na(crop_data_aggregated$pest) &
  #                 !is.na(crop_data_aggregated$preferred_name) &
  #                 is.na(crop_data_aggregated$kingdom))
  # # 2 records (Chestnut yellows, pathogen undetermined)
  
  # filter out non-priority diseases that are only reported once
  priority_diseases <- crop_data_aggregated |>
    dplyr::filter(priority == TRUE) |>
    dplyr::pull(preferred_name) |>
    unique()
  rarely_reported_diseases <- crop_data_aggregated |>
    janitor::tabyl(preferred_name) |>
    dplyr::filter(n == 1) |>
    dplyr::filter(!preferred_name %in% priority_diseases) |>
    dplyr::pull(preferred_name) |>
    unique()
  crop_data_aggregated <- crop_data_aggregated |>
    dplyr::filter(!preferred_name %in% rarely_reported_diseases)
  
  write.csv(crop_data_aggregated, "data-raw/crop-disease-lookup/crop_report_index.csv")
  
  return(crop_data_aggregated)
}
