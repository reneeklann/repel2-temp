# Targets for livestock model validation ----

## Livestock model validation ----
validation_targets_livestock <- tar_plan(
  
  ## Scale and compress validation data ----
  tar_target(
    name = repel_validation_data_scaled,
    command = download_github_cache(object_name = "repel_validation_data_scaled")
  ),
  
  ## Generate predictions on validation data ----
  tar_target(
    name = repel_validation_predict,
    command = download_github_cache(object_name = "repel_validation_predict")
  ),
  
  ## Confusion matrix ----
  tar_target(
    name = repel_confusion_matrix,
    command = download_github_cache(object_name = "repel_confusion_matrix")
  ),
  
  # Performance metrics
  tar_target(
    name = repel_performance,
    command = download_github_cache(object_name = "repel_performance")
  ),
  tar_target(
    name = repel_calibration,
    command = download_github_cache(object_name = "repel_calibration")
  ),
  tar_target(
    name = repel_calibration_plot,
    command = download_github_cache(object_name = "repel_calibration_plot")
  ),
  tar_target(
    name = repel_calibration_table,
    command = download_github_cache(object_name = "repel_calibration_table")
  ),
  tar_target(
    name = repel_calibration_n_within_range,
    command = download_github_cache(object_name = "repel_calibration_n_within_range")
  )
)
