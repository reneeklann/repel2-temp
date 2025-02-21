#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title

#' @return
#' @author Emma Mendelsohn
#' @export
check_prediction_date <- function(predict_from, max_training_date, last_data_update, time_scale) {
  
  predict_from <- format_date(predict_from)
  message(paste("Predicting ahead from", predict_from))
  
  # Check that prediction date is after max training date
  max_training_date <- format_date(max_training_date)
  assertthat::assert_that(predict_from >= max_training_date, 
                          msg = glue::glue("Prediction date cannot be before max training date"))
  
  ## Check that we are not predicting more than 1 window beyond when data was last updated ----
  last_data_update <- format_date(last_data_update)
  assertthat::assert_that(last_data_update >= predict_from, 
                          msg = glue::glue("Cannot predict more than 1 {stringr::str_remove(time_scale, 'ly')} beyond when data was last updated"))
  
  return(predict_from)
}
