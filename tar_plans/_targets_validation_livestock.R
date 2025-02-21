# Targets for livestock model validation ----

## Livestock model validation ----
validation_targets_livestock <- tar_plan(
  
  ## Scale and compress validation data ----
  tar_target(
    name = repel_validation_data_scaled,
    command = network_recipe(
      augmented_data = repel_validation_data,  
      predictor_vars = repel_predictor_variables, 
      scaling_values = repel_scaling_values[[1]],
      include_time = TRUE
    ), 
    cue = tar_cue(tar_cue_setting)
  ),
  
  ## Generate predictions on validation data ----
  tar_target(
    name = repel_validation_predict,
    cue = tar_cue(tar_cue_setting),
    command = {
      p <- predict(repel_model, repel_validation_data_scaled, type = "response")
      repel_validation_data_scaled |> dplyr::mutate(predicted = p)
    }
  ),
  
  ## Confusion matrix ----
  tar_target(
    name = repel_confusion_matrix,
    command = generate_confusion_matrix(repel_validation_predict),
    cue = tar_cue(tar_cue_setting)
  ),
  
  # Performance metrics
  tar_target(
    name = repel_performance,
    command = yardstick:::summary.conf_mat(repel_confusion_matrix),
    cue = tar_cue(tar_cue_setting)
  ),
  
  # Calibration curve
  # tar_target(
  #   name = repel_optimised_bins,
  #   command = optimise_bins(repel_validation_predict),
  #   cue = tar_cue(tar_cue_setting)
  # ),
  tar_target(
    name = repel_calibration,
    command = generate_calibration(repel_validation_predict, opt_bins = TRUE),
    cue = tar_cue(tar_cue_setting)
  ),
  tar_target(
    name = repel_calibration_plot,
    command = plot_calibration(repel_calibration),
    cue = tar_cue(tar_cue_setting)
  ),
  # tar_target(
  #   name = repel_calibration_plot_plus,
  #   command = plot_calibration(repel_calibration, forecast_range = TRUE),
  #   cue = tar_cue(tar_cue_setting)
  # ),
  tar_target(
    name = repel_calibration_table,
    command = table_calibration(repel_calibration),
    cue = tar_cue(tar_cue_setting)
  ),
  tar_target(
    name = repel_calibration_n_within_range,
    command = sum(repel_calibration_table$`Mean Prediction within 95%CI` == "yes"),
    cue = tar_cue(tar_cue_setting)
  )
)
