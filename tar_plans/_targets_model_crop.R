# Targets for crop model improvements ------------------------------------------

repel_crop_model_improvements_targets <- tar_plan(
  ## Split data into 20% validation ----
  tar_target(
    name = repel_data_split_crop,
    command = repel_split_data(augmented_data = augmented_crop_data_aggregated)
  ),
  ## Create original validation data ----
  tar_target(
    name = repel_validation_data_crop,
    command = repel_validation(repel_data_split = repel_data_split_crop)
  ),
  ## Create original training data ----
  tar_target(
    name = repel_training_data_crop,
    command = repel_training(repel_data_split = repel_data_split_crop)
  ),
  ## Filter out continuous outbreaks ----
  tar_target(
    name = repel_training_data_select_crop,
    command = repel_filter_outbreak_starts_crop(repel_training_data = repel_training_data_crop)
  ),
  ## Set the predictor variables ----
  tar_target(
    name = repel_predictor_variables_crop,
    command = c(
      "continent", "kingdom", "shared_borders_from_outbreaks",
      "log_comtrade_dollars_from_outbreaks","log_fao_crop_quantity_from_outbreaks",
      "log_n_migratory_wildlife_from_outbreaks", "log_gdp_dollars",
      "log_human_population", "log_crop_production"
    )
  ),
  ## Calculate scaling values ----
  tar_target(
    name = repel_scaling_values_crop,
    command = repel_scale_values_crop(
      repel_training_data_select = repel_training_data_select_crop,
      repel_predictor_variables = repel_predictor_variables_crop
    )
  ),
  ## Fit the model ----
  tar_target(
    name = repel_model_crop,
    command = repel_fit_crop_model(
      augmented_data_compressed = repel_scaling_values_crop[[2]],
      predictor_vars = repel_predictor_variables_crop,
      n_threads = 16,
      max_date = crop_model_max_training_date, # as a data check to make sure we are working with the correct data
      max_window = repel_scaling_values_crop[[3]]
    ),
  ),
)
