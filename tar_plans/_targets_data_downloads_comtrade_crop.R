# Targets for Comtrade crop data download ----

## Data ingest ----
data_ingest_targets_comtrade_crop <- tar_plan(
  
  ### COMTRADE crop-related trade ----------------------------------------------
  tar_target(comtrade_crop_raw_directory, create_data_directory(directory_path = "data-raw/comtrade-crop")),
  
  #### Determine COMTRADE download start and end dates ----
  tar_target(
    name = comtrade_crop_download_dates,
    command = get_comtrade_crop_download_dates(start_date = 1993)
  ),
  tar_target(
    name = comtrade_crop_download_start_dates,
    command = comtrade_crop_download_dates[[1]]
  ),
  tar_target(
    name = comtrade_crop_download_end_dates,
    command = comtrade_crop_download_dates[[2]]
  ),
  
  #### Get relevant commodity codes ----
  tar_target(
    name = comtrade_crop_commodity_codes,
    command = get_comtrade_crop_commodity_codes() 
  ),
  
  #### Test whether current available Comtrade has expected field names ----
  tar_target(
    name = comtrade_crop_download_check,
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
    name = comtrade_crop_downloaded_from_aws,
    command = misc_download_comtrade_from_aws(directory = comtrade_crop_raw_directory,
                                              download_aws = as.logical(Sys.getenv("USE_AWS_DOWNLOAD", unset = FALSE)),
                                              comtrade_crop_download_start_dates),
    repository = "local",
    cue = tar_cue(tar_cue_setting)
  ),
  
  #### Download COMTRADE trade data serially across start date, end date, and commodity ----
  tar_target(
    name = comtrade_crop_downloaded,
    command = download_comtrade(
      start_date = comtrade_crop_download_start_dates,
      end_date = comtrade_crop_download_end_dates,
      commodity_code = comtrade_crop_commodity_codes,
      directory = comtrade_crop_raw_directory,
      overwrite =  crop_model_overwrite_comtrade,
      comtrade_crop_downloaded_from_aws # to enforce dependency
    ),
    pattern = cross(
      map(comtrade_crop_download_start_dates, comtrade_crop_download_end_dates), 
      comtrade_crop_commodity_codes
    ),
    format = "file",
    repository = "local",
    cue = tar_cue(tar_cue_setting)
  )
)
