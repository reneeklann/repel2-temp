#' 
#' Generate calibrated model predictions validation
#' 
#' @param repel_validation_predict A data.frame of predictions based on
#'   the current model using validation data.
#' @param opt_bins Logical. Should optimised binning of predictions be applied?
#'   Default to TRUE. If set to FALSE, predictions are grouped into number of
#'   groups equal to value of `bins`.
#' @param bins Number of bins to use for calibration. Default is 30.
#'  
#' @returns
#' 
#' @export
#' 
generate_calibration <- function(repel_validation_predict, 
                                 opt_bins = TRUE,
                                 bins = 30) {
  ## Determine binning approach to predictions ----
  if (opt_bins) {
    ## Get optimsed bins information ----
    opt_breaks <- optimise_bins(repel_validation_predict) |>
      get_optimised_bin_values() |>
      (\(x) x$breaks)()
    expr <- "cut(predicted, breaks = opt_breaks, include.lowest = TRUE, right = FALSE)"
  } else {
    expr <- "ggplot2::cut_number(predicted, n = bins)"
  }

  lme_predict_grp <- repel_validation_predict  |> 
    dplyr::select(country_iso3c, disease, prediction_window, predicted, outbreak_start) |> 
    dplyr::mutate(predicted_grp = eval(parse(text = expr))) |>
    dplyr::group_by(predicted_grp) |>
    dplyr::mutate(predicted_grp_median = median(predicted, na.rm = TRUE)) |>
    #dplyr::mutate(predicted_grp_mean = mean(predicted, na.rm = TRUE)) |> 
    dplyr::mutate(
      predicted_grp_mean = stringr::str_remove_all(predicted_grp, "\\[|\\)|\\]") |> 
        stringr::str_split(pattern = ",") |> 
        lapply(function(x) as.numeric(x) |> median()) |> 
        unlist()
    ) |>
    dplyr::mutate(predicted_grp_min = min(predicted, na.rm = TRUE)) |>
    dplyr::mutate(predicted_grp_max = max(predicted, na.rm = TRUE)) |>
    dplyr::ungroup()
  
  lme_predict_grp_sizes <- lme_predict_grp |> 
    dplyr::group_by(predicted_grp) |> 
    dplyr::count() |> 
    dplyr::ungroup() |> 
    dplyr::arrange(predicted_grp) 
  
  # overall forecast vs actual by binom group
  lme_binoms <- lme_predict_grp |>
    dplyr::group_by(predicted_grp) |>
    dplyr::group_split() |>
    purrr::map_dfr(function(tw){
      binom <-  binom::binom.confint(x = sum(tw$outbreak_start), n=nrow(tw), methods = "wilson")
      tw |>
        dplyr::distinct(predicted_grp, predicted_grp_median, predicted_grp_mean, predicted_grp_max, predicted_grp_min) |>
        dplyr::mutate(outbreak_start_actual_prob = binom$mean, outbreak_start_actual_low = binom$lower, outbreak_start_actual_upper = binom$upper)})

  return(lme_binoms)
}

