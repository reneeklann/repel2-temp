#' Summarize augmented data over country origins
#'
#' @param augmented_livestock_data_disaggregated_with_windows
#' @return
#' @export
aggregate_augmented_livestock_data <- function(augmented_livestock_data_disaggregated) {
  
  ## aggregate augmented livestock data ----
  ### sum trade/migration from outbreaks over the origin countries
  augmented_livestock_data_aggregated <- augmented_livestock_data_disaggregated |> 
    dplyr::select(-country_origin) |> 
    dplyr::group_by(
      dplyr::across(
        -c(n_migratory_wildlife_from_outbreaks, 
           shared_borders_from_outbreaks, 
           comtrade_dollars_from_outbreaks, 
           fao_livestock_heads_from_outbreaks)
      )
    ) |> 
    dplyr::summarize_all(~sum(., na.rm = TRUE)) |> # this turns all NA into 0
    dplyr::ungroup() |> 
    tibble::as_tibble()
  
  ## log transform "from_outbreak" variables  ----
  augmented_livestock_data_aggregated <- augmented_livestock_data_aggregated |> 
    dplyr::mutate(
      log_fao_livestock_heads_from_outbreaks = prepvar(
        fao_livestock_heads_from_outbreaks + 1, 
        trans_fn = log10),
      log_comtrade_dollars_from_outbreaks = prepvar(
        comtrade_dollars_from_outbreaks + 1, 
        trans_fn = log10),
      log_n_migratory_wildlife_from_outbreaks = prepvar(
        n_migratory_wildlife_from_outbreaks + 1, 
        trans_fn = log10),
    ) |>
    dplyr::select(-fao_livestock_heads_from_outbreaks, -comtrade_dollars_from_outbreaks, -n_migratory_wildlife_from_outbreaks)
    
  ## Test that outputs are as expected ----
  
  start <- augmented_livestock_data_disaggregated |> 
    dplyr::distinct(across(c(country_iso3c, disease, prediction_window))) |> 
    nrow()
  final <- nrow(augmented_livestock_data_aggregated)
  
  assertthat::assert_that(final == start)
  
  return(augmented_livestock_data_aggregated)
}