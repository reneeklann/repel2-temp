# Targets for livestock model improvements -------------------------------------

repel_livestock_model_improvements_targets <- tar_plan(
  ## Split data into 20% validation ----
  tar_target(
    name = repel_data_split,
    command = repel_split_data(augmented_livestock_data_aggregated),
    cue = tar_cue(tar_cue_setting)
  ),
  ## Create original validation data ----
  tar_target(
    name = repel_validation_data,
    command = repel_validation(repel_data_split),
    cue = tar_cue(tar_cue_setting)
  ),
  ## Create original training data ----
  tar_target(
    name = repel_training_data,
    command = repel_training(repel_data_split),
    cue = tar_cue(tar_cue_setting)
  ),
  ## Filter out endemic and continuous outbreaks ----
  tar_target(
    name = repel_training_data_select,
    command = repel_filter_outbreak_starts(repel_training_data),
    cue = tar_cue(tar_cue_setting)
  ),
  ## Set the predictor variables ----
  tar_target(
    name = repel_predictor_variables,
    command = c(
      "continent", "shared_borders_from_outbreaks",
      "log_comtrade_dollars_from_outbreaks","log_fao_livestock_heads_from_outbreaks", 
      "log_n_migratory_wildlife_from_outbreaks", "log_gdp_dollars", 
      "log_human_population", "log_target_taxa_population", 
      "log_veterinarians", "disease_present_anywhere", "outbreak_previous"
    ),
    cue = tar_cue(tar_cue_setting)
  ),
  ## Calculate scaling values ----
  tar_target(
    name = repel_scaling_values,
    command = repel_scale_values(
      repel_training_data_select,
      repel_predictor_variables
    ),
    cue = tar_cue(tar_cue_setting)
  ),
  ## Fit the model ----
  tar_target(
    name = repel_model,
    command = repel_fit_model(
      augmented_data_compressed = repel_scaling_values[[2]],
      predictor_vars = repel_predictor_variables,
      n_threads = 16,
      max_date = livestock_model_max_training_date # as a data check to make sure we are working with the correct data
    ), 
    cue = tar_cue(tar_cue_setting)
  )

)
