#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param wahis_outbreaks_downloaded
#' @return
#' @author Emma Mendelsohn
#' @export
process_wahis_disease_taxa_lookup <- function(wahis_outbreaks_downloaded) {
  data_check <- check_wahis_outbreaks(
    wahis_outbreaks_downloaded,
    index_fields = c("standardized_taxon_name", "standardized_disease_name")
  )

  if (!is.null(data_check)) {
    stop(data_check)
  }

  disease_taxa_list <- arrow::open_dataset(wahis_outbreaks_downloaded) |>
    dplyr::distinct(standardized_taxon_name, standardized_disease_name) |>
    dplyr::filter(!standardized_taxon_name %in% c("unknown", "mixed")) |>
    dplyr::collect()

  return(disease_taxa_list)

}
