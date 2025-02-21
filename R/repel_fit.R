#' Fit model
#'
#' @return
#' @export
repel_fit_model <- function(augmented_data_compressed,
                            predictor_vars,
                            n_threads = 16,
                            max_date = livestock_model_max_training_date) {
  
  
  # Check that the dataset is filtered to the expected date
  max_date <- format_date(max_date)
  max_window <- stringr::str_split(max(augmented_data_compressed$prediction_window),  " to ")[[1]][[2]]
  assertthat::assert_that(max_date == max_window)
  
  wgts <- augmented_data_compressed$count
  
  frm <- stats::as.formula(
    paste0(
      "outbreak_start ~ ", 
      paste0("(0 + ", predictor_vars, "|disease)", collapse = " + ")
    )
  ) #  “variance of trade by disease”
  # syntax notes: (https://stats.stackexchange.com/questions/13166/rs-lmer-cheat-sheet)
  # (0 + var | disease) = The effect of var within each level of disease (more specifically, the degree to which the var effect within a given level deviates from the global effect of var), while enforcing a zero correlation between the intercept deviations and var effect deviations across levels of disease
  
  RhpcBLASctl::blas_set_num_threads(threads = n_threads)
  tictoc::tic(paste0(n_threads, " blas threads"))
  
  mod <- lme4::glmer(
    data = augmented_data_compressed,
    weights = wgts,
    family = binomial,
    formula = frm,
    nAGQ = 0, # adaptive Gaussian quadrature instead the Laplace approximation. The former is known to be better for binomial data.
    verbose = 2, 
    control = lme4::glmerControl(calc.derivs = TRUE)
  )
  
  tictoc::toc()
  
  mod
}



#' Fit crop model (difference is that calc.derivs = FALSE)
#'
#' @return
#' @export
repel_fit_crop_model <- function(augmented_data_compressed, 
                                 predictor_vars, 
                                 n_threads = 16, 
                                 max_date = crop_model_max_training_date, 
                                 max_window) {
  
  
  # Check that the dataset is filtered to the expected date
  max_date <- format_date(max_date)
  # max_window <- stringr::str_split(max(augmented_data_compressed$prediction_window), " to ")[[1]][[2]]
  assertthat::assert_that(max_date == max_window)
  
  wgts <- augmented_data_compressed$count
  
  frm <- stats::as.formula(
    paste0(
      "outbreak_start ~ ", 
      paste0("(0 + ", predictor_vars, "|disease)", collapse = " + ")
    )
  ) #  “variance of trade by disease”
  # syntax notes: (https://stats.stackexchange.com/questions/13166/rs-lmer-cheat-sheet)
  # (0 + var | disease) = The effect of var within each level of disease (more specifically, the degree to which the var effect within a given level deviates from the global effect of var), while enforcing a zero correlation between the intercept deviations and var effect deviations across levels of disease
  
  RhpcBLASctl::blas_set_num_threads(threads = n_threads)
  tictoc::tic(paste0(n_threads, " blas threads"))
  
  mod <- lme4::glmer(
    data = augmented_data_compressed,
    weights = wgts,
    family = binomial,
    formula = frm,
    nAGQ = 0, # adaptive Gaussian quadrature instead the Laplace approximation. The former is known to be better for binomial data.
    verbose = 2, 
    control = lme4::glmerControl(calc.derivs = FALSE)
  )
  
  tictoc::toc()
  
  mod
}
