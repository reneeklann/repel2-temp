#'
#' Perform optimised binning for model calibration curves
#' 
#' @param repel_validation_predict A data.frame of predictions based on
#'   the current model using validation data.
#' 
#' @returns A tibble with number of rows equal to the number of optimised bins.
#'   Returned tibble has information on number of predictions included in each
#'   bin, the lower value limit of a bin, the higher value limit of a bin, and
#'   the CEP_pav for each bin.
#'
#' @examples
#' optimise_bins(repel_validation_predict)
#' 
#' @export
#'

optimise_bins <- function(repel_validation_predict) {
  rd <- reliabilitydiag::reliabilitydiag(
    x = repel_validation_predict$predicted,
    y = as.integer(repel_validation_predict$outbreak_start)
  )

  ## Return optimised bins ----
  rd$x$bins
}


#'
#' Get binning values from optimised bin information
#'
#' @param repel_optimised_bins A tibble containing information on optimised bins
#'   usually produced by a call to `optimise_bins()` or by extracting bin
#'   information from `reliabilitydiag::reliabilitydiag()`
#'   
#' @returns A list of useful binning information from the bin optimisation
#'   process that can be used for other functions
#'   
#' @examples 
#' get_optimised_bin_values(repel_optimsed_bins)
#' 
#' @export
#'

get_optimised_bin_values <- function(repel_optimised_bins) {
  with(
    repel_optimised_bins,
    list(
      n = n,
      median = Map(median, x_min, x_max) |> unlist(),
      breaks = c(x_min, tail(x_max, 1))
    )
  )
}
