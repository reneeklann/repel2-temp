
network_recipe <- function(augmented_data,
                           predictor_vars,
                           scaling_values,
                           include_time = FALSE) {
  
  ## remove continent (factor) for scaling purposes ----
  predictor_vars <- predictor_vars[!predictor_vars %in% c("continent", "disease_present_anywhere", "outbreak_previous")] 
  
  ## check that predictor_vars are found in scaling_values keys ----
  assertthat::assert_that(all(sort(scaling_values$key) == sort(predictor_vars)))

  ## create prescale_augmented_data ----
  prescale_augmented_data <- augmented_data |>
    dplyr::select(
      country_iso3c,
      suppressWarnings(dplyr::one_of("continent")),
      disease_present_anywhere,
      outbreak_previous,
      disease,
      suppressWarnings(dplyr::one_of("outbreak_start")), # needed for model fitting but not prediction
      prediction_window, # needed for results interpretation but not fitting
      !!predictor_vars
    ) |>
    dplyr::mutate(country_iso3c = as.factor(country_iso3c)) |>
    dplyr::mutate(disease = as.factor(disease))
  
  if (!include_time){
    prescale_augmented_data <- dplyr::select(prescale_augmented_data, -prediction_window)
  }
  
  ## scale augmented data ----
  scaled_augmented_data <- prescale_augmented_data |>
    dplyr::mutate(unique_id = row_number()) |> # in case there are duplicates (e.g., in bootstrap validation)
    tidyr::pivot_longer(cols = dplyr::all_of(predictor_vars)) |>
    dplyr::left_join(scaling_values, by = c("name" = "key")) |>
    dplyr::mutate(value = (value - `mean`) / `sd`) |>
    dplyr::select(-mean, -sd) |>
    tidyr::pivot_wider(names_from = "name", values_from = "value") |>
    dplyr::select(-unique_id)
  
  scaled_augmented_data
}



network_recipe_crop <- function(augmented_data,
                                predictor_vars,
                                scaling_values,
                                include_time = FALSE) {
  
  ## remove continent and kingdom (factor) for scaling purposes ----
  predictor_vars <- predictor_vars[!predictor_vars %in% c("continent", "kingdom")]
  
  ## check that predictor_vars are found in scaling_values keys ----
  assertthat::assert_that(all(sort(scaling_values$key) == sort(predictor_vars)))
  
  ## create prescale_augmented_data ----
  prescale_augmented_data <- augmented_data |>
    dplyr::select(
      country_iso3c,
      suppressWarnings(dplyr::one_of("continent")),
      suppressWarnings(dplyr::one_of("kingdom")),
      disease,
      suppressWarnings(dplyr::one_of("outbreak_start")), # needed for model fitting but not prediction
      prediction_window, # needed for results interpretation but not fitting
      !!predictor_vars
    ) |>
    dplyr::mutate(country_iso3c = as.factor(country_iso3c)) |>
    dplyr::mutate(disease = as.factor(disease))
  
  if (!include_time){
    prescale_augmented_data <- dplyr::select(prescale_augmented_data, -prediction_window)
  }
  
  ## scale augmented data ----
  scaled_augmented_data <- prescale_augmented_data |>
    dplyr::mutate(unique_id = dplyr::row_number()) |> # in case there are duplicates (e.g., in bootstrap validation)
    tidyr::pivot_longer(cols = dplyr::all_of(predictor_vars)) |>
    dplyr::left_join(scaling_values, by = c("name" = "key")) |>
    dplyr::mutate(value = (value - `mean`) / `sd`) |>
    dplyr::select(-mean, -sd) |>
    tidyr::pivot_wider(names_from = "name", values_from = "value") |>
    dplyr::select(-unique_id)
  
  scaled_augmented_data
}
