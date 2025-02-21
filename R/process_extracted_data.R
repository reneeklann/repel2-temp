#' Process extracted data
#'
#' This function...
#'
#' @return
#' 
#' @import dplyr
#' @import lubridate
#' 
#' @examples
#' 
#' @export
process_extracted_data <- function(extracted_data, crop_report_index_file) {
  
  # targets::tar_load(extracted_data)
  
  extracted_data <- read.csv(extracted_data)
  
  extracted_data <- extracted_data |> 
    dplyr::select(source, url, eppo_unique_id, country_code, 
                  preferred_name, disease_manual, disease_extracted, kingdom, 
                  date_published, year_published, issue, year_manual, year_extracted, 
                  month_manual, month_extracted, 
                  host_manual, host_extracted, 
                  presence_manual, presence_extracted, 
                  manually_extracted, 
                  flag_disease, flag_year, flag_presence) |>
    dplyr::rename(country_iso3c = country_code) |>
    dplyr::mutate(date_published = lubridate::ymd(date_published)) |>
    dplyr::mutate(manually_extracted = ifelse(is.na(manually_extracted), FALSE, manually_extracted))
  
  # Clean disease ----
  # Remove EPPO code and most other text in parentheses from extracted disease name
  # extracted_data <- data.frame(disease_extracted = c("Plum pox virus", "Plum pox virus - (PPV000)", "Plum pox virus (PPV)", "Ralstonia solanacearum", "Ralstonia solanacearum race 3 (biovar 2)"))
  extracted_data <- extracted_data |>
    dplyr::mutate(disease_extracted = stringr::str_remove(string = disease_extracted, pattern = "\\s-\\s\\([A-Z0-9]{5,6}\\)")) |>
    dplyr::mutate(disease_extracted = ifelse(stringr::str_detect(disease_extracted, "Ralstonia solanacearum"), 
                                             stringr::str_remove_all(disease_extracted, "\\(|\\)"), 
                                             stringr::str_remove(disease_extracted, "\\s\\(.*\\)")))
  
  # # Example disease name data for testing
  # preferred_name <- c("Globodera pallida", "Plum pox virus", NA, NA, "Xylella fastidiosa", "Xylella fastidiosa", NA, "Ralstonia solanacearum", "Ralstonia solanacearum", "Ralstonia solanacearum")
  # disease_manual <- c("Globodera pallida", NA, "'Candidatus Liberibacter asiaticus'", NA, "Xylella fastidiosa subsp. pauca", NA, NA, "Ralstonia solanacearum race 3 biovar 2", NA, NA)
  # disease_extracted <- c("Globodera pallida", "plum pox virus", "Candidatus Liberibacter asiaticus", "Candidatus Phytoplasma solani", 
  #                        "Xylella fastidiosa", "Xylella fastidiosa subsp. multiplex", "Xylella fastidiosa subsp. pauca", 
  #                        "Ralstonia solanacearum biovar 2 race 3", "Ralstonia solanacearum race 1", "Ralstonia solanacearum biovar 2 race 3")
  # kingdom <- c("Animalia", "Animalia", NA, NA, "Bacteria", "Bacteria", NA, "Bacteria", "Bacteria", "Bacteria")
  # extracted_data <- dplyr::bind_cols(preferred_name = preferred_name,
  #                                    disease_manual = disease_manual,
  #                                    disease_extracted = disease_extracted,
  #                                    kingdom = kingdom)
  
  # Coalesce name fields, then filter out reports for which disease is NA
  # (Some IPPC reports have no disease name in the structured data and 
  # no extracted disease name because the free text is basically empty)
  extracted_data <- extracted_data |>
    dplyr::mutate(disease = dplyr::coalesce(preferred_name, disease_manual, disease_extracted)) |>
    dplyr::filter(!is.na(disease))
  
  # If preferred name is Ralstonia solanacearum or Xylella fastidiosa, use manual or extracted name
  # (If preferred name is already Ralstonia solanacearum race 3 biovar 2 or Xylella fastidiosa subsp. multiplex, it doesn't need to be changed)
  extracted_data <- extracted_data |>
    dplyr::mutate(disease = ifelse(preferred_name %in% c("Ralstonia solanacearum", "Xylella fastidiosa") & !is.na(disease_manual), disease_manual, disease)) |>
    dplyr::mutate(disease = ifelse(preferred_name %in% c("Ralstonia solanacearum", "Xylella fastidiosa") & is.na(disease_manual), disease_extracted, disease))
  
  # Simplify name variations of Ralstonia solanacearum
  extracted_data <- extracted_data |>
    dplyr::mutate(disease = ifelse(stringr::str_detect(disease, "Ralstonia solanacearum race 1"), "Ralstonia solanacearum race 1", disease)) |>
    dplyr::mutate(disease = ifelse(stringr::str_detect(disease, "Ralstonia solanacearum race 2"), "Ralstonia solanacearum race 2", disease)) |>
    dplyr::mutate(disease = ifelse(stringr::str_detect(disease, "Ralstonia solanacearum") & 
                                   stringr::str_detect(disease, "race 3") & 
                                   stringr::str_detect(disease, "biovar 2"), 
                                   "Ralstonia solanacearum race 3 biovar 2", disease)) |>
    dplyr::mutate(disease = ifelse(stringr::str_detect(disease, "Ralstonia solanacearum race 3") & 
                                   disease != "Ralstonia solanacearum race 3 biovar 2", 
                                   "Ralstonia solanacearum race 3", disease)) |>
    dplyr::mutate(disease = ifelse(stringr::str_detect(disease, "Ralstonia solanacearum") & 
                                   stringr::str_detect(disease, "race", negate = TRUE) & 
                                   stringr::str_detect(disease, "species complex", negate = TRUE), 
                                   "Ralstonia solanacearum", disease))
  
  # diseases <- extracted_data |> janitor::tabyl(disease)
  
  # targets::tar_load(crop_report_index_file)
  
  crop_report_index <- read.csv(crop_report_index_file)
  
  # Get preferred names from index and add priority disease names that are not in index
  preferred_names <- crop_report_index |> 
    dplyr::select(preferred_name) |> 
    unique() |> 
    dplyr::rename(preferred = preferred_name)
  additional_priority_names <- tibble::tibble(
    preferred = c("Ralstonia solanacearum race 1", "Ralstonia solanacearum race 2", "Ralstonia solanacearum race 3", 
                  "Xylella fastidiosa subsp. fastidiosa", "Xylella fastidiosa subsp. pauca", "Xylella fastidiosa subsp. sandyi")
  )
  preferred_names <- dplyr::bind_rows(preferred_names, additional_priority_names) |> unique()
  
  # Use approximate string matching to match disease to preferred name from index
  fuzzy_standardize_names <- function(extracted_data, preferred_names) {
    extracted_data <- extracted_data |> 
      dplyr::mutate(match = preferred_names$preferred[stringdist::amatch(x=tolower(extracted_data$disease), tolower(preferred_names$preferred), method = "jw")])
  }
  extracted_data <- fuzzy_standardize_names(extracted_data, preferred_names)
  
  # test <- extracted_data |> dplyr::distinct(disease, match)
  
  # If preferred name is NA, use matched name, then filter out reports for which disease is NA
  extracted_data <- extracted_data |>
    dplyr::mutate(disease = ifelse(is.na(preferred_name) & disease != match, match, disease)) |>
    dplyr::select(-match) |>
    dplyr::filter(!is.na(disease))
  
  # Fill in kingdom for diseases that did not have standardized name and taxonomy in index ----
  kingdom <- crop_report_index |> 
    dplyr::select(preferred_name, kingdom) |>
    dplyr::rename(kingdom_index = kingdom) |>
    unique()
  extracted_data <- extracted_data |>
    dplyr::left_join(kingdom, by = dplyr::join_by(disease == preferred_name)) |>
    dplyr::mutate(kingdom = ifelse(is.na(kingdom), kingdom_index, kingdom)) |>
    dplyr::mutate(kingdom = ifelse(stringr::str_detect(disease, "Ralstonia solanacearum"), "Bacteria", kingdom)) |>
    dplyr::mutate(kingdom = ifelse(stringr::str_detect(disease, "Xylella fastidiosa"), "Bacteria", kingdom)) |>
    dplyr::select(-kingdom_index) |>
    dplyr::filter(kingdom != "Plantae") |>
    dplyr::filter(!is.na(kingdom))
  
  # Clean year ----
  extracted_data <- extracted_data |>
    dplyr::mutate(year = dplyr::coalesce(year_manual, year_extracted)) |>
    dplyr::mutate(year = ifelse(manually_extracted == TRUE & is.na(year_manual), NA, year))
  
  # Clean month ----
  extracted_data <- extracted_data |>
    # dplyr::mutate(month_extracted = stringr::str_remove(month_extracted, "(?i)spring|summer|autumn|winter")) |>
    dplyr::mutate(month_extracted = ifelse(!month_extracted %in% c("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"), NA, month_extracted)) |>
    dplyr::mutate(month = dplyr::coalesce(month_manual, month_extracted)) |>
    dplyr::mutate(month = ifelse(manually_extracted == TRUE & is.na(month_manual), NA, month))
  
  # Clean host ----
  # extracted_data <- data.frame(host_extracted = c("Zea mays", "corn", NA, "fruit fly", "Various"))
  extracted_data <- extracted_data |>
    dplyr::mutate(host_extracted = stringr::str_remove(host_extracted, "(?i)fruit fly|ornamental plants|horticultural crops|deciduous trees|woody plants|and other hardwoods")) |>
    dplyr::mutate(host_extracted = dplyr::na_if(host_extracted, "")) |>
    dplyr::mutate(host = dplyr::coalesce(host_manual, host_extracted)) |>
    dplyr::mutate(host = ifelse(manually_extracted == TRUE & is.na(host_manual), NA, host))
  # can't cover all possible terms but this is a start
  
  # Clean presence ----
  # extracted_data <- data.frame(presence_extracted = c("present", "absent", "unknown", NA, "intercepted"))
  extracted_data <- extracted_data |>
    dplyr::mutate(presence_extracted = dplyr::case_when(is.na(presence_extracted) | presence_extracted %in% c("present", "absent") ~ presence_extracted, TRUE ~ NA_character_)) |>
    dplyr::mutate(presence = dplyr::coalesce(presence_manual, presence_extracted)) |>
    dplyr::mutate(presence = ifelse(manually_extracted == TRUE & is.na(presence_manual), NA, presence))
  
  # Aggregate subtypes of Ralstonia solanacearum and Xylella fastidiosa (requires clean presence) ----
  # Only for records where disease is present because absence of subspecies does not mean disease as a whole is absent
  # aggregate R. solanacearum race 3 biovar 2 into race 3
  extracted_data <- extracted_data |>
    dplyr::mutate(rs_race = stringr::str_detect(disease, "Ralstonia solanacearum race") & presence == "present") |>
    dplyr::mutate(rs_race3_biovar2 = disease == "Ralstonia solanacearum race 3 biovar 2" & presence == "present") |>
    dplyr::mutate(xf_subsp = stringr::str_detect(disease, "Xylella fastidiosa subsp.") & presence == "present")
  rs_race <- extracted_data |>
    dplyr::filter(rs_race == TRUE) |>
    dplyr::mutate(disease = "Ralstonia solanacearum")
  rs_race3_biovar2 <- extracted_data |>
    dplyr::filter(rs_race3_biovar2 == TRUE) |>
    dplyr::mutate(disease = "Ralstonia solanacearum race 3")
  xf_subsp <- extracted_data |>
    dplyr::filter(xf_subsp == TRUE) |>
    dplyr::mutate(disease = "Xylella fastidiosa")
  extracted_data <- dplyr::bind_rows(extracted_data, rs_race, rs_race3_biovar2, xf_subsp)
  
  # diseases <- extracted_data |> janitor::tabyl(disease)
  
  # Create field event_date based on extracted year/month or report publication date ----
  get_event_month <- function(year, month, source, date_published, year_published, issue) {
    if(!is.na(year) & !is.na(month)) {event_date = lubridate::my(paste(month, year))}
    else if(!is.na(year) & is.na(month)) {event_date = lubridate::ym(paste(year, "01"))}
    else if(is.na(year) & (source == "IPPC" | source == "NAPPO")) {event_date = lubridate::floor_date(date_published, "month")}
    else if(is.na(year) & source == "EPPO") {event_date = lubridate::ym(paste(year_published, issue))}
    return(event_date)
  }
  
  events <- extracted_data |>
    dplyr::mutate(event_month_imputed = is.na(year)) |>
    dplyr::rowwise() |>
    dplyr::mutate(event_month = get_event_month(year, month, source, date_published, year_published, issue)) |>
    dplyr::select(source, url, eppo_unique_id, country_iso3c, disease, kingdom, year, month, event_month, event_month_imputed, host, presence, flag_disease, flag_year, flag_presence, manually_extracted) |>
    dplyr::arrange(dplyr::pick(disease, event_month)) |> 
    dplyr::ungroup()
  
  return(events)
}
