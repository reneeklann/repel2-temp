#' Combine extracted data from all sources
#'
#' This function
#'
#' @return 
#' 
#' @import dplyr
#' 
#' @examples
#' 
#' @export
combine_extracted_data_sample <- function(ippc_reports_sample, ippc_data_formatted_sample, 
                                          nappo_reports_sample, nappo_data_formatted_sample, 
                                          eppo_single_reports_sample, eppo_single_data_formatted_sample, 
                                          eppo_multi_reports_preprocessed_sample, 
                                          eppo_multi_data_formatted_sample, 
                                          crop_data_manual) {
  
  # targets::tar_load(ippc_reports_sample)
  # targets::tar_load(ippc_data_formatted_sample)
  # 
  # targets::tar_load(nappo_reports_sample)
  # targets::tar_load(nappo_data_formatted_sample)
  # 
  # targets::tar_load(eppo_single_reports_sample)
  # targets::tar_load(eppo_single_data_formatted_sample)
  # 
  # targets::tar_load(eppo_multi_reports_preprocessed_sample)
  # targets::tar_load(eppo_multi_data_formatted_sample)
  # 
  # targets::tar_load(crop_data_manual)
  
  # for each source, join main data table and extracted data
  ippc <- dplyr::left_join(ippc_reports_sample, ippc_data_formatted_sample, by = dplyr::join_by(url))
  nappo <- dplyr::left_join(nappo_reports_sample, nappo_data_formatted_sample, by = dplyr::join_by(url))
  eppo_single <- dplyr::left_join(eppo_single_reports_sample, eppo_single_data_formatted_sample, 
                                  by = dplyr::join_by(url, eppo_unique_id))
  eppo_multi <- dplyr::left_join(eppo_multi_reports_preprocessed_sample, eppo_multi_data_formatted_sample, 
                                 by = dplyr::join_by(url, eppo_unique_id))
  
  # combine all sources, convert publication year to integer, unnest response
  all_sources <- dplyr::bind_rows(ippc, nappo, eppo_single, eppo_multi) |>
    dplyr::mutate(year_published = as.integer(year_published)) |>
    tidyr::unnest_wider(response) |>
    dplyr::rename(
      disease_extracted = disease,
      year_extracted = year,
      month_extracted = month,
      host_extracted = host,
      presence_extracted = presence
      # event_type_extracted = event_type
    ) |>
    dplyr::mutate(dplyr::across(c(disease_extracted, year_extracted, month_extracted, host_extracted, presence_extracted), ~dplyr::na_if(., "NA")))
  
  # test <- all_sources |> dplyr::select(preferred_name, disease_extracted, year_extracted, month_extracted, host_extracted, presence_extracted)
  
  # read in manually extracted data
  crop_data_manual <- read.csv(crop_data_manual)
  crop_data_manual <- crop_data_manual |>
    dplyr::select(source, url, eppo_unique_id, disease_manual, year_manual, month_manual, host_manual, presence_manual, manually_extracted, notes)
  
  # join IPPC and NAPPO
  ippc_nappo <- all_sources |>
    dplyr::filter(source == "IPPC" | source == "NAPPO")
  ippc_nappo_manual <- crop_data_manual |>
    dplyr::filter(source == "IPPC" | source == "NAPPO") |>
    dplyr::select(-c(source, eppo_unique_id))
  ippc_nappo <- ippc_nappo |>
    dplyr::left_join(ippc_nappo_manual, by = dplyr::join_by(url))
  
  # join EPPO
  eppo <- all_sources |>
    dplyr::filter(source == "EPPO")
  eppo_manual <- crop_data_manual |>
    dplyr::filter(source == "EPPO") |>
    dplyr::select(-source)
  eppo <- eppo |>
    dplyr::left_join(eppo_manual, by = dplyr::join_by(url, eppo_unique_id))
  
  # combine all sources
  all_sources <- dplyr::bind_rows(ippc_nappo, eppo)
  
  # clean year and convert to integer
  # all_sources <- data.frame(year_extracted = c("2001", NA, "(2002)", "2003/2004", "2005-2006", "2007 to 2008", "2009 and 2010", "1990s", "(1998-1999)", "the early 80s", "(since 1995)", "(1992-93)"), 
  #                           correct_year = c(2001, NA, 2002, 2003, 2005, 2007, 2009, NA, 1998, NA, 1955, 1992))
  all_sources <- all_sources |>
    dplyr::mutate(year_extracted = ifelse(stringr::str_detect(year_extracted, "\\d{4}", negate = TRUE), NA, year_extracted)) |>
    dplyr::mutate(year_extracted = stringr::str_remove_all(year_extracted, "\\(|\\)")) |>
    dplyr::mutate(year_extracted = ifelse(stringr::str_detect(year_extracted, "\\d{4}-\\d{4}|\\d{4}\\/\\d{4}|\\d{4}\\s\\d{4}|\\d{4}\\sto\\s\\d{4}|\\d{4}\\sand\\s\\d{4}"), 
                                          pmin(as.integer(stringr::str_extract(year_extracted, "\\d{4}")),
                                               as.integer(stringr::str_extract(year_extracted, "\\d{4}$"))),
                                          year_extracted)) |>
    dplyr::mutate(year_extracted = ifelse(stringr::str_detect(year_extracted, "\\d{4}-\\d{2}|\\d{4}\\/\\d{2}"), 
                                          stringr::str_extract(year_extracted, "\\d{4}"), 
                                          year_extracted)) |>
    dplyr::mutate(year_extracted = ifelse(stringr::str_detect(year_extracted, "\\d{4}s"), NA, year_extracted)) |>
    dplyr::mutate(year_extracted = stringr::str_remove_all(year_extracted, "[A-Za-z\\s]")) |>
    dplyr::mutate(year_extracted = as.integer(year_extracted)) |>
    dplyr::mutate(year_extracted = ifelse(year_extracted > as.integer(format(Sys.Date(), "%Y")), NA, year_extracted))
  
  return(all_sources)
}
