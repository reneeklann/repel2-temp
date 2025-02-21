# Targets for crop model validation ----

## Crop model validation ----
validation_targets_crop <- tar_plan(
  
  ## Scale and compress validation data ----
  tar_target(
    name = repel_validation_data_scaled_crop,
    command = download_github_cache(object_name = "repel_validation_data_scaled_crop")
  ),
  
  ## Generate predictions on validation data ----
  tar_target(
    name = repel_validation_predict_crop,
    command = download_github_cache(object_name = "repel_validation_predict_crop")
  ),

  ## Confusion matrix ----
  tar_target(
    name = repel_confusion_matrix_crop,
    command = download_github_cache(object_name = "repel_confusion_matrix_crop")
  ),
  
  # Performance metrics
  tar_target(
    name = repel_performance_crop,
    command = download_github_cache(object_name = "repel_performance_crop")
  ),
  tar_target(
    name = repel_calibration_crop,
    command = download_github_cache(object_name = "repel_calibration_crop")
  ),
  tar_target(
    name = repel_calibration_plot_crop,
    command = download_github_cache(object_name = "repel_calibration_plot_crop")
  ),
  tar_target(
    name = repel_calibration_table_crop,
    command = download_github_cache(object_name = "repel_calibration_table_crop")
  ),
  tar_target(
    name = repel_calibration_n_within_range_crop,
    command = download_github_cache(object_name = "repel_calibration_n_within_range_crop")
  )
)
