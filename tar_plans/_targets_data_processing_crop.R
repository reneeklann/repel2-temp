# Targets for crop data processing ----

## Data processing ----
data_processing_targets_crop <- tar_plan(
  
  ### EPPO ---------------------------------------------------------------------
  #### Some data cleaning and regex-based extraction
  # TODO adapt function to dynamically handle missing reports 
  tar_target(
    name = eppo_free_text_processed,
    command = process_eppo_free_text(eppo_free_text_scraped),
    cue = tar_cue(tar_cue_setting)
  ),
  tar_target(
    name = eppo_index_processed,
    command = process_eppo_index(eppo_index_downloaded, eppo_free_text_processed, 
                                 priority_crop_disease_lookup),
    cue = tar_cue(tar_cue_setting)
  ),
  
  ### IPPC ---------------------------------------------------------------------
  tar_target(
    name = ippc_table_processed,
    command = process_ippc_table(ippc_table_downloaded, ippc_free_text_scraped, 
                                 priority_crop_disease_lookup),
    cue = tar_cue(tar_cue_setting)
  ),
  
  ### NAPPO --------------------------------------------------------------------
  tar_target(
    name = nappo_table_processed,
    command = process_nappo_table(nappo_table_downloaded, nappo_free_text_scraped, 
                                  priority_crop_disease_lookup),
    cue = tar_cue(tar_cue_setting)
  ),
  
  ### Standardize pest names and taxonomy --------------------------------------
  tar_target(
    name = pest_names_standardized,
    command = standardize_pest_names(database_directory = eppo_crop_database_directory, 
                                     eppo_index_processed, ippc_table_processed, 
                                     nappo_table_processed, eppo_database_downloaded, 
                                     crop_disease_names_manual, 
                                     duplicate_crop_disease_names_to_remove),
    cue = tar_cue(tar_cue_setting)
  ),
  tar_target(
    name = pest_names_not_standardized,
    command = check_pest_names_not_standardized(pest_names_standardized, 
                                                crop_disease_taxonomy_manual),
    cue = tar_cue(tar_cue_setting)
  ),
  tar_target(
    name = crop_report_index,
    command = standardize_pest_taxonomy(pest_names_standardized,
                                        pest_names_not_standardized,
                                        crop_disease_taxonomy_manual),
    cue = tar_cue(tar_cue_setting)
  ),
  tar_target(
    name = priority_diseases,
    command = crop_report_index |>
      dplyr::filter(priority == TRUE) |>
      dplyr::pull(preferred_name) |>
      unique()
  )
)
