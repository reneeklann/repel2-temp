# Targets for crop production and trade data processing ----

## Data processing ----
data_processing_targets_crop_production_trade <- tar_plan(
  
  ### COMTRADE crop-related trade ----------------------------------------------
  #### bilateral/connect
  #### by year
  tar_target(
    name = connect_yearly_comtrade_crop,
    command = process_comtrade(
      download_files = comtrade_crop_downloaded,
      start_date = comtrade_crop_download_start_dates[[1]],
      all_connect_countries_years,
      comtrade_download_check = comtrade_crop_download_check
    )
  ),
  
  ### FAO crop production ------------------------------------------------------
  #### country-level 
  #### by year
  tar_target(
    name = fao_crop_production_item_codes,
    command = get_fao_crop_production_item_codes()
  ),
  tar_target(
    name = country_yearly_crop_production,
    command = process_crop_production(
      download_file = fao_production_downloaded, 
      fao_crop_production_item_codes,
      all_countries_years
    )
  ),
  
  ### FAO crop trade -----------------------------------------------------------
  #### bilateral/connect
  #### by year
  tar_target(
    name = fao_trade_crop_item_codes,
    command = get_fao_trade_crop_item_codes()
  ),
  tar_target(
    name = connect_yearly_fao_trade_crop,
    command = process_fao_trade_crop(
      download_file = fao_trade_downloaded, 
      fao_trade_crop_item_codes, 
      all_connect_countries_years
    )
  )
)
