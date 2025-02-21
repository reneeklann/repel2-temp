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
    command = process_extracted_data(extracted_data, crop_report_index_file)
  ),
  tar_target(
    name = connect_crop_outbreaks,
    command = process_crop_outbreaks(
      extracted_data_processed,
      max_date = crop_model_max_training_date,
      time_scale = crop_model_time_scale
    )
  ),
  
  ### Processed Comtrade data ----
  # tar_target(
  #   connect_yearly_comtrade_crop_file, "data-raw/comtrade-crop/connect_yearly_comtrade_crop.csv", 
  #   format = "file", repository = "local"
  # ),
  
  ### Augment crop outbreak dataset - disaggregated ----
  tar_target(
    name = augmented_crop_data_disaggregated,
    command = augment_crop_data_disaggregated(
      connect_crop_outbreaks,
      extracted_data_processed,
      country_yearly_gdp,
      country_yearly_human_population,
      country_yearly_crop_production,
      connect_static_shared_borders,
      connect_static_wildlife_migration,
      connect_yearly_fao_trade_crop,
      connect_yearly_comtrade_crop
      # connect_yearly_comtrade_crop_file
    ),
    cue = tar_cue(tar_cue_setting)
  ),
  
  ### Aggregated augmented crop outbreak dataset by origin country ----
  tar_target(
    name = augmented_crop_data_aggregated,
    command = aggregate_augmented_crop_data(
      augmented_crop_data_disaggregated
    ),
    cue = tar_cue(tar_cue_setting)
  )
)
