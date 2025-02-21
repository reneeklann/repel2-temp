# Targets for data download ----

## Data download ----
data_downloads_targets_livestock <- tar_plan(

  ### COMTRADE agricultural trade ----------------------------------------------------------------
  tar_target(comtrade_livestock_raw_directory, create_data_directory(directory_path = "data-raw/comtrade-livestock")),
  
  #### Determine COMTRADE download start and end dates ----
  tar_target(
    name = comtrade_livestock_download_dates,
    command = get_comtrade_livestock_download_dates(start_date = 2000)
  ),
  tar_target(
    name = comtrade_livestock_download_start_dates,
    command = comtrade_livestock_download_dates[[1]]
  ),
  tar_target(
    name = comtrade_livestock_download_end_dates,
    command = comtrade_livestock_download_dates[[2]]
  ),

  #### Get relevant commodity codes ----
  tar_target(
    name = comtrade_livestock_commodity_codes,
    command = get_comtrade_livestock_commodity_codes() 
  ),
  
  #### Test whether current available Comtrade has expected field names ----
  tar_target(
    name = comtrade_livestock_download_check,
    command = check_comtrade_download_fields(
      index_fields = c(
        "period", "reporter_iso", "partner_iso", 
        "flow_desc", "cmd_code", "cmd_desc", 
        "primary_value"
      )
    )
  ),
  
  #### To increase download speed for internal development purposes, option to download comtrade repo from AWS ----
  tar_target(
    name = comtrade_livestock_downloaded_from_aws,
    command = misc_download_comtrade_from_aws(directory = comtrade_livestock_raw_directory,
                                              download_aws = as.logical(Sys.getenv("USE_AWS_DOWNLOAD", unset = FALSE)),
                                              comtrade_livestock_download_start_dates),
    repository = "local",
    cue = tar_cue(tar_cue_setting)
  ),
  
  #### Download COMTRADE trade data serially across start date, end date, and commodity ----
  tar_target(
    name = comtrade_livestock_downloaded,
    command = download_comtrade(
      start_date = comtrade_livestock_download_start_dates,
      end_date =comtrade_livestock_download_end_dates,
      commodity_code = comtrade_livestock_commodity_codes,
      directory = comtrade_livestock_raw_directory,
      overwrite = livestock_model_overwrite_comtrade,
      comtrade_livestock_downloaded_from_aws # to enforce dependency
    ),
    pattern = cross(
      map(comtrade_livestock_download_start_dates, comtrade_livestock_download_end_dates), 
      comtrade_livestock_commodity_codes
    ),
    format = "file",
    repository = "local",
    cue = tar_cue(tar_cue_setting)
  ),
  
  ### WOAH veterinarian population ----------------------------------------------------------------
  tar_target(woah_vet_population_raw_directory, create_data_directory(directory_path = "data-raw/woah-vet-population")),
  
  tar_target(
    name = woah_vet_population_downloaded,
    command = download_woah_vet_population(directory = woah_vet_population_raw_directory),
    format = "file",
    repository = "local",
    cue = tar_cue(tar_cue_setting)
  ),
  
  
  ### WAHIS livestock events/outbreaks  ----------------------------------------------------------------
  tar_target(wahis_outbreak_reports_raw_directory, create_data_directory(directory_path = "data-raw/wahis-outbreak-reports")),
  
  #### Events is higher level one outbreak per row
  tar_target(
    name = wahis_epi_events_downloaded,
    command = download_wahis(
      token = Sys.getenv("DOLT_TOKEN"),
      wahis_table = "wahis_epi_events",
      directory = wahis_outbreak_reports_raw_directory
    ),
    format = "file",
    repository = "local",
    cue = tar_cue(tar_cue_setting)
  ),
  
  #### Outbreaks has finer resolution taxa and location and timing info
  tar_target(
    name = wahis_outbreaks_downloaded,
    command = download_wahis(
      token = Sys.getenv("DOLT_TOKEN"),
      wahis_table = "wahis_outbreaks", 
      directory = wahis_outbreak_reports_raw_directory
    ),
    format = "file",
    repository = "local",
    cue = tar_cue(tar_cue_setting)
  ),
  
  ### WAHIS livestock six-month reports  ----------------------------------------------------------------
  tar_target(wahis_six_month_reports_raw_directory, create_data_directory(directory_path = "data-raw/wahis-six-month-reports")),
  
  ### Retrieve WAHIS six month datasets ----
  tar_target(
    name = wahis_six_month_status_downloaded,
    command = download_wahis(
      token = Sys.getenv("DOLT_TOKEN"),
      wahis_table = "wahis_six_month_status", 
      directory = wahis_six_month_reports_raw_directory
    ),
    format = "file",
    repository = "local",
    cue = tar_cue(tar_cue_setting)
  ),
  
  tar_target(
    name = wahis_six_month_controls_downloaded,
    command = download_wahis(
      token = Sys.getenv("DOLT_TOKEN"),
      wahis_table = "wahis_six_month_controls", 
      directory = wahis_six_month_reports_raw_directory
    ),
    format = "file",
    repository = "local",
    cue = tar_cue(tar_cue_setting)
  ),
  
  tar_target(
    name = wahis_six_month_quantitative_downloaded,
    command = download_wahis(
      token = Sys.getenv("DOLT_TOKEN"),
      wahis_table = "wahis_six_month_quantitative", 
      directory = wahis_six_month_reports_raw_directory),
    format = "file",
    repository = "local",
    cue = tar_cue(tar_cue_setting)
  ),
  
  
  ### REPEL phase I extracts  ----------------------------------------------------------------
  tar_target(repel1_extracts_directory, create_data_directory(directory_path = "repel1-extracts")),
  
  #### cached NOWCAST data ----
  tar_target(
    name = repel1_nowcast_boost_augment_predict,
    command = misc_download_repel1_extract(file = "nowcast_boost_augment_predict.csv.gz", directory = repel1_extracts_directory),
    format = "file",
    repository = "local",
    cue = tar_cue(tar_cue_setting)
  ),
  
  ### Retrieve REPEL1 cached data for comparison report ----
  tar_target(
    name = repel1_network_lme_augment_predict_by_origin,
    command = misc_download_repel1_extract(file = "network_lme_augment_predict_by_origin.csv.gz", directory = repel1_extracts_directory),
    format = "file",
    repository = "local",
    cue = tar_cue(tar_cue_setting)
  ),
  tar_target(
    name = repel1_network_lme_augment_predict,
    command = misc_download_repel1_extract(file = "network_lme_augment_predict.csv.gz", directory = repel1_extracts_directory),
    format = "file",
    repository = "local",
    cue = tar_cue(tar_cue_setting)
  ),
  
  ### Retrieve REPEL1 cached model for comparison report ----
  tar_target(
    name = repel1_network_scaling_values,
    command = misc_download_repel1_extract(file = "network_scaling_values.rds", directory = repel1_extracts_directory),
    format = "file",
    repository = "local",
    cue = tar_cue(tar_cue_setting)
  ),
  tar_target(
    name = repel1_lme_mod_network,
    command = misc_download_repel1_extract(file = "lme_mod_network.rds", directory = repel1_extracts_directory),
    format = "file",
    repository = "local",
    cue = tar_cue(tar_cue_setting)
  )
)