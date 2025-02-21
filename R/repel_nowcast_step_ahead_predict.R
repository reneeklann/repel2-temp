#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param country_livestock_six_month_disease_status_for_prediction
#' @return
#' @author emmamendelsohn
#' @export
repel_nowcast_step_ahead_predict <- function(country_livestock_six_month_disease_status_for_prediction) {
  
  step_ahead <- country_livestock_six_month_disease_status_for_prediction |> 
    dplyr::select(country_iso3c, disease, report_period, disease_status) |> 
    dplyr::mutate(disease_status_unreported = disease_status == "unreported") |> 
    dplyr::mutate(disease_status = dplyr::na_if(disease_status, "unreported")) |> 
    dplyr::group_by(country_iso3c, disease) |> 
    dplyr::arrange(report_period)  |> 
    (\(x) tidyr::fill(x, disease_status))() |> 
    dplyr::ungroup() |> 
    dplyr::filter(disease_status == "present") |> 
    dplyr::rename(imputed = disease_status_unreported)
  
  return(step_ahead)
  
  
  
}
