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
combine_extracted_data <- function(ippc_reports, ippc_data_formatted, 
                                   nappo_reports, nappo_data_formatted, 
                                   eppo_single_reports, eppo_single_data_formatted, 
                                   eppo_multi_reports_preprocessed, eppo_multi_data_formatted) {
  
  # targets::tar_load(ippc_reports)
  # targets::tar_load(ippc_data_formatted)
  # 
  # targets::tar_load(nappo_reports)
  # targets::tar_load(nappo_data_formatted)
  # 
  # targets::tar_load(eppo_single_reports)
  # targets::tar_load(eppo_single_data_formatted)
  # 
  # targets::tar_load(eppo_multi_reports_preprocessed)
  # targets::tar_load(eppo_multi_data_formatted)
  
  # # arrange reports by preferred name (because extracted data is in order of name-based branching)
  # ippc_reports <- ippc_reports |> dplyr::arrange(preferred_name)
  # nappo_reports <- nappo_reports |> dplyr::arrange(preferred_name)
  # eppo_single_reports <- eppo_single_reports |> dplyr::arrange(preferred_name)
  # eppo_multi_reports_preprocessed <- eppo_multi_reports_preprocessed |> dplyr::arrange(preferred_name)
  
  # for each source, join main data table and extracted data
  ippc <- dplyr::left_join(ippc_reports, ippc_data_formatted, by = dplyr::join_by(url))
  nappo <- dplyr::left_join(nappo_reports, nappo_data_formatted, by = dplyr::join_by(url))
  eppo_single <- dplyr::left_join(eppo_single_reports, eppo_single_data_formatted, 
                                  by = dplyr::join_by(url, eppo_unique_id))
  eppo_multi <- dplyr::left_join(eppo_multi_reports_preprocessed, eppo_multi_data_formatted, 
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
  
  # sort(unique(all_sources$year_extracted))
  
  return(all_sources)
}
