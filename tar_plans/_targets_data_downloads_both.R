# Targets for data download ----

## Data download ----
data_downloads_targets_both <- tar_plan(
  
  ### World Bank (WB) GDP ----------------------------------------------------------------
  tar_target(wb_gdp_raw_directory, create_data_directory(directory_path = "data-raw/wb-gdp")),
  
  tar_target(
    name = wb_gdp_downloaded,
    command = download_wb(
      directory = wb_gdp_raw_directory,
      indicator = "NY.GDP.MKTP.CD"
    ),
    format = "file",
    repository = "local",
    cue = tar_cue(tar_cue_setting)
  ),
  
  ### World Bank (WB) human population ----------------------------------------------------------------
  tar_target(wb_human_population_raw_directory, create_data_directory(directory_path = "data-raw/wb-human-population")),
  
  tar_target(
    name = wb_human_population_downloaded,
    command = download_wb(
      directory = wb_human_population_raw_directory,
      indicator = "SP.POP.TOTL"
    ),
    format = "file",
    repository = "local",
    cue = tar_cue(tar_cue_setting)
  ),
  
  ### CIA World Factbook shared borders ----------------------------------------------------------------
  tar_target(shared_borders_directory, create_data_directory(directory_path = "data-raw/shared-borders")),
  
  tar_target(
    name = shared_borders_downloaded,
    command = download_shared_borders(directory = shared_borders_directory),
    format = "file",
    repository = "local",
    cue = tar_cue(tar_cue_setting)
  ),
  
  ### IUCN/GROMS wildlife migration ----------------------------------------------------------------
  
  #### Wildlife occurrence data from IUCN
  tar_target(iucn_wildlife_directory, create_data_directory(directory_path = "data-raw/iucn-wildlife")),
  
  tar_target(
    name = iucn_wildlife_downloaded,
    command = download_iucn_wildlife(
      token = Sys.getenv("IUCN_REDLIST_KEY"),
      directory = iucn_wildlife_directory
    ),
    format = "file",
    repository = "local",
    cue = tar_cue(tar_cue_setting)
  ),
  
  #### Migratory species from GROMS
  tar_target(groms_migratory_species_directory, create_data_directory(directory_path = "data-raw/groms-migratory-species")),
  
  tar_target(
    name = groms_migratory_species_downloaded,
    command = download_groms_migratory_species(
      directory = groms_migratory_species_directory
    ),
    format = "file",
    repository = "local",
    cue = tar_cue(tar_cue_setting)
  ),
  
  ### FAO trade ----------------------------------------------------------------
  tar_target(fao_trade_raw_directory, create_data_directory(directory_path = "data-raw/fao-trade")),
  
  tar_target(
    name = fao_trade_downloaded,
    command = download_fao(directory = fao_trade_raw_directory, dataset = "trade"),
    format = "file",
    repository = "local",
    cue = tar_cue(tar_cue_setting)
  ),
  
  ### FAO taxa and crop production ----------------------------------------------------------------
  tar_target(fao_production_raw_directory, create_data_directory(directory_path = "data-raw/fao-production")),
  
  tar_target(
    name = fao_production_downloaded,
    command = download_fao(directory = fao_production_raw_directory, dataset = "production"),
    format = "file",
    repository = "local",
    cue = tar_cue(tar_cue_setting)
  ),
  
)