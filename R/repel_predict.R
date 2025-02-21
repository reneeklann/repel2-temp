#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param lme_mod_network
#' @param repel_scaling_values
#' @param repel_validation_data
#' @param diseases
#' @param country
#' @param time_scale
#' @return
#' @export
repel_predict <- function(repel_model,
                          repel_scaling_values,
                          augmented_data_aggregated_for_prediction,
                          repel_training_counts
) {
  
  ## Get scaling values ----
  network_scaling_values <- repel_scaling_values[[1]]
  
  ## Get predictor variables ----
  predictor_vars <- repel_scaling_values[[1]]$key
  
  ## Transform repel_augmented_data with scaling values ----
  newdata_scaled <- network_recipe(
    augmented_data = augmented_data_aggregated_for_prediction, 
    predictor_vars = predictor_vars, 
    scaling_values = network_scaling_values,
    include_time = TRUE
  )
  
  newdata_scaled <- newdata_scaled |> 
    dplyr::mutate(row_number = dplyr::row_number())
  
  ## Warning about complete cases ----
  unknown_diseases <- levels(newdata_scaled$disease)[!levels(newdata_scaled$disease) %in%  levels(repel_model@frame$disease)]
  if(length(unknown_diseases)){
    newdata_scaled <- newdata_scaled |> 
      dplyr::filter(!disease %in% unknown_diseases) |>
      droplevels()
    warning(paste(paste(unknown_diseases, collapse = ", "), "unrecognized by the model. Removing from the dataset."))
  }
  
  ## run predictions ----
  augment_predict <-  newdata_scaled |> 
    dplyr::mutate(predicted_outbreak_probability = predict(repel_model, newdata_scaled, type = "response")) |>
    dplyr::arrange(row_number)
  
  ## structure outputs ----
  augment_predict_out <- augment_predict |> 
    dplyr::select(country_iso3c, prediction_window, disease, predicted_outbreak_probability) |> # TODO need NA if includes future
    dplyr::arrange(country_iso3c, prediction_window, disease)
  
  ## pull in actual status ----
  actual_status <- augmented_data_aggregated_for_prediction |> 
    dplyr::select(country_iso3c, disease, prediction_window,
                  actual_outbreak_start = outbreak_start, 
                  actual_outbreak_ongoing = outbreak_ongoing, 
                  actual_endemic = endemic)
  
  augment_predict_out <- dplyr::left_join(augment_predict_out, actual_status, by = dplyr::join_by(country_iso3c, prediction_window, disease))
  
  ## calculate binomial CIs ----
  binomial_cis <- dplyr::left_join(augment_predict_out,
                                   repel_training_counts,
                                   by = dplyr::join_by(country_iso3c, disease)) |>
    tidyr::drop_na(c(n, predicted_outbreak_probability)) |>
    dplyr::distinct(country_iso3c, prediction_window, disease, predicted_outbreak_probability, n) |> 
    dplyr::mutate(binom_ci = binom::binom.confint(x = predicted_outbreak_probability * n,
                                                  n = n,
                                                  methods = "wilson")) |> 
    dplyr::select(-predicted_outbreak_probability, -n) |> 
    (\(x) unnest(x, binom_ci))()
  
  augment_predict_out <- dplyr::left_join(augment_predict_out, binomial_cis, by = dplyr::join_by(country_iso3c, prediction_window, disease))
  
  assertthat::assert_that(!any(is.na(augment_predict_out$predicted_outbreak_probability)))
  
  return(augment_predict_out)
}



#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param lme_mod_network
#' @param repel_scaling_values
#' @param repel_validation_data
#' @param diseases
#' @param country
#' @param time_scale
#' @return
#' @export
repel_predict_crop <- function(repel_model,
                               repel_scaling_values,
                               augmented_data_aggregated_for_prediction,
                               repel_training_counts
                               ) {

  
  # targets::tar_load(repel_model_crop)
  # repel_model <- repel_model_crop
  # 
  # targets::tar_load(repel_scaling_values_crop)
  # repel_scaling_values <- repel_scaling_values_crop
  # 
  # targets::tar_load(augmented_crop_data_aggregated_for_prediction)
  # augmented_data_aggregated_for_prediction <- augmented_crop_data_aggregated_for_prediction
  # 
  # targets::tar_load(repel_training_counts_crop)
  # repel_training_counts <- repel_training_counts_crop
  
  ## Get scaling values ----
  network_scaling_values <- repel_scaling_values[[1]]
  
  ## Get predictor variables ----
  predictor_vars <- repel_scaling_values[[1]]$key
  
  ## Transform repel_augmented_data with scaling values ----
  newdata_scaled <- network_recipe_crop(
    augmented_data = augmented_data_aggregated_for_prediction, 
    predictor_vars = predictor_vars, 
    scaling_values = network_scaling_values,
    include_time = TRUE
  )
  
  newdata_scaled <- newdata_scaled |> 
    dplyr::mutate(row_number = dplyr::row_number())
  
  ## Warning about complete cases ----
  unknown_diseases <- levels(newdata_scaled$disease)[!levels(newdata_scaled$disease) %in%  levels(repel_model@frame$disease)]
  if(length(unknown_diseases)){
    newdata_scaled <- newdata_scaled |> 
      dplyr::filter(!disease %in% unknown_diseases) |>
      droplevels()
    warning(paste(paste(unknown_diseases, collapse = ", "), "unrecognized by the model. Removing from the dataset."))
  }
  
  ## Run predictions ----
  augment_predict <-  newdata_scaled |> 
    dplyr::mutate(predicted_outbreak_probability = predict(repel_model, newdata_scaled, type = "response")) |>
    dplyr::arrange(row_number)
  
  ## Structure outputs ----
  augment_predict_out <- augment_predict |> 
    dplyr::select(country_iso3c, prediction_window, disease, predicted_outbreak_probability) |>
    dplyr::arrange(country_iso3c, prediction_window, disease)
  
  ## Pull in actual status ----
  actual_status <- augmented_data_aggregated_for_prediction |> 
    dplyr::select(country_iso3c, disease, prediction_window,
                  actual_outbreak_start = outbreak_start, 
                  actual_outbreak_ongoing = outbreak_ongoing)
  # actual_endemic = endemic)
  
  augment_predict_out <- dplyr::left_join(augment_predict_out, actual_status, by = dplyr::join_by(country_iso3c, prediction_window, disease))
  
  ## Calculate binomial CIs ----
  binomial_cis <- dplyr::left_join(augment_predict_out,
                                   repel_training_counts,
                                   by = dplyr::join_by(country_iso3c, disease)) |>
    tidyr::drop_na(c(n, predicted_outbreak_probability)) |>
    dplyr::distinct(country_iso3c, prediction_window, disease, predicted_outbreak_probability, n) |> 
    dplyr::mutate(binom_ci = binom::binom.confint(x = predicted_outbreak_probability * n,
                                                  n = n,
                                                  methods = "wilson")) |> 
    dplyr::select(-predicted_outbreak_probability, -n) |> 
    (\(x) unnest(x, binom_ci))()
  
  augment_predict_out <- dplyr::left_join(augment_predict_out, binomial_cis, by = dplyr::join_by(country_iso3c, prediction_window, disease))
  
  assertthat::assert_that(!any(is.na(augment_predict_out$predicted_outbreak_probability)))
  
  return(augment_predict_out)
}
