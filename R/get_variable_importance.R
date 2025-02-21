#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param repel_model
#' @param repel_augmented_data_disagreggated
#' @return
#' @export
get_variable_importance <- function(repel_predictions,
                                    repel_model,
                                    repel_augmented_data_disagreggated,
                                    repel_scaling_values) {
  
  # In our training pipeline, we do the prepvar() log10 transform post-aggregation
  # Here we are dealing with the disagreggated data for variable importance, which is pre-transformed
  # So we can apply prepvar() log10 transform to get the data on the same scale as the model
  repel_augmented_data_disagreggated_transformed <- repel_augmented_data_disagreggated |> 
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
  
  
  # Add REPEL predictions to disaggregated data
  disagreggated_predict <- repel_predictions |> 
    dplyr::select(country_iso3c, prediction_window, disease, predicted_outbreak_probability, actual_outbreak_start) |> 
    dplyr::left_join(repel_augmented_data_disagreggated_transformed, by = dplyr::join_by(country_iso3c, prediction_window, disease)) |> 
    dplyr::select(-endemic, -outbreak_ongoing)
  
  # Reshape long
  disagreggated_predict_long <- disagreggated_predict |> 
    dplyr::rename(country_origin_iso3c =  country_origin) |>
    tidyr::pivot_wider(names_from = continent, values_from = continent, names_prefix = "continent") |>
    tidyr::pivot_wider(names_from = outbreak_previous, values_from = outbreak_previous, names_prefix = "outbreak_previous") |> 
    tidyr::pivot_wider(names_from = disease_present_anywhere, values_from = disease_present_anywhere, names_prefix = "disease_present_anywhere") |> 
    dplyr::mutate_at(vars(starts_with("continent"), starts_with("outbreak_previous"), starts_with("disease_present_anywhere")), ~ifelse(is.na(.), 0, 1)) |>
    tidyr::pivot_longer(cols = -c("country_iso3c", "country_origin_iso3c", "disease", "prediction_window", "actual_outbreak_start", "predicted_outbreak_probability"),
                        names_to = "variable", values_to = "x") |>
    dplyr::filter(str_detect(variable, "from_outbreaks"))
  
  # Get model coeffs
  randef_disease <- lme4::ranef(repel_model) |>
    (\(x) x[[1]])() |>
    (\(x) data.frame(disease = row.names(x), x))() |>
    (\(x) { row.names(x) <- NULL; x })() |>
    tidyr::pivot_longer(cols = -disease) |>
    dplyr::mutate(
      variable_clean = stringr::str_remove_all(name, pattern = "continent") |>
        stringr::str_replace_all(pattern = "\\_", replacement = " ")
    ) |>
    dplyr::rename(variable = name, coef = value)
  
  network_scaling_values <- repel_scaling_values[[1]] |> 
    dplyr::rename(variable = key)
  
  # Join together augment and coeffs, calc variable importance
  vi_co <- disagreggated_predict_long |>
    dplyr::left_join(randef_disease, by = c("disease", "variable")) |>
    dplyr::left_join(network_scaling_values, by = "variable") |>
    dplyr::group_by(across(c(country_iso3c, disease, prediction_window, variable))) |>
    dplyr::mutate(sum_x_standardized = (sum(x, na.rm = TRUE) - `mean`) / `sd`,
                  sum_x = sum(x, na.rm = TRUE)) |>
    dplyr::ungroup() |>
    dplyr::mutate(overall_variable_importance = sum_x_standardized * coef) |>  # this is on the aggregated scale - eg comtrade_dollars_from_outbreaks, scaled, times the model coefficient for the disease and variable 
    dplyr::mutate(disagg_variable_importance = (overall_variable_importance/sum_x)*x) |> # this breaks down the relative contribution of each country of origin. the sum of disagg_variable_importance = overall_variable_importance
    dplyr::mutate(pos = disagg_variable_importance > 0)
  
  vi <- vi_co |> 
    dplyr::distinct(across(c(country_iso3c, disease, prediction_window, variable, overall_variable_importance)))
  
  vi_by_origin <- vi_co |>
    tidyr::drop_na(disagg_variable_importance) |>
    dplyr::mutate(country_origin = countrycode::countrycode(country_origin_iso3c, origin = "iso3c", destination = "country.name")) |> 
    dplyr::group_by(across(c(prediction_window, disease,
                    country_iso3c, country_origin_iso3c, country_origin, variable))) |>
    dplyr::summarize(contribution_to_import_risk = sum(disagg_variable_importance, na.rm = TRUE)) |>
    dplyr::ungroup() |>
    dplyr::arrange(country_iso3c, prediction_window, disease, -contribution_to_import_risk)
  
  return(list("variable_importance" = vi, "variable_importance_by_origin" = vi_by_origin))
  
}



#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param repel_model
#' @param repel_augmented_data_disagreggated
#' @return
#' @export
get_variable_importance_crop <- function(repel_predictions,
                                         repel_model,
                                         repel_augmented_data_disagreggated,
                                         repel_scaling_values) {
  
  # targets::tar_load(repel_predictions_priority_diseases_usa_crop)
  # repel_predictions <- repel_predictions_priority_diseases_usa_crop
  # 
  # targets::tar_load(repel_model_crop)
  # repel_model <- repel_model_crop
  # 
  # targets::tar_load(augmented_crop_data_disaggregated_for_prediction)
  # repel_augmented_data_disagreggated <- augmented_crop_data_disaggregated_for_prediction
  # 
  # targets::tar_load(repel_scaling_values_crop)
  # repel_scaling_values <- repel_scaling_values_crop
  
  # Add REPEL predictions to disaggregated data
  disagreggated_predict <- dplyr::left_join(repel_predictions, repel_augmented_data_disagreggated, by = dplyr::join_by(country_iso3c, prediction_window, disease)) |> 
    dplyr::select(-"outbreak_ongoing", -"disease_present_anywhere") # -"endemic"
  
  # Reshape long
  disagreggated_predict_long <- disagreggated_predict |>
    dplyr::rename(country_origin_iso3c = country_origin) |>
    tidyr::pivot_wider(names_from = continent, values_from = continent, names_prefix = "continent") |>
    dplyr::mutate_at(dplyr::vars(starts_with("continent")), ~ifelse(!is.na(.), 1, NA)) |>
    tidyr::pivot_longer(cols = -c("country_iso3c", "country_origin_iso3c", "disease", "kingdom", "prediction_window", "actual_outbreak_start", "predicted_outbreak_probability"),
                        names_to = "variable", values_to = "x") |>
    dplyr::filter(stringr::str_detect(variable, "from_outbreaks"))
  
  # Get model coeffs - not working yet
  randef_disease <- lme4::ranef(repel_model) |>
    (\(x) x[[1]])() |>
    (\(x) data.frame(disease = row.names(x), x))() |>
    (\(x) { row.names(x) <- NULL; x })() |>
    tidyr::pivot_longer(cols = continentAfrica:log_human_population) |> # ??
    dplyr::mutate(
      variable_clean = stringr::str_remove_all(name, pattern = "continent") |>
        stringr::str_replace_all(pattern = "\\_", replacement = " ")
    ) |>
    dplyr::rename(variable = name, coef = value)
  
  network_scaling_values <- repel_scaling_values[[1]] |> 
    dplyr::rename(variable = key)
  
  # Join together augment and coeffs, calc variable importance
  vi_co <- disagreggated_predict_long |>
    dplyr::left_join(randef_disease, by = c("disease", "variable")) |>
    dplyr::left_join(network_scaling_values, by = "variable") |>
    dplyr::group_by(across(c(country_iso3c, disease, prediction_window, variable))) |>
    dplyr::mutate(sum_x_standardized = (sum(x, na.rm = TRUE) - `mean`) / `sd`,
                  sum_x = sum(x, na.rm = TRUE)) |>
    dplyr::ungroup() |>
    dplyr::mutate(overall_variable_importance = sum_x_standardized * coef) |>  # this is on the aggregated scale - eg comtrade_dollars_from_outbreaks, scaled, times the model coefficient for the disease and variable 
    dplyr::mutate(disagg_variable_importance = (overall_variable_importance/sum_x)*x) |> # this breaks down the relative contribution of each country of origin. the sum of disagg_variable_importance = overall_variable_importance
    dplyr::mutate(pos = disagg_variable_importance > 0)
  
  vi <- vi_co |> 
    dplyr::distinct(across(c(country_iso3c, disease, prediction_window, variable, overall_variable_importance)))
  
  vi_by_origin <- vi_co |>
    tidyr::drop_na(disagg_variable_importance) |>
    dplyr::mutate(country_origin = countrycode::countrycode(country_origin_iso3c, origin = "iso3c", destination = "country.name")) |> 
    dplyr::group_by(across(c(prediction_window, disease,
                             country_iso3c, country_origin_iso3c, country_origin, variable))) |>
    dplyr::summarize(contribution_to_import_risk = sum(disagg_variable_importance, na.rm = TRUE)) |>
    dplyr::ungroup() |>
    dplyr::arrange(country_iso3c, prediction_window, disease, -contribution_to_import_risk)
  
  return(list("variable_importance" = vi, "variable_importance_by_origin" = vi_by_origin))
  
}



#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param repel_model
#' @param repel_augmented_data_disagreggated
#' @return
#' @export
get_variable_importance_crop <- function(repel_predictions,
                                         repel_model,
                                         repel_augmented_data_disagreggated,
                                         repel_scaling_values) {
  
  # targets::tar_load(repel_predictions_priority_diseases_usa_crop)
  # repel_predictions <- repel_predictions_priority_diseases_usa_crop
  # 
  # targets::tar_load(repel_model_crop)
  # repel_model <- repel_model_crop
  # 
  # targets::tar_load(augmented_crop_data_disaggregated_for_prediction)
  # repel_augmented_data_disagreggated <- augmented_crop_data_disaggregated_for_prediction
  # 
  # targets::tar_load(repel_scaling_values_crop)
  # repel_scaling_values <- repel_scaling_values_crop
  
  # In our training pipeline, we do the prepvar() log10 transform post-aggregation
  # Here we are dealing with the disagreggated data for variable importance, which is pre-transformed
  # So we can apply prepvar() log10 transform to get the data on the same scale as the model
  repel_augmented_data_disagreggated_transformed <- repel_augmented_data_disagreggated |> 
    dplyr::mutate(
      log_fao_crop_quantity_from_outbreaks = prepvar(
        fao_crop_quantity_from_outbreaks + 1, 
        trans_fn = log10),
      log_comtrade_dollars_from_outbreaks = prepvar(
        comtrade_dollars_from_outbreaks + 1, 
        trans_fn = log10),
      log_n_migratory_wildlife_from_outbreaks = prepvar(
        n_migratory_wildlife_from_outbreaks + 1, 
        trans_fn = log10),
    ) |>
    dplyr::select(-fao_crop_quantity_from_outbreaks, -comtrade_dollars_from_outbreaks, -n_migratory_wildlife_from_outbreaks)
  
  # # Add REPEL predictions to disaggregated data
  # disagreggated_predict <- dplyr::left_join(repel_predictions, repel_augmented_data_disagreggated, by = dplyr::join_by(country_iso3c, prediction_window, disease)) |> 
  #   dplyr::select(-"outbreak_ongoing", -"disease_present_anywhere") # -"endemic"
  
  # Add REPEL predictions to disaggregated data
  disagreggated_predict <- repel_predictions |>
    dplyr::select(country_iso3c, prediction_window, disease, predicted_outbreak_probability, actual_outbreak_start) |>
    dplyr::left_join(repel_augmented_data_disagreggated_transformed, by = dplyr::join_by(country_iso3c, prediction_window, disease)) |>
    dplyr::select(-outbreak_ongoing) # -endemic
  
  # Reshape long
  disagreggated_predict_long <- disagreggated_predict |>
    dplyr::rename(country_origin_iso3c = country_origin) |>
    tidyr::pivot_wider(names_from = continent, values_from = continent, names_prefix = "continent") |>
    tidyr::pivot_wider(names_from = disease_present_anywhere, values_from = disease_present_anywhere, names_prefix = "disease_present_anywhere") |>
    # dplyr::mutate_at(dplyr::vars(starts_with("continent")), ~ifelse(!is.na(.), 1, NA)) |>
    dplyr::mutate_at(dplyr::vars(starts_with("continent"), starts_with("disease_present_anywhere")), ~ifelse(is.na(.), 0, 1)) |> 
    tidyr::pivot_longer(cols = -c("country_iso3c", "country_origin_iso3c", "disease", "kingdom", "prediction_window", "actual_outbreak_start", "predicted_outbreak_probability"),
                        names_to = "variable", values_to = "x") |>
    dplyr::filter(stringr::str_detect(variable, "from_outbreaks"))
  
  # Get model coeffs
  randef_disease <- lme4::ranef(repel_model) |>
    (\(x) x[[1]])() |>
    (\(x) data.frame(disease = row.names(x), x))() |>
    (\(x) { row.names(x) <- NULL; x })() |>
    tidyr::pivot_longer(cols = -disease) |>
    dplyr::mutate(
      variable_clean = stringr::str_remove_all(name, pattern = "continent") |>
        stringr::str_replace_all(pattern = "\\_", replacement = " ")
    ) |>
    dplyr::rename(variable = name, coef = value)
  
  network_scaling_values <- repel_scaling_values[[1]] |> 
    dplyr::rename(variable = key)
  
  # Join together augment and coeffs, calc variable importance
  vi_co <- disagreggated_predict_long |>
    dplyr::left_join(randef_disease, by = c("disease", "variable")) |>
    dplyr::left_join(network_scaling_values, by = "variable") |>
    dplyr::group_by(across(c(country_iso3c, disease, prediction_window, variable))) |>
    dplyr::mutate(sum_x_standardized = (sum(x, na.rm = TRUE) - `mean`) / `sd`,
                  sum_x = sum(x, na.rm = TRUE)) |>
    dplyr::ungroup() |>
    dplyr::mutate(overall_variable_importance = sum_x_standardized * coef) |>  # this is on the aggregated scale - eg comtrade_dollars_from_outbreaks, scaled, times the model coefficient for the disease and variable 
    dplyr::mutate(disagg_variable_importance = (overall_variable_importance/sum_x)*x) |> # this breaks down the relative contribution of each country of origin. the sum of disagg_variable_importance = overall_variable_importance
    dplyr::mutate(pos = disagg_variable_importance > 0)
  
  vi <- vi_co |> 
    dplyr::distinct(across(c(country_iso3c, disease, prediction_window, variable, overall_variable_importance)))
  
  vi_by_origin <- vi_co |>
    tidyr::drop_na(disagg_variable_importance) |>
    dplyr::mutate(country_origin = countrycode::countrycode(country_origin_iso3c, origin = "iso3c", destination = "country.name")) |> 
    dplyr::group_by(across(c(prediction_window, disease,
                             country_iso3c, country_origin_iso3c, country_origin, variable))) |>
    dplyr::summarize(contribution_to_import_risk = sum(disagg_variable_importance, na.rm = TRUE)) |>
    dplyr::ungroup() |>
    dplyr::arrange(country_iso3c, prediction_window, disease, -contribution_to_import_risk)
  
  return(list("variable_importance" = vi, "variable_importance_by_origin" = vi_by_origin))
  
}
