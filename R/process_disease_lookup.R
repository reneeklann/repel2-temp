#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param download_file
#' @return
#' @author Emma Mendelsohn
#' @export
process_disease_lookup <- function(download_file = wahis_epi_events_downloaded) {

    wahis_events <- arrow::read_parquet(download_file)
    
    wahis_events <- wahis_events |>
      dplyr::distinct(disease = standardized_disease_name) |>
      dplyr::mutate(
        disease_recode = stringr::str_replace_all(
          string = disease, #pattern = "\\s*\\([^\\)]+\\)|\\."
          pattern = "-", replacement = " "
        ) |>
          janitor::make_clean_names()
      )

    return(wahis_events)
}
