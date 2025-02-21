# Targets for crop data augmentation -------------------------------------------

data_augmentation_targets_crop <- tar_plan(
  
  ### Read in extracted data and process crop outbreaks ----
  tar_target(
    crop_report_index_file, "data-raw/crop-disease-lookup/crop_report_index.csv",
    format = "file", repository = "local"
  ),
  tar_target(
    extracted_data, "data-raw/crop-data-extracted/extracted_data_complete.csv",
    format = "file", repository = "local"
  ),
  tar_target(
    name = extracted_data_processed,
    command = download_github_cache(object_name = "extracted_data_processed")
  ),
  tar_target(
    name = connect_crop_outbreaks,
    command = download_github_cache(object_name = "connect_crop_outbreaks")
  ),
  
  ### Augment crop outbreak dataset - disaggregated ----
  tar_target(
    name = augmented_crop_data_disaggregated,
    command = download_github_cache(object_name = "augmented_crop_data_disaggregated")
  ),
  
  ### Aggregated augmented crop outbreak dataset by origin country ----
  tar_target(
    name = augmented_crop_data_aggregated,
    command = download_github_cache(object_name = "augmented_crop_data_aggregated")
  )
)
