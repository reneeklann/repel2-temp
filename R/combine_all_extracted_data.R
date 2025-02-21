#' Create final extracted data file
#'
#' This function combines the assessment pipeline data, which is manually extracted,
#' and the full pipeline data, some of which is manually reviewed, 
#' and saves a csv file for further processing
#'
#' @return 
#' 
#' @import dplyr
#' 
#' @examples
#' 
#' @export
combine_all_extracted_data <- function(extracted_data_combined_sample, extracted_data_flagged) {
  
  # targets::tar_load(extracted_data_combined_sample)
  # targets::tar_load(extracted_data_flagged)
  
  manually_reviewed_data <- readxl::read_xlsx("data-raw/crop-data-extracted/extracted_data_flagged_manual_review.xlsx")
  manually_reviewed_data <- manually_reviewed_data |>
    dplyr::filter(manually_extracted == TRUE) |>
    dplyr::mutate(year_manual = dplyr::na_if(year_manual, "NA")) |>
    dplyr::mutate(month_manual = dplyr::na_if(month_manual, "NA")) |>
    dplyr::mutate(host_manual = dplyr::na_if(host_manual, "NA")) |>
    dplyr::mutate(presence_manual = dplyr::na_if(presence_manual, "NA")) |>
    dplyr::mutate(year_manual = as.integer(year_manual)) |>
    dplyr::select(c(url, eppo_unique_id, disease_manual, year_manual, month_manual, 
                    host_manual, presence_manual, manually_extracted, notes))
  
  # IPPC and NAPPO
  extracted_data_flagged_ippc_nappo <- extracted_data_flagged |>
    dplyr::filter(source == "IPPC" | source == "NAPPO") |>
    dplyr::left_join(manually_reviewed_data, by = dplyr::join_by(url)) |>
    dplyr::select(-eppo_unique_id.y) |> dplyr::rename(eppo_unique_id = eppo_unique_id.x)
  
  # EPPO
  extracted_data_flagged_eppo <- extracted_data_flagged |>
    dplyr::filter(source == "EPPO") |>
    dplyr::left_join(manually_reviewed_data, by = dplyr::join_by(url, eppo_unique_id))
  
  extracted_data_complete <- dplyr::bind_rows(extracted_data_combined_sample, 
                                              extracted_data_flagged_ippc_nappo, 
                                              extracted_data_flagged_eppo)
  
  # test <- extracted_data_complete |>
  #   dplyr::select(source, pest, preferred_name, disease_extracted, disease_manual, 
  #                 year_extracted, year_manual, month_extracted, month_manual, 
  #                 host_extracted, host_manual, presence_extracted, presence_manual, 
  #                 manually_extracted, notes)
  
  # dupes <- extracted_data_complete |> janitor::get_dupes(eppo_unique_id)
  
  write.csv(extracted_data_complete, "data-raw/crop-data-extracted/extracted_data_complete.csv")
  
}
