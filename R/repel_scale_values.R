#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param repel_training_data_select
#' @param repel_predictor_variables
#' @return
#' @export
repel_scale_values <- function(repel_training_data_select, 
                               repel_predictor_variables) {
  
  ## mean/sd for scaling predictions ----
  scaling_values <- repel_training_data_select |>
    dplyr::select(all_of(repel_predictor_variables), -continent, -disease_present_anywhere, -outbreak_previous) |>
    tidyr::gather() |>
    dplyr::group_by(key) |>
    dplyr::summarize(mean = mean(value), sd = sd(value)) |>
    dplyr::ungroup()
  
  ## scale ----
  repel_data_compressed <- repel_training_data_select |>
    network_recipe(
      repel_predictor_variables, 
      scaling_values, 
      include_time = TRUE
    ) |>
    dplyr::group_by_all() |>
    dplyr::count() |>
    dplyr::ungroup() |>
    dplyr::select(
      country_iso3c, disease, count = n, outbreak_start, dplyr::everything(), 
    ) |>
    dplyr::arrange(disease, desc(count), country_iso3c)
  
  list(scaling_values, repel_data_compressed)
}



#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param repel_training_data_select
#' @param repel_predictor_variables
#' @return
#' @export
repel_scale_values_crop <- function(repel_training_data_select, 
                                    repel_predictor_variables) {
  
  # targets::tar_load(repel_training_data_select_crop)
  # repel_training_data_select <- repel_training_data_select_crop
  # 
  # targets::tar_load(repel_predictor_variables_crop)
  # repel_predictor_variables <- repel_predictor_variables_crop
  
  ## mean/sd for scaling predictions ----
  scaling_values <- repel_training_data_select |>
    dplyr::select(all_of(repel_predictor_variables), -c(continent, kingdom)) |>
    tidyr::gather() |>
    dplyr::group_by(key) |>
    dplyr::summarize(mean = mean(value), sd = sd(value)) |>
    dplyr::ungroup()
  
  ## scale ----
  repel_data_scaled <- repel_training_data_select |>
    network_recipe_crop(  
      repel_predictor_variables, 
      scaling_values, 
      include_time = TRUE
    ) # |>
  # dplyr::group_by_all() |>
  # dplyr::count() |>
  # dplyr::ungroup() |>
  # dplyr::select(
  #   country_iso3c, disease, count = n, outbreak_start, dplyr::everything(),
  # ) |>
  # dplyr::arrange(disease, desc(count), country_iso3c)
  
  # compressed this was 3486758 rows
  
  max_window <- stringr::str_split(max(repel_data_scaled$prediction_window), " to ")[[1]][[2]]
  
  ### binning and compress ----
  # here we split the continuous variables into 30 intervals based on the range of values
  # we assign the median as the value for each bin, to be used for fitting
  repel_data_binned <- repel_data_scaled |> 
    dplyr::select(-prediction_window) |>
    dplyr::group_by(country_iso3c, disease) |> 
    dplyr::mutate(tmp_id = dplyr::row_number()) |> 
    tidyr::pivot_longer(cols = -c(tmp_id, country_iso3c, continent, kingdom, disease, outbreak_start, shared_borders_from_outbreaks), names_to = "variable") |>
    dplyr::group_by(variable) |> 
    dplyr::mutate(bin = cut(value, 30)) |> # based on the range, not the quantiles
    dplyr::group_by(variable, bin) |> 
    dplyr::mutate(bin_median = median(as.numeric(stringr::str_extract_all(bin, "-?[0-9]+\\.?[0-9]*")[[1]]))) |> 
    dplyr::ungroup() |> 
    dplyr::select(-value, -bin) |> 
    tidyr::pivot_wider(id_cols = c(tmp_id, country_iso3c, continent, kingdom, disease, outbreak_start, shared_borders_from_outbreaks), names_from = variable, values_from = bin_median) |>
    dplyr::select(-tmp_id)
  
  assertthat::assert_that(nrow(repel_data_binned) == nrow(repel_data_scaled))
  
  repel_data_compressed <- repel_data_binned |> 
    dplyr::group_by_all() |>
    dplyr::count() |>
    dplyr::ungroup() |>
    dplyr::select(
      country_iso3c, disease, count = n, outbreak_start, dplyr::everything(),
    ) |>
    dplyr::arrange(disease, desc(count), country_iso3c)
  
  # reduced by ~50%
  # nrow(repel_data_compressed) # 1666678
  
  list(scaling_values, repel_data_compressed, max_window)
}
