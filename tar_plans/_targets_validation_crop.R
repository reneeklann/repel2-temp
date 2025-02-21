# Targets for crop model validation ----

## Crop model validation ----
validation_targets_crop <- tar_plan(
  
  ## Scale and compress validation data ----
  tar_target(
    name = repel_validation_data_scaled_crop,
    command = network_recipe_crop(
      augmented_data = repel_validation_data_crop,  
      predictor_vars = repel_predictor_variables_crop, 
      scaling_values = repel_scaling_values_crop[[1]],
      include_time = TRUE
    )
  ),
  
  ## Generate predictions on validation data ----
  tar_target(
    name = repel_validation_predict_crop,
    command = {
      p <- predict(repel_model_crop, repel_validation_data_scaled_crop, type = "response")
      repel_validation_data_scaled_crop |> dplyr::mutate(predicted = p)
    }
  ),

  ## Confusion matrix ----
  tar_target(
    name = repel_confusion_matrix_crop,
    command = generate_confusion_matrix(repel_validation_predict_crop)
  ),
  
  # Performance metrics
  tar_target(
    name = repel_performance_crop,
    command = yardstick:::summary.conf_mat(repel_confusion_matrix_crop)
  ),

  # Calibration curve
  # tar_target(
  #   name = repel_optimised_bins_crop,
  #   command = optimise_bins(repel_validation_predict_crop)
  # ),
  tar_target(
    name = repel_calibration_crop,
    command = generate_calibration(repel_validation_predict_crop, opt_bins = TRUE)
  ),
  tar_target(
    name = repel_calibration_plot_crop,
    command = plot_calibration(repel_calibration_crop)
  ),
  tar_target(
    name = repel_calibration_plot_crop_plus,
    command = plot_calibration(repel_calibration_crop, forecast_range = TRUE)
  ),
  tar_target(
    name = repel_calibration_table_crop,
    command = table_calibration(repel_calibration_crop)
  ),
  tar_target(
    name = repel_calibration_n_within_range_crop,
    command = sum(repel_calibration_table_crop$`Mean Prediction within 95%CI` == "yes")
  )
)
