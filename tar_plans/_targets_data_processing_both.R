# Targets for data processing ----

## Data processing ----
data_processing_targets_both <- tar_plan(
  
  ### Processing for utility datasets ----
  all_countries_years = misc_process_country_year(from = 1993),
  all_connect_countries_years = misc_process_connect_country_year(from = 1993),
  
  ### World Bank (WB) GDP ----------------------------------------------------------------
  #### country-level 
  #### by year
  tar_target(
    name = country_yearly_gdp,
    command = process_wb(download_file = wb_gdp_downloaded,
                         field_name = "gdp_dollars",
                         all_countries_years,
                         index_fields = c("countryiso3code", "date", "value"))
  ),
  
  ### World Bank (WB) human population ----------------------------------------------------------------
  #### country-level 
  #### by year
  tar_target(
    name = country_yearly_human_population,
    command = process_wb(download_file = wb_human_population_downloaded,
                         field_name = "human_population",
                         all_countries_years,
                         index_fields = c("countryiso3code", "date", "value"))
  ),
  
  ### CIA World Factbook shared borders ----------------------------------------------------------------
  #### bilateral/connect 
  #### static
  tar_target(
    name = connect_static_shared_borders,
    command = process_country_borders(download_file = shared_borders_downloaded,
                                      all_connect_countries_years)
  ),
  
  ### Process bilateral wildlife migration from IUCN ----------------------------------------------------------------
  #### bilateral/connect 
  #### static
  tar_target(
    name = connect_static_wildlife_migration,
    command = process_wildlife_migration(iucn_download_file = iucn_wildlife_downloaded,
                                         groms_download_file = groms_migratory_species_downloaded,
                                         all_connect_countries_years)
  )
)
