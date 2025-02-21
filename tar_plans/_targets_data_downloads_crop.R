# Targets for crop data download ----

## Data ingest ----
data_ingest_targets_crop <- tar_plan(
  
  ### EPPO reporting service ---------------------------------------------------
  tar_target(eppo_crop_reports_raw_directory, create_data_directory(directory_path = "data-raw/eppo-crop-reports")),
  
  #### Download structured index ----
  tar_target(
    name = eppo_index_downloaded, # NOTE the index goes to 2023, we will need to rely on the free text for updates
    command = download_eppo_index(directory = eppo_crop_reports_raw_directory),
    format = "file",
    repository = "local",
    cue = tar_cue(tar_cue_setting)
  ),
  
  #### Get report URLs for free text scraping ----
  tar_target(
    name = eppo_report_urls,
    command = get_eppo_report_urls(),
    cue = tar_cue(tar_cue_setting)
  ),
  
  #### Iterate over URLS and ingest ----
  tar_target(
    name = eppo_free_text_scraped,
    command = scrape_eppo_free_text(eppo_report_urls, 
                                    directory = eppo_crop_reports_raw_directory,
                                    overwrite = FALSE),
    format = "file",
    repository = "local",
    cue = tar_cue(tar_cue_setting)
  ),
  
  ### IPPC pest reports --------------------------------------------------------
  tar_target(ippc_crop_reports_raw_directory, create_data_directory(directory_path = "data-raw/ippc-crop-reports")),
  
  #### Download structured index and URLS----
  tar_target(
    name = ippc_table_downloaded,
    command = download_ippc_table(directory = ippc_crop_reports_raw_directory),
    format = "file",
    repository = "local",
    cue = tar_cue(tar_cue_setting)
  ),
  
  #### Iterate over URLS and ingest ----
  tar_target(
    name = ippc_free_text_scraped,
    command = scrape_ippc_free_text(ippc_table_downloaded, 
                                    directory = ippc_crop_reports_raw_directory,
                                    overwrite = FALSE),
    format = "file",
    repository = "local",
    cue = tar_cue(tar_cue_setting)
  ),
  
  ### NAPPO pest reports -------------------------------------------------------
  tar_target(nappo_crop_reports_raw_directory, create_data_directory(directory_path = "data-raw/nappo-crop-reports")),
  
  #### Download structured index and URLS----
  tar_target(
    name = nappo_table_downloaded,
    command = download_nappo_table(directory = nappo_crop_reports_raw_directory),
    format = "file",
    repository = "local",
    cue = tar_cue(tar_cue_setting)
  ),
  
  #### Iterate over URLS and ingest ----
  tar_target(
    name = nappo_free_text_scraped,
    command = scrape_nappo_free_text(nappo_table_downloaded, 
                                     directory = nappo_crop_reports_raw_directory,
                                     overwrite = FALSE),
    format = "file",
    repository = "local",
    cue = tar_cue(tar_cue_setting)
  ),
  
  ### Data sources for cleaning and standardization ----------------------------
  
  #### EPPO database for disease name standardization ----
  tar_target(eppo_crop_database_directory, create_data_directory(directory_path = "data-raw/eppo-crop-database")),
  
  tar_target(
    name = eppo_database_downloaded, 
    command = withr::with_dir(eppo_crop_database_directory,
                              c(pestr::eppo_database_download(), 
                                zip::unzip("eppocodes.zip")))
  ),
  
  #### EHA manually generated files for disease name and taxonomy standardization ----
  ##### these are static files that are git tracked
  tar_target(crop_disease_lookup_directory, create_data_directory(directory_path = "data-raw/crop-disease-lookup")),
  
  tar_target(
    priority_crop_disease_lookup, 
    paste0(crop_disease_lookup_directory, "/priority_crop_disease_lookup.xlsx"), 
    format = "file", 
    repository = "local"
  ),
  
  tar_target(
    crop_disease_names_manual, 
    paste0(crop_disease_lookup_directory, "/crop_disease_names_manual.csv"), 
    format = "file", 
    repository = "local"
  ),
  
  tar_target(
    duplicate_crop_disease_names_to_remove, 
    paste0(crop_disease_lookup_directory, "/duplicate_crop_disease_names_to_remove.csv"), 
    format = "file", 
    repository = "local"
  ),
  
  tar_target(
    crop_disease_taxonomy_manual, 
    paste0(crop_disease_lookup_directory, "/crop_disease_taxonomy_manual.csv"), 
    format = "file", 
    repository = "local"
  )
)
