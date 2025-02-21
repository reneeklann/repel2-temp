# Targets for crop data extraction ----

## Data extraction ----
data_extraction_targets_crop <- tar_plan(
  
  ### Manually extracted data for scoring purposes
  #### This can be updated with additional samples if we want to include more reports in our scoring
  tar_target(
    crop_data_manual, "data-raw/crop-disease-lookup/crop_data_manual.csv",
    format = "file", repository = "local"
  ),
  
  tar_target(extracted_crop_data_directory, create_data_directory(directory_path = "data-raw/crop-data-extracted")),
  
  ### NAPPO OpenAI data extraction ---------------------------------------------
  #### Assessment - extraction for crop_data_manual
  tar_target(
    name = nappo_reports_sample,
    command = get_nappo_reports_sample(crop_data_manual, crop_report_index) |>
      dplyr::group_by(group = (row_number() - 1) %/% 50) |>
      tar_group(),
    iteration = "group",
    cue = tar_cue(tar_cue_setting)
  ),
  tar_target(
    name = nappo_data_extracted_sample,
    command =  extract_data_nappo(
      nappo_reports = nappo_reports_sample,
      pipeline = "assessment",
      directory = extracted_crop_data_directory,
      overwrite = FALSE
    ),
    pattern = map(nappo_reports_sample),
    format = "file",
    repository = "local",
    cue = tar_cue(tar_cue_setting)
  ),
  tar_target(
    name = nappo_data_formatted_sample,
    command = format_openai_results(extracted_data_files = nappo_data_extracted_sample),
    cue = tar_cue(tar_cue_setting)
  ),
  #### Full run excluding crop_data_manual
  tar_target(
    name = nappo_reports,
    command = get_nappo_reports(crop_data_manual, crop_report_index) |>
      # dplyr::filter(preferred_name %in% priority_diseases) |>
      # dplyr::filter(preferred_name %in% c("'Candidatus Phytoplasma solani'", "Xylella fastidiosa")) |>
      dplyr::group_by(preferred_name) |>
      tar_group(),
    iteration = "group"
  ),
  tar_target(
    name = nappo_data_extracted,
    command =  extract_data_nappo(
      nappo_reports = nappo_reports,
      pipeline = "full",
      directory = extracted_crop_data_directory,
      overwrite = FALSE
    ),
    pattern = map(nappo_reports),
    format = "file",
    repository = "local"
  ),
  tar_target(
    name = nappo_data_formatted,
    command = format_openai_results(extracted_data_files = nappo_data_extracted)
  ),
  
  ### IPPC OpenAI data extraction ----------------------------------------------
  #### Assessment - extraction for crop_data_manual
  tar_target(
    name = ippc_reports_sample,
    command = get_ippc_reports_sample(crop_data_manual, crop_report_index) |>
      dplyr::group_by(group = (row_number() - 1) %/% 50) |>
      tar_group(),
    iteration = "group",
    cue = tar_cue(tar_cue_setting)
  ),
  tar_target(
    name = ippc_data_extracted_sample,
    command =  extract_data_ippc(
      ippc_reports = ippc_reports_sample,
      pipeline = "assessment",
      directory = extracted_crop_data_directory,
      overwrite = FALSE
    ),
    pattern = map(ippc_reports_sample),
    format = "file",
    repository = "local",
    cue = tar_cue(tar_cue_setting)
  ),
  tar_target(
    name = ippc_data_formatted_sample,
    command = format_openai_results(extracted_data_files = ippc_data_extracted_sample),
    cue = tar_cue(tar_cue_setting)
  ),
  #### Full run excluding crop_data_manual
  tar_target(
    name = ippc_reports,
    command = get_ippc_reports(crop_data_manual, crop_report_index) |>
      # dplyr::filter(preferred_name %in% priority_diseases) |>
      # dplyr::filter(preferred_name == "Cowpea mild mottle virus") |>
      dplyr::group_by(preferred_name) |>
      tar_group(),
    iteration = "group"
  ),
  tar_target(
    name = ippc_data_extracted,
    command =  extract_data_ippc(
      ippc_reports = ippc_reports,
      pipeline = "full",
      directory = extracted_crop_data_directory,
      overwrite = FALSE
    ),
    pattern = map(ippc_reports),
    format = "file",
    repository = "local"
  ),
  tar_target(
    name = ippc_data_formatted,
    command = format_openai_results(extracted_data_files = ippc_data_extracted)
  ),
  
  ### EPPO single OpenAI data extraction (reports with one disease event) ----------
  #### Assessment - extraction for crop_data_manual
  tar_target(
    name = eppo_single_reports_sample,
    command = get_eppo_single_reports_sample(crop_data_manual, crop_report_index) |>
      dplyr::group_by(group = (row_number() - 1) %/% 50) |>
      tar_group(),
    iteration = "group",
    cue = tar_cue(tar_cue_setting)
  ),
  tar_target(
    name = eppo_single_data_extracted_sample,
    command = extract_data_eppo_single(
      eppo_single_reports = eppo_single_reports_sample,
      pipeline = "assessment",
      directory = extracted_crop_data_directory,
      overwrite = FALSE
    ),
    pattern = map(eppo_single_reports_sample),
    format = "file",
    repository = "local",
    cue = tar_cue(tar_cue_setting)
  ),
  tar_target(
    name = eppo_single_data_formatted_sample,
    command = format_openai_results(extracted_data_files = eppo_single_data_extracted_sample),
    cue = tar_cue(tar_cue_setting)
  ),
  #### Full run excluding crop_data_manual
  tar_target(
    name = eppo_single_reports,
    command = get_eppo_single_reports(crop_data_manual, crop_report_index) |>
      dplyr::filter(year_published < as.integer(format(Sys.Date(), "%Y"))) |>
      # dplyr::filter(preferred_name %in% priority_diseases) |>
      # dplyr::filter(preferred_name == "Xanthomonas oryzae pv. oryzicola") |>
      dplyr::group_by(preferred_name) |>
      tar_group(),
    iteration = "group"
  ),
  tar_target(
    name = eppo_single_data_extracted,
    command = extract_data_eppo_single(
      eppo_single_reports = eppo_single_reports,
      pipeline = "full",
      directory = extracted_crop_data_directory,
      overwrite = FALSE
    ),
    pattern = map(eppo_single_reports),
    format = "file",
    repository = "local"
  ),
  tar_target(
    name = eppo_single_data_formatted,
    command = format_openai_results(extracted_data_files = eppo_single_data_extracted)
  ),
  
  ### EPPO multi OpenAI data extraction (reports with multiple disease events) ----------
  #### Assessment - extraction for crop_data_manual
  tar_target(
    name = eppo_multi_reports_sample,
    command = get_eppo_multi_reports_sample(crop_data_manual, crop_report_index),
    cue = tar_cue(tar_cue_setting)
  ),
  tar_target(
    name = eppo_multi_reports_preprocessed_sample,
    command = preprocess_eppo_multi_reports(eppo_multi_reports = eppo_multi_reports_sample) |>
      dplyr::group_by(group = (row_number() - 1) %/% 50) |>
      tar_group(),
    iteration = "group",
    cue = tar_cue(tar_cue_setting)
  ),
  tar_target(
    name = eppo_multi_data_extracted_sample,
    command =  extract_data_eppo_multi(
      eppo_multi_reports = eppo_multi_reports_preprocessed_sample,
      pipeline = "assessment",
      directory = extracted_crop_data_directory,
      overwrite = FALSE
    ),
    pattern = map(eppo_multi_reports_preprocessed_sample),
    format = "file",
    repository = "local",
    cue = tar_cue(tar_cue_setting)
  ),
  tar_target(
    name = eppo_multi_data_formatted_sample,
    command = format_openai_results(extracted_data_files = eppo_multi_data_extracted_sample),
    cue = tar_cue(tar_cue_setting)
  ),
  #### Full run excluding crop_data_manual
  tar_target(
    name = eppo_multi_reports,
    command = get_eppo_multi_reports(crop_data_manual, crop_report_index)
  ),
  tar_target(
    name = eppo_multi_reports_preprocessed,
    command = preprocess_eppo_multi_reports(eppo_multi_reports = eppo_multi_reports) |>
      dplyr::filter(year_published < as.integer(format(Sys.Date(), "%Y"))) |>
      # dplyr::filter(preferred_name %in% priority_diseases) |>
      # dplyr::filter(preferred_name == "Xylella fastidiosa subsp. multiplex") |>
      dplyr::group_by(preferred_name) |>
      tar_group(),
    iteration = "group"
  ),
  tar_target(
    name = eppo_multi_data_extracted,
    command =  extract_data_eppo_multi(
      eppo_multi_reports = eppo_multi_reports_preprocessed,
      pipeline = "full",
      directory = extracted_crop_data_directory,
      overwrite = FALSE
    ),
    pattern = map(eppo_multi_reports_preprocessed),
    format = "file",
    repository = "local"
  ),
  tar_target(
    name = eppo_multi_data_formatted,
    command = format_openai_results(extracted_data_files = eppo_multi_data_extracted)
  ),
  
  ### Combine assessment pipeline manual extraction with free text reports and LLM extract ----------
  #### Can be exported as a csv for manually scoring
  tar_target(
    name = extracted_data_combined_sample,
    command = combine_extracted_data_sample(ippc_reports_sample, ippc_data_formatted_sample,
                                            nappo_reports_sample, nappo_data_formatted_sample,
                                            eppo_single_reports_sample, eppo_single_data_formatted_sample,
                                            eppo_multi_reports_preprocessed_sample, 
                                            eppo_multi_data_formatted_sample, 
                                            crop_data_manual),
    cue = tar_cue(tar_cue_setting)
  ),
  #### Export csv for scoring
  tar_target(
    name = assessment_data_exported,
    command = write.csv(extracted_data_combined_sample, "data-raw/crop-data-extracted/extracted_data_assessment.csv")
  ),
  
  ### Combine all full pipeline free text reports and LLM extract ----------
  tar_target(
    name = extracted_data_combined,
    command = combine_extracted_data(ippc_reports, ippc_data_formatted,
                                     nappo_reports, nappo_data_formatted,
                                     eppo_single_reports, eppo_single_data_formatted,
                                     eppo_multi_reports_preprocessed,
                                     eppo_multi_data_formatted)
  ),
  ### Add flags (disease, year, presence) ----------
  tar_target(
    name = extracted_data_flagged,
    command = flag_extracted_data(extracted_data_combined)
  ),
  # This is the file for manual review of flagged data. Make sure it isn't over-written.
  tar_target(
    name = flagged_data_exported,
    command = extracted_data_flagged |>
      dplyr::filter(flag_disease == TRUE | flag_year == TRUE | flag_presence == TRUE) |>
      write.csv("data-raw/crop-data-extracted/extracted_data_flagged.csv")
  ),
  
  ### Create final extracted data file ----------
  #### Combines three outputs for input into process_crop_outbreaks()
  #### extracted_data_combined_sample
  #### flagged_data_scored
  #### extracted_data_combined - with the flagged data filtered out
  #### check to make sure we have all reports represented
  # tar_target(
  #   name = extracted_data_complete,
  #   command = extracted_data_complete <- dplyr::bind_rows(extracted_data_combined_sample, extracted_data_flagged) |>
  #     write.csv("data-raw/crop-data-extracted/extracted_data_complete.csv")
  # )
  tar_target(
    name = extracted_data_complete,
    command = combine_all_extracted_data(extracted_data_combined_sample, extracted_data_flagged)
  )
  
  ### Score summary table ----------
  #### combine extracted_data_combined_sample and flagged_data_scored into a table for reporting
  
)
