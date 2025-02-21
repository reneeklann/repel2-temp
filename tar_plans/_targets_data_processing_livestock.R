# Targets for data processing ----

## Data processing ----
data_processing_targets_livestock <- tar_plan(
  
  
  ### FAO taxa population ----------------------------------------------------------------
  #### country-level 
  #### by year
  
  #### for nowcast we need taxa population by year
  tar_target(
    name = country_yearly_taxa_population_nowcast,
    command = clean_fao_taxa_population(
      download_file = fao_production_downloaded,
      wahis_disease_taxa_lookup
    )
  ),
  
  #### for travelcast we need target disease population by year (because taxa is not a field in the model)
  tar_target(
    name = country_yearly_taxa_population,
    command = process_taxa_population(
      fao_taxa_population = country_yearly_taxa_population_nowcast,
      wahis_disease_taxa_lookup,
      all_countries_years
    )
  ),
  
  ### WOAH veterinarian population ----------------------------------------------------------------
  #### country-level 
  #### by year
  tar_target(
    name = country_yearly_vet_population,
    command = process_vet_population(
      download_file = woah_vet_population_downloaded,
      all_countries_years
    )
  ),
  
  ### FAO livestock trade ----------------------------------------------------------------
  #### bilateral/connect 
  #### by year
  tar_target(
    name = connect_yearly_fao_trade_livestock,
    command = process_fao_trade_livestock(
      download_file = fao_trade_downloaded,
      all_connect_countries_years
    )
  ),
  
  ### COMTRADE agricultural trade ----------------------------------------------------------------
  #### bilateral/connect 
  #### by year
  tar_target(
    name = connect_yearly_comtrade_livestock,
    command = process_comtrade(
      download_files = comtrade_livestock_downloaded,
      start_date = comtrade_livestock_download_start_dates[[1]],
      all_connect_countries_years,
      comtrade_download_check = comtrade_livestock_download_check
    )
  ),
  
  ### WAHIS livestock events/outbreaks  ----------------------------------------------------------------
  #### outcome variable
  #### disease status by month
  ### WAHIS data checks ----
  
  tar_target(
    name = wahis_epi_events_data_check,
    command = check_wahis_epi_events(
      wahis_epi_events_downloaded,
      index_fields = c(
        "terra_aqua", "epi_event_id_unique",
        "event_start_date", "event_confirmation_date", 
        "event_closing_date", "date_last_occurrence", 
        "iso_code", "standardized_disease_name"
      )
    )
  ),
  
  tar_target(
    name = wahis_outbreaks_data_check,
    command = check_wahis_outbreaks(
      wahis_outbreaks_downloaded,
      index_fields = c("epi_event_id_unique", "outbreak_start_date", "outbreak_end_date")
    )
  ),
  
  ### Get lookup of relevant taxa for each disease
  tar_target(
    name = wahis_disease_taxa_lookup,
    command = process_wahis_disease_taxa_lookup(wahis_outbreaks_downloaded)
  ),
  
  ### Process monthly outbreaks ----
  tar_target(
    name = connect_livestock_outbreaks,
    command = process_wahis_outbreaks(
      wahis_epi_events_downloaded,
      wahis_outbreaks_downloaded,
      nowcast = NULL, # repel_nowcast_predictions if you want to use the NOWCAST model
      max_date = livestock_model_max_training_date,
      time_scale = livestock_model_time_scale,
      wahis_epi_events_data_check,
      wahis_outbreaks_data_check
    )
  )
)