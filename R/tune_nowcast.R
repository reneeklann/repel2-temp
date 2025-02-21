#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title

#' @return
#' @author Emma Mendelsohn
#' @export
tune_nowcast <- function(augmented_six_month_disease_status, threads = 4) {
  
  # Model recipe
  nowcast_recipe <-
    recipes::recipe(formula = disease_status ~ ., data = augmented_six_month_disease_status) |>
    recipes::step_rm(dplyr::starts_with("report_period")) |> # these are not used in fitting
    recipes::step_novel(disease, country_iso3c) |> # assign a previously unseen factor level to "new" (for prediction)
    recipes::step_dummy(recipes::all_nominal(), - recipes::all_outcomes(), one_hot = TRUE) # convert factors wide into dummy fields
  
  # View data
  nowcast_data <- nowcast_recipe |> recipes::prep() |> recipes::juice()
  assertthat::assert_that(!any(map_lgl(nowcast_data, ~any(is.na(.)))))
  
  # Set up model to tune all parameters
  nowcast_spec <-
    parsnip::boost_tree(trees = hardhat::tune(), 
                        min_n = hardhat::tune(), 
                        tree_depth = hardhat::tune(), 
                        learn_rate = hardhat::tune(),
                        loss_reduction = hardhat::tune(),
                        sample_size = hardhat::tune(),
                        mtry = hardhat::tune()) |>
    parsnip::set_mode("classification" ) |>
    parsnip::set_engine("xgboost")
  
  # Make a tidymodel workflow combining recipe and specs
  nowcast_workflow <-
    workflows::workflow() |>
    workflows::add_recipe(nowcast_recipe) |>
    workflows::add_model(nowcast_spec)
  
  # Modify parameters to be able to tune mtry()
  nowcast_param <-
    nowcast_workflow |>
    hardhat::extract_parameter_set_dials() |>
    recipes::update(mtry = dials::finalize(dials::mtry(), augmented_six_month_disease_status))
  
  # Set up 10 fold cross validation
  nowcast_folds <- augmented_six_month_disease_status |>
    rsample::vfold_cv(strata = disease_status, v = 10)
  
  # set up parallel
  doMC::registerDoMC(cores=threads)
  
  # Tune disease status model - first using a grid
  nowcast_tune_grid <- tune::tune_grid(nowcast_workflow,
                                 resamples = nowcast_folds,
                                 control = tune::control_grid(verbose = TRUE,
                                                        parallel_over = "everything"))

  # Read in tuned results and select best parameters
  nowcast_tuned_param <- tune::select_by_one_std_err(nowcast_tune_grid, mtry, trees, min_n, tree_depth, learn_rate, loss_reduction, sample_size)

  # Update workflow with selected parameters
  nowcast_workflow_tuned <- tune::finalize_workflow(nowcast_workflow, nowcast_tuned_param)

  # Fit model with tuned parameters
  nowcast_fit <-  parsnip::fit(object = nowcast_workflow_tuned,
                                      data = augmented_six_month_disease_status)

  return(nowcast_fit)
}
