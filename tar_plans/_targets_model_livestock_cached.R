# Targets for livestock model improvements -------------------------------------

repel_livestock_model_improvements_targets <- tar_plan(
  ## Split data into 20% validation ----
  tar_target(
    name = repel_data_split,
    command = download_github_cache(object_name = "repel_data_split")
  ),
  ## Create original validation data ----
  tar_target(
    name = repel_validation_data,
    command = download_github_cache(object_name = "repel_validation_data")
  ),
  ## Create original training data ----
  tar_target(
    name = repel_training_data,
    command = download_github_cache(object_name = "repel_training_data")
  ),
  ## Filter out endemic and continuous outbreaks ----
  tar_target(
    name = repel_training_data_select,
    command = download_github_cache(object_name = "repel_training_data_select")
  ),
  ## Set the predictor variables ----
  tar_target(
    name = repel_predictor_variables,
    command = download_github_cache(object_name = "repel_predictor_variables")
  ),
  ## Calculate scaling values ----
  tar_target(
    name = repel_scaling_values,
    command = download_github_cache(object_name = "repel_scaling_values")
  ),
  ## Fit the model ----
  tar_target(
    name = repel_model,
    command = download_github_cache(object_name = "repel_model")
  )

)
