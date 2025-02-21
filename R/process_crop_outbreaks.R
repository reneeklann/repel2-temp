#' Process Crop Outbreaks
#'
#' This function...
#'
#' @return
#' 
#' @import lubridate
#' @import dplyr
#' @import tidyr
#' 
#' @examples
#' 
#' @export
process_crop_outbreaks <- function(extracted_data_processed,
                                   max_date = crop_model_max_training_date,
                                   time_scale = c("yearly", "monthly"), 
                                   training = TRUE,
                                   ...) {
  
  # Get selected time_scale ----
  # time_scale = "yearly"
  time_scale <- match.arg(time_scale)
  message(paste("Crop model timescale is", time_scale))
  
  # Determine window size ----
  window_size <- switch(time_scale, "yearly" = 12, "monthly" = 1)
  
  # Get max date ----
  # max_date = "2023-06"
  # max_date = lubridate::ym(max_date)
  if(class(max_date) == "character"){max_date = lubridate::ym(max_date)}
  message(paste("Maximum date is", max_date))
  
  events <- extracted_data_processed
  
  # # Get subset of data with multiple reports per country for testing ----
  # events <- events |>
  #   dplyr::filter((country_iso3c == "USA" & disease == "'Candidatus Liberibacter asiaticus'") |
  #                 (country_iso3c == "USA" & disease == "Agrilus planipennis"))
  
  # Get all combos ----
  one_year_ahead <- max_date + lubridate::years(1)
  all_combos <- events |>
    tidyr::expand(
      country_iso3c,
      disease,
      event_month = seq(
        from = lubridate::ymd("1993-01-01"), # start of reporting
        to = one_year_ahead,
        by = "months"
      )
    )
  all_combos <- all_combos |>
    dplyr::filter(!is.na(country_iso3c) & !is.na(disease))
  
  # Expand events to all combos ----
  events <- dplyr::left_join(all_combos, events, by = dplyr::join_by(country_iso3c, disease, event_month))
  
  # Fill presence down and fill in presence for months before first reports ----
  events <- events |>
    dplyr::group_by(country_iso3c, disease) |>
    tidyr::fill(presence, .direction = "down") |>
    dplyr::ungroup() |>
    dplyr::mutate(presence = ifelse(is.na(presence), "absent", presence))
  
  # Create fields outbreak_start and outbreak_ongoing ----
  events <- events |>
    dplyr::group_by(country_iso3c, disease) |>
    dplyr::arrange(event_month, .by_group = TRUE) |>
    dplyr::mutate(disease_present = presence == "present") |> 
    dplyr::mutate(disease_present_lagged = dplyr::lag(disease_present)) |> 
    dplyr::mutate(outbreak_start = disease_present & !disease_present_lagged) |> 
    dplyr::mutate(outbreak_ongoing = disease_present & !outbreak_start) |> 
    dplyr::ungroup() |>
    dplyr::select(-disease_present, -disease_present_lagged)
  
  # Assign disease status to NA for months between max date and one year ahead ----
  events <- events |> 
    dplyr::filter(event_month <= one_year_ahead) |> 
    dplyr::mutate(dplyr::across(c(presence, outbreak_start, outbreak_ongoing), ~ifelse(event_month > max_date, NA, .)))
  
  # Add rolling windows and lag windows to support joins in augmentation ----
  # Note that if the number of months is not evenly divisible by 12, the first group (January-June 1993) will not have a full 12 month lag window
  # this is okay, because we filter 1993 from the model training (as we do not have 1992 disease data to inform the predictions)
  window_lookup <- tibble::tibble(month = rev(seq(min(events$event_month), max(events$event_month), by = "month"))) |> 
    dplyr::mutate(window_group = (seq_along(month) - 1) %/% window_size) |> 
    dplyr::group_by(window_group) |> 
    dplyr::mutate(prediction_window = paste(min(month), "to", max(month))) |> 
    dplyr::mutate(lag_prediction_window = paste(min(month)-months(window_size), "to", max(month)-months(window_size))) |> 
    dplyr::mutate(lag_prediction_window_list = list(seq(min(month)-months(window_size), max(month)-months(window_size), by  = "month"))) |> 
    dplyr::ungroup() |> 
    # dplyr::mutate(lag_year_weight = purrr::map(lag_prediction_window_list, ~table(year(.)))) |> 
    # tidyr::unnest(lag_year_weight) |> 
    # dplyr::mutate(lag_year = names(lag_year_weight)) |> 
    # dplyr::mutate(lag_year_weight = as.integer(lag_year_weight))
    dplyr::select(-window_group)
  
  events <- events |> dplyr::left_join(window_lookup, by = dplyr::join_by(event_month == month))
  
  assertthat::assert_that(!any(is.na(events$prediction_window)))
  
  # This works on monthly and yearly scale
  events <- events |>
    dplyr::group_by(country_iso3c, disease, prediction_window, lag_prediction_window, lag_prediction_window_list) |> 
    dplyr::summarize(
      outbreak_start = any(outbreak_start), # if any outbreak started in the window
      outbreak_ongoing = any(outbreak_ongoing) & !any(outbreak_start), # if no outbreak started but the disease was ongoing from a previous window
      # endemic = any(endemic) & !any(outbreak_start), # if no outbreak started but the disease was endemic
      .groups = "drop"
    ) |> 
    dplyr::ungroup()
  
  # Remove the future prediction window if this is just for training ----
  if(training){
    events <- tidyr::drop_na(events, outbreak_start)
  }
  
  return(events)
}
