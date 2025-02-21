#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param repel_calibration
#' @return
#' @export
table_calibration <- function(repel_calibration) {

  repel_calibration |> 
    dplyr::select(-predicted_grp_median) |> 
    dplyr::mutate(predicted_mean_in_range = predicted_grp_mean >= outbreak_start_actual_low & predicted_grp_mean <= outbreak_start_actual_upper) |>
    dplyr::mutate(predicted_mean_in_range = ifelse(predicted_mean_in_range, "yes", "no")) |> 
    dplyr::mutate(across(c(predicted_grp_mean, outbreak_start_actual_prob, outbreak_start_actual_low, outbreak_start_actual_upper), ~signif(10000*., 2))) |>  # calculate per 10000
    dplyr::mutate(outbreak_start_actual_lab = paste0(outbreak_start_actual_prob, " ", "(", outbreak_start_actual_low, "-", outbreak_start_actual_upper, ")"))  |> 
    dplyr::select(-outbreak_start_actual_prob, -outbreak_start_actual_low, -outbreak_start_actual_upper) |> 
    dplyr::arrange(predicted_grp) |> 
    dplyr::select(-predicted_grp) |> 
    dplyr::select("Mean Prediction" = predicted_grp_mean,
           "Observed Outbreak Rate (mean and 95%CI)" = outbreak_start_actual_lab,
           "Mean Prediction within 95%CI" = predicted_mean_in_range) 

}
