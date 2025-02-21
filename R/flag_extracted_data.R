#' Flag extracted crop disease event data
#'
#' This function...
#'
#' @return
#'
#' @import dplyr
#'
#' @examples
#'
#' @export
flag_extracted_data <- function(extracted_data_combined) {
  
  # targets::tar_load(extracted_data_combined)
  
  # Disease: priority diseases that need to be manually checked (Xylella fastidiosa and Ralstonia solanacearum)
  # Don't need to check if preferred_name already contains subspecies or race/biovar of interest
  extracted_data_combined <- extracted_data_combined |>
    dplyr::mutate(flag_disease = stringr::str_detect(disease_extracted, "Xylella fastidiosa|Ralstonia solanacearum")) |>
    dplyr::mutate(flag_disease = ifelse(stringr::str_detect(preferred_name, "Xylella fastidiosa subsp. fastidiosa|Xylella fastidiosa subsp. multiplex|Xylella fastidiosa subsp. pauca|Ralstonia solanacearum race 3 biovar 2"), FALSE, flag_disease))
  
  # Year: more recent than publication year or too long before publication year
  extracted_data_combined <- extracted_data_combined |>
    dplyr::mutate(flag_year_recent = ifelse(is.na(year_extracted), FALSE, year_extracted > year_published)) |>
    dplyr::mutate(flag_year_old_ippc_nappo = ifelse(is.na(year_extracted), FALSE, (source == "IPPC" | source == "NAPPO") & year_extracted + 1 < year_published)) |>
    dplyr::mutate(flag_year_old_eppo = ifelse(is.na(year_extracted), FALSE, source == "EPPO" & year_extracted + 5 < year_published)) |>
    dplyr::mutate(flag_year = flag_year_recent == TRUE | flag_year_old_ippc_nappo == TRUE | flag_year_old_eppo == TRUE) |>
    dplyr::select(-c(flag_year_recent, flag_year_old_ippc_nappo, flag_year_old_eppo))
  
  # Presence: NA, something other than "present" or "absent", "absent" for NAPPO reports, implausible based on EPPO keywords
  extracted_data_combined <- extracted_data_combined |>
    dplyr::mutate(flag_presence_na = is.na(presence_extracted)) |>
    dplyr::mutate(flag_presence_enumeration = !is.na(presence_extracted) & !presence_extracted %in% c("present", "absent")) |>
    dplyr::mutate(flag_presence_nappo_absent = source == "NAPPO" & presence_extracted == "absent") |>
    dplyr::mutate(keywords = paste(keyword1, keyword2)) |>
    dplyr::mutate(flag_presence_keywords = ifelse(source == "IPPC" | source == "NAPPO" | is.na(presence_extracted), FALSE, 
                                                  (presence_extracted == "present" & stringr::str_detect(keywords, "Absence")) | 
                                                  (presence_extracted == "absent" & stringr::str_detect(keywords, "New pest|New record|Detailed record")))) |>
    dplyr::mutate(flag_presence = flag_presence_na == TRUE | flag_presence_enumeration | flag_presence_nappo_absent | flag_presence_keywords == TRUE) |>
    dplyr::select(-c(flag_presence_na, flag_presence_enumeration, flag_presence_nappo_absent, flag_presence_keywords, keywords))
  
  # test <- extracted_data_combined |> dplyr::select(source, country, pest, preferred_name,
  #                                                  disease_extracted, year_extracted, presence_extracted,
  #                                                  flag_disease, flag_year, flag_presence)
  
  extracted_data_combined
}
