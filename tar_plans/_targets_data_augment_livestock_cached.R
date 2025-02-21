# Targets for data augmentation ------------------------------------------------

data_augmentation_targets_livestock <- tar_plan(
  
  ### Augment WAHIS dataset - disaggregated ----
  tar_target(
    name = augmented_livestock_data_disaggregated,
    command = download_github_cache(object_name = "augmented_livestock_data_disaggregated")
  ),
  
  ### Aggregated augmented WAHIS dataset by origin country ----
  tar_target(
    name = augmented_livestock_data_aggregated,
    command = download_github_cache(object_name = "augmented_livestock_data_aggregated")
  )
  
)
