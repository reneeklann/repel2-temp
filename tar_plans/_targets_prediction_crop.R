# Targets for crop model prediction ----

## Crop model prediction ----
prediction_targets_crop <- tar_plan(
  
  tar_target(
    name = repel_prediction_date_crop,
    command = check_prediction_date(
      predict_from = crop_model_last_data_update,
      max_training_date = crop_model_max_training_date,
      last_data_update = crop_model_last_data_update,
      time_scale = crop_model_time_scale
    )
  ),
  
  tar_target(
    name = connect_crop_outbreaks_for_prediction,
    command = process_crop_outbreaks(
      extracted_data_processed,
      max_date = repel_prediction_date_crop,
      time_scale = crop_model_time_scale,
      training = FALSE,
      repel_model_crop # to enforce dependency
    )
  ),
  
  tar_target(
    name = augmented_crop_data_disaggregated_for_prediction,
    command = augment_crop_data_disaggregated(
      connect_crop_outbreaks = connect_crop_outbreaks_for_prediction,
      extracted_data_processed,
      country_yearly_gdp,
      country_yearly_human_population,
      country_yearly_crop_production,
      connect_static_shared_borders,
      connect_static_wildlife_migration,
      connect_yearly_fao_trade_crop,
      connect_yearly_comtrade_crop
      # connect_yearly_comtrade_crop_file
    )
  ),
  
  tar_target(
    name = augmented_crop_data_aggregated_for_prediction,
    command =  aggregate_augmented_crop_data(
      augmented_crop_data_disaggregated = augmented_crop_data_disaggregated_for_prediction
    ),
  ),
  
  tar_target(
    name = repel_training_counts_crop,
    command = repel_training_data_select_crop |> 
      dplyr::group_by(country_iso3c, disease) |> dplyr::count() |> dplyr::ungroup()
  ),
  
  tar_target(
    name = repel_predictions_crop,
    command = repel_predict_crop(
      repel_model = repel_model_crop,
      repel_scaling_values = repel_scaling_values_crop,
      augmented_data_aggregated_for_prediction = augmented_crop_data_aggregated_for_prediction,
      repel_training_counts = repel_training_counts_crop
    )
  ),
  
  tar_target(
    name = repel_predictions_priority_diseases_usa_crop,
    command = repel_predictions_crop |>
      filter(
        country_iso3c == "USA",
        # use priority disease target once created instead of hardcoding this
        disease %in% c(
          "'Candidatus Liberibacter asiaticus'",
          "'Candidatus Liberibacter solanacearum'",
          "'Candidatus Phytoplasma solani'",
          "Clavibacter nebraskensis", # no reports in full dataset
          "Coniothyrium glycines", # no reports in full dataset
          "Cotton leaf curl virus",
          "Cowpea mild mottle virus",
          "Globodera pallida",
          "Globodera rostochiensis",
          "Groundnut rosette virus", # no reports in full dataset
          "Pyricularia oryzae",
          "Pyricularia oryzae Triticum pathotype",
          "Oxycarenus hyalinipennis",
          "Pantoea stewartii",
          "Peronosclerospora maydis", # no reports in full dataset
          "Phakopsora pachyrhizi",
          "Plum pox virus",
          "Puccinia graminis f. sp. tritici",
          "Ralstonia solanacearum",
          "Ralstonia solanacearum race 3 biovar 2",
          "Synchytrium endobioticum",
          "Thecaphora frezii", # no reports in full dataset
          "Tomato yellow leaf curl virus",
          "Xanthomonas citri pv. malvacearum",
          "Xanthomonas oryzae pv. oryzicola",
          "Xylella fastidiosa",
          "Xylella fastidiosa subsp. fastidiosa",
          "Xylella fastidiosa subsp. multiplex",
          "Xylella fastidiosa subsp. pauca"
        )
      )
  ),
  
  tar_target(
    name = repel_predictions_crop_new_diseases,
    command = repel_predict_new_crop_diseases(# priority_crop_disease_lookup, 
                                              connect_crop_outbreaks, 
                                              country_yearly_gdp, 
                                              country_yearly_human_population, 
                                              country_yearly_crop_production, 
                                              connect_static_shared_borders, 
                                              connect_static_wildlife_migration, 
                                              connect_yearly_fao_trade_crop, 
                                              connect_yearly_comtrade_crop = connect_yearly_comtrade_crop_file, 
                                              repel_scaling_values_crop, 
                                              repel_model_crop)
  ),
  
  # variable_importance is the importance of each bilateral predictor variable for each month-country-disease prediction.
  # variable_importance_by_origin disagreggates the variable importance by outbreak origin countries.
  tar_target(
    name = repel_variable_importance_priority_diseases_usa_crop,
    command = get_variable_importance_crop(
      repel_predictions = repel_predictions_priority_diseases_usa_crop,
      repel_model = repel_model_crop,
      repel_augmented_data_disagreggated = augmented_crop_data_disaggregated_for_prediction,
      repel_scaling_values = repel_scaling_values_crop
    )
  ),
  
  tar_target(
    name = repel_variable_importance_priority_diseases_usa_crop_plot,
    command = plot_variable_importance(
      repel_variable_importance_priority_diseases_usa = repel_variable_importance_priority_diseases_usa_crop
    )
  ),
  
  tar_target(
    name = repel_full_crop_pipeline,
    command = pipeline_endpoints(repel_crop_model_updates_report, repel_variable_importance_priority_diseases_usa_crop_plot, repel_predictions_crop_new_diseases)
  )
)
