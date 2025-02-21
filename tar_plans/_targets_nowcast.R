# Targets for nowcast pipeline ----

nowcast_targets <- tar_plan(
  
  ## Feature engineering
  
  ### Process WAHIS six month datasets for NOWCAST ----
  #### For model training, unreported disease statuses are filtered out
  #### For prediction, we include ALL unreported, which includes 
  #### a) diseases marked as "no information / unreported" in the reports 
  #### b) missing reports
  #### c) missing diseases, ie the report is not missing, but it did not mention the specific disease (there are 216,967 instances of this)
  tar_target(
    name = country_livestock_six_month_disease_status,
    command = process_wahis_six_month(
      wahis_six_month_status_downloaded,
      wahis_six_month_controls_downloaded,
      wahis_six_month_quantitative_downloaded,
      max_date = livestock_model_max_training_date
    )
  ),
  
  ### Augment six month disease status ----
  tar_target(
    name = augmented_six_month_disease_status,
    command = augment_wahis_six_months(
      country_livestock_six_month_disease_status,
      country_yearly_gdp,
      country_yearly_human_population,
      country_yearly_taxa_population,
      country_yearly_vet_population,
      connect_static_shared_borders
    ),
  ),
  
  ## Model fitting using tidymodels ----
  
  ### Train/validation split  ----
  tar_target(
    name = repel_data_nowcast_split,
    command = repel_split_nowcast(
      augmented_six_month_disease_status
    ),
  ),  
  tar_target(
    name = repel_validation_data_nowcast,
    command = repel_validation(repel_data_nowcast_split)
  ),
  tar_target(
    name = repel_training_data_nowcast,
    command = repel_training(repel_data_nowcast_split)
  ),
  
  ### Set model tuning parameters and grid ----
  tar_target(
    name = repel_nowcast_spec,
    parsnip::boost_tree(
      trees = 1000,
      tree_depth = hardhat::tune(),
      min_n = hardhat::tune(),
      loss_reduction = hardhat::tune(),                   
      sample_size = hardhat::tune(), 
      mtry = hardhat::tune(),
      learn_rate = hardhat::tune()                          
    ) |>
      parsnip::set_engine("xgboost")  |>
      parsnip::set_mode("classification")
  ),
  
  tar_target(
    name = repel_nowcast_grid,
    dials::grid_latin_hypercube(
      dials::tree_depth(),
      dials::min_n(),
      dials::loss_reduction(),
      sample_size = dials::sample_prop(),
      dials::finalize(dials::mtry(), repel_training_data_nowcast),
      dials::learn_rate(),
      size = 10
    ) 
  ),
  
  ### Set model recipe and workflow  ----
  tar_target(
    name = repel_nowcast_recipe,
    recipes::recipe(formula = disease_status ~ ., data = repel_training_data_nowcast) |>
      recipes::step_rm(dplyr::starts_with("report_period")) |> # these are not used in fitting
      recipes::step_novel(disease, country_iso3c)  |> 
      recipes::step_dummy(recipes::all_nominal(), - recipes::all_outcomes(), one_hot = TRUE) # convert factors wide into dummy fields
  ),
  tar_target(
    name = repel_nowcast_workflow,
    workflows::workflow() |>
      workflows::add_recipe(repel_nowcast_recipe) |>
      workflows::add_model(repel_nowcast_spec)
  ),
  
  ### Cross validation  ----
  tar_target(
    name = repel_nowcast_folds,
    rsample::vfold_cv(repel_training_data_nowcast, strata = disease_status, v = 10) 
  ),
  tar_target(
    name = repel_nowcast_tuned,
    {
      tuned <- tune::tune_grid(
        repel_nowcast_workflow,
        resamples = repel_nowcast_folds,
        grid = repel_nowcast_grid,
        control = tune::control_grid(verbose = TRUE)
      )
      tune::select_by_one_std_err(tuned,  mtry, min_n, tree_depth, learn_rate, loss_reduction, sample_size)
    }
  ),
  
  ### Final model  ----
  tar_target(
    name = repel_nowcast_model,
    tune::finalize_workflow(x = repel_nowcast_workflow, parameters = repel_nowcast_tuned) |> parsnip::fit(repel_training_data_nowcast)
  ),
  
  ### Model performance ----
  tar_target(
    name = repel_nowcast_validation,
    {
      p <- dplyr::mutate(repel_validation_data_nowcast, disease_status_predicted= dplyr::pull(predict(repel_nowcast_model, repel_validation_data_nowcast), 1))
      switch <- p |> 
        dplyr::select(disease_status, disease_status_predicted, disease_status_lag_6) |> 
        dplyr::mutate(switch = disease_status_lag_6 %in% c("absent","unreported")  & disease_status == "present") |> 
        dplyr::filter(switch)
      sum(switch$disease_status_predicted == "present")/nrow(switch)
      cm <- yardstick::conf_mat(data = p,
                                truth = disease_status,
                                estimate = disease_status_predicted)
      return(summary(cm))
    }
  ),
  
  ### Prep data for predictions ----
  tar_target(
    name = country_livestock_six_month_disease_status_for_prediction,
    command = process_wahis_six_month(
      wahis_six_month_status_downloaded,
      wahis_six_month_controls_downloaded,
      wahis_six_month_quantitative_downloaded,
      max_date = repel_prediction_date_livestock,
      training = FALSE
    )
  ),
  tar_target(
    name = augmented_six_month_disease_status_for_prediction,
    augment_wahis_six_months(
      country_livestock_six_month_disease_status_for_prediction,
      country_yearly_gdp,
      country_yearly_human_population,
      country_yearly_taxa_population,
      country_yearly_vet_population,
      connect_static_shared_borders
    )
  ),
  
  ### Step ahead predictions ----
  tar_target(
    name = repel_nowcast_step_ahead_predictions,
    command = repel_nowcast_step_ahead_predict(
      country_livestock_six_month_disease_status_for_prediction
    )
  ),
  
  ### Model based predictions ----
  tar_target(
    name = repel_nowcast_predictions,
    {
      p <- dplyr::mutate(augmented_six_month_disease_status_for_prediction, disease_status_predicted = dplyr::pull(predict(repel_nowcast_model, augmented_six_month_disease_status_for_prediction), 1))
      p |> 
        dplyr::mutate(imputed = disease_status == "missing")  |> 
        dplyr::mutate(disease_status = dplyr::if_else(imputed, disease_status_predicted, disease_status)) |> 
        dplyr::select(country_iso3c, disease, report_period, disease_status, imputed) 
    }
  )
)
