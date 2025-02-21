# Targets for crop model improvements ------------------------------------------

repel_crop_model_improvements_targets <- tar_plan(
  ## Split data into 20% validation ----
  tar_target(
    name = repel_data_split_crop,
    command = download_github_cache(object_name = "repel_data_split_crop")
  ),
  ## Create original validation data ----
  tar_target(
    name = repel_validation_data_crop,
    command = download_github_cache(object_name = "repel_validation_data_crop")
  ),
  ## Create original training data ----
  tar_target(
    name = repel_training_data_crop,
    command = download_github_cache(object_name = "repel_training_data_crop")
  ),
  ## Filter out continuous outbreaks ----
  tar_target(
    name = repel_training_data_select_crop,
    command = download_github_cache(object_name = "repel_training_data_select_crop")
  ),
  ## Set the predictor variables ----
  tar_target(
    name = repel_predictor_variables_crop,
    command = download_github_cache(object_name = "repel_predictor_variables_crop")
  ),
  
  ## Calculate scaling values ----
  tar_target(
    name = repel_scaling_values_crop,
    command = download_github_cache(object_name = "repel_scaling_values_crop")
  ),
  ## Fit the model ----
  tar_target(
    name = repel_model_crop,
    command = download_github_cache(object_name = "repel_model_crop")
  )
)
