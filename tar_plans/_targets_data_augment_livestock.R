# Targets for data augmentation ------------------------------------------------

data_augmentation_targets_livestock <- tar_plan(
  
  ### Augment WAHIS dataset - disaggregated ----
  tar_target(
    name = augmented_livestock_data_disaggregated,
    command = augment_livestock_data_disaggregated(
      connect_livestock_outbreaks,
      country_yearly_gdp,
      country_yearly_human_population,
      country_yearly_taxa_population,
      country_yearly_vet_population,
      connect_static_shared_borders,
      connect_static_wildlife_migration,
      connect_yearly_fao_trade_livestock,
      connect_yearly_comtrade_livestock,
      time_scale = livestock_model_time_scale
    ),
    cue = tar_cue(tar_cue_setting)
  ),
  
  ### Aggregated augmented WAHIS dataset by origin country ----
  tar_target(
    name = augmented_livestock_data_aggregated,
    command = aggregate_augmented_livestock_data(
      augmented_livestock_data_disaggregated
    ),
    cue = tar_cue(tar_cue_setting)
  )
  
)
