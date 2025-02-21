#' New disease predictions
#'
#' This function makes predictions for five priority diseases that have no reports in the training dataset
#'
#' @return 
#'
#' @import dplyr
#' @importFrom countrycode countrycode
#' @importFrom lme4 ranef
#'
#' @examples
#'
#' @export
repel_predict_new_crop_diseases <- function(# priority_crop_disease_lookup, 
                                            connect_crop_outbreaks, 
                                            country_yearly_gdp, 
                                            country_yearly_human_population, 
                                            country_yearly_crop_production, 
                                            connect_static_shared_borders, 
                                            connect_static_wildlife_migration, 
                                            connect_yearly_fao_trade_crop, 
                                            connect_yearly_comtrade_crop, 
                                            repel_scaling_values_crop, 
                                            repel_model_crop) {
  
  # recreate connect_crop_outbreaks for new diseases ----
  
  ## start by modifying the priority disease distribution csv
  connect_crop_outbreaks_new_diseases <- readr::read_csv("data-raw/crop-disease-lookup/new_disease_distribution.csv") |>
    dplyr::select(disease, country) |>
    dplyr::mutate(country_iso3c = countrycode::countrycode(country, "country.name", "iso3c"))  |>
    dplyr::filter(country_iso3c != "USA") |>  # we are predicting FOR the US, so we don't need to track status
    dplyr::mutate(outbreak_start = FALSE, outbreak_ongoing = TRUE)
  
  ## now add in US for prediction purposes 
  connect_crop_outbreaks_new_diseases <- dplyr::bind_rows(connect_crop_outbreaks_new_diseases, 
                                                          connect_crop_outbreaks_new_diseases |> 
                                                            dplyr::distinct(disease) |> 
                                                            dplyr::mutate(country = "United States", country_iso3c = "USA", outbreak_start = FALSE, outbreak_ongoing = FALSE)
  )
  
  ## expand to include all prediction windows
  windows <- connect_crop_outbreaks |>
    dplyr::distinct(prediction_window, lag_prediction_window, lag_prediction_window_list)
  
  connect_crop_outbreaks_new_diseases <- tidyr::crossing(connect_crop_outbreaks_new_diseases, windows)
  
  # recreate augmented_crop_data_disaggregated for new diseases ----
  # extracted_data_processed_new_diseases <- readxl::read_xlsx(priority_crop_disease_lookup) |>
  #   dplyr::rename(disease = scientific_name)
  extracted_data_processed_new_diseases <- readxl::read_xlsx("data-raw/crop-disease-lookup/priority_crop_disease_lookup.xlsx") |>
    dplyr::rename(disease = scientific_name)
  
  augment_disagg <- augment_crop_data_disaggregated(connect_crop_outbreaks = connect_crop_outbreaks_new_diseases, 
                                                    extracted_data_processed = extracted_data_processed_new_diseases,
                                                    country_yearly_gdp, 
                                                    country_yearly_human_population, 
                                                    country_yearly_crop_production, 
                                                    connect_static_shared_borders, 
                                                    connect_static_wildlife_migration, 
                                                    connect_yearly_fao_trade_crop, 
                                                    connect_yearly_comtrade_crop) |>
    dplyr::filter(country_iso3c == "USA", prediction_window == max(prediction_window))
  
  augment_agg <- aggregate_augmented_crop_data(
    augment_disagg
  )
  
  # scale predictor variables and reshape with dummy vars ----
  predictor_vars <- repel_scaling_values_crop[[1]]$key
  
  augment_agg_scaled <- network_recipe_crop(
    augmented_data = augment_agg, 
    predictor_vars = predictor_vars, 
    scaling_values = repel_scaling_values_crop[[1]],
    include_time = TRUE
  )   |>
    dplyr::mutate(dummy = 1) |>
    tidyr::pivot_wider(names_from = kingdom, 
                       values_from = dummy, 
                       values_fill = 0, 
                       names_glue = "kingdom{kingdom}") |> 
    dplyr::mutate(dummy = 1) |>
    tidyr::pivot_wider(names_from = continent, 
                       values_from = dummy, 
                       values_fill = 0, 
                       names_glue = "continent{continent}")
  
  # get model coefficients and apply to values to generate predictions ----
  random_effects <- lme4::ranef(repel_model_crop)
  intercept <- summary(repel_model_crop)$coefficients[[1]]
  mean_coefficients <- purrr::map_dbl(random_effects$disease, mean)
  
  # m <- augment_agg_scaled |>
  #   dplyr::select(tidyselect::any_of(names(coef))) |>
  #   as.matrix()
  m <- augment_agg_scaled |>
    dplyr::select(tidyselect::any_of(names(mean_coefficients))) |>
    as.matrix()
  
  v <- mean_coefficients[names(mean_coefficients) %in% colnames(m)] 
  
  colnames(m) == names(v)
  
  prod <- sweep(m, 2, v, "*")
  log_odds <- apply(prod, 1, sum) + intercept
  predictions <- plogis(log_odds) # 1/(1+exp(-log_odds))
  
  predictions <- augment_agg |>
    dplyr::select(country_iso3c, prediction_window, disease) |>
    dplyr::mutate(predicted_outbreak_probability = predictions)
  
  return(predictions)
}
