# Targets for livestock model prediction ----

## Livestock model prediction ----
prediction_targets_livestock <- tar_plan(
  
  tar_target(
    name = repel_prediction_date_livestock,
    command = check_prediction_date(
      predict_from = livestock_model_last_data_update,
      max_training_date = livestock_model_max_training_date,
      last_data_update = livestock_model_last_data_update,
      time_scale = livestock_model_time_scale
    )
  ),
  
  tar_target(
    name = connect_livestock_outbreaks_for_prediction,
    command = process_wahis_outbreaks(
      wahis_epi_events_downloaded,
      wahis_outbreaks_downloaded,
      nowcast = NULL,
      max_date = repel_prediction_date_livestock,
      time_scale = livestock_model_time_scale,
      wahis_epi_events_data_check,
      wahis_outbreaks_data_check,
      training = FALSE,
      repel_model # to enforce dependency
    )
  ),
  
  tar_target(
    name = augmented_livestock_data_disaggregated_for_prediction,
    command = augment_livestock_data_disaggregated(
      connect_livestock_outbreaks_for_prediction,
      country_yearly_gdp,
      country_yearly_human_population,
      country_yearly_taxa_population,
      country_yearly_vet_population,
      connect_static_shared_borders,
      connect_static_wildlife_migration,
      connect_yearly_fao_trade_livestock,
      connect_yearly_comtrade_livestock,
      time_scale = livestock_model_time_scale
    )
  ),
  
  tar_target(
    name = augmented_livestock_data_aggregated_for_prediction,
    command =  aggregate_augmented_livestock_data(augmented_livestock_data_disaggregated_for_prediction), 
  ),
  
  tar_target(
    name = repel_training_counts,
    command = repel_training_data_select |> dplyr::group_by(country_iso3c, disease) |> dplyr::count() |> dplyr::ungroup()
  ),
  
  tar_target(
    name = repel_predictions,
    command = repel_predict(
      repel_model,
      repel_scaling_values, 
      augmented_livestock_data_aggregated_for_prediction,
      repel_training_counts
    )
  ),

  tar_target(
    name = repel_predictions_priority_diseases_usa,
    command = repel_predictions |> 
      filter(disease %in% c("african swine fever", 
                            "anthrax",
                            "classical swine fever",
                            "foot-and-mouth disease",
                            "highly pathogenic avian influenza",
                            "newcastle disease",
                            "rift valley fever"),
             country_iso3c == "USA")
  ),
  
  # variable_importance is the importance of each bilateral predictor variable for each month-country-disease prediction. 
  # variable_importance_by_origin disagreggates the variable importance by outbreak origin countries.
  tar_target(
    name = repel_variable_importance_priority_diseases_usa,
    command = get_variable_importance(
      repel_predictions = repel_predictions_priority_diseases_usa,
      repel_model = repel_model,
      repel_augmented_data_disagreggated = augmented_livestock_data_disaggregated_for_prediction,
      repel_scaling_values = repel_scaling_values
    )
  ),
  tar_target(
    name = repel_variable_importance_priority_diseases_usa_plot,
    command = plot_variable_importance(
      repel_variable_importance_priority_diseases_usa
    )
  ),
  
  tar_target(
    name = repel_full_pipeline,
    command = pipeline_endpoints(repel_model_updates_report, repel_variable_importance_priority_diseases_usa_plot)
  )
)
