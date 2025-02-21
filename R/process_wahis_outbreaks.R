#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param wahis_epi_events_downloaded
#' @param nowcast
#' @return
#' @author Emma Mendelsohn
#' @export
process_wahis_outbreaks <- function(wahis_epi_events_downloaded, 
                                    wahis_outbreaks_downloaded,
                                    nowcast = NULL,
                                    max_date = livestock_model_max_training_date,
                                    time_scale = c("yearly", "monthly"),
                                    wahis_epi_events_data_check,
                                    wahis_outbreaks_data_check,
                                    training = TRUE,
                                    ...) {
  ## Check input data ----
  if (!is.null(wahis_epi_events_data_check)) {
    stop(wahis_epi_events_data_check)
  }
  
  if (!is.null(wahis_outbreaks_data_check)) {
    stop(wahis_outbreaks_data_check)
  }
  
  ## Get selected time_scale ----
  time_scale <- match.arg(time_scale)
  message(paste("Livestock model timescale is", time_scale))
  
  # Determine window size ----
  window_size <- switch(time_scale, "yearly" = 12, "monthly" = 1)
  
  ## Get max date ----
  max_date <- format_date(max_date)
  message(paste("Maximum date is", max_date))
  
  ## Initial cleaning ----
  raw_events <- arrow::read_parquet(wahis_epi_events_downloaded) |>
    dplyr::filter(terra_aqua == "terrestrial") |>
    dplyr::mutate_at(dplyr::vars(dplyr::contains("date")), as.Date) |>
    dplyr::mutate(
      iso_code = toupper(iso_code) |>
        (\(x) ifelse(x == "SCG", "SRB", x))()
    ) |>
    dplyr::rename(
      country_iso3c = iso_code,
      disease = standardized_disease_name
    )
  
  ## Process dates from the outbreak table to fill in missing end date values in events table ----
  outbreaks <- arrow::read_parquet(wahis_outbreaks_downloaded) |>
    dplyr::select(epi_event_id_unique, outbreak_start_date, outbreak_end_date) |> 
    dplyr::mutate_at(dplyr::vars(dplyr::contains("date")), as.Date) |> 
    dplyr::group_by(epi_event_id_unique) |> 
    dplyr::summarize(outbreak_end_date = lubridate::floor_date(max(outbreak_end_date, na.rm = FALSE), "month")) |> # NA would mean it's still ongoing  
    dplyr::ungroup()
  
  ## Get start and end dates for each outbreak ----
  one_step_ahead <- switch(time_scale,
                           "yearly" = max_date + lubridate::years(1),
                           "monthly" = max_date %m+% months(1)
  )
  dummy_future_date <- lubridate::floor_date(Sys.Date() + lubridate::years(1), unit = "month") # this is needed as a closing date for unfinished outbreaks.  (one_step_ahead could be before a disease starts if we are filtering back in time)
  
  assertthat::are_equal(sum(is.na(raw_events$event_start_date)), 0)
  events <- raw_events |>
    dplyr::mutate(
      event_start_date = lubridate::floor_date(event_start_date, "month"),
      event_closing_date = lubridate::floor_date(event_closing_date, "month")
    ) |>
    dplyr::distinct(epi_event_id_unique, country_iso3c, disease, event_start_date, event_closing_date)  |>
    dplyr::left_join(outbreaks, by = dplyr::join_by(epi_event_id_unique))  |> 
    dplyr::mutate(event_closing_date = dplyr::coalesce(event_closing_date, outbreak_end_date))  |> # if the event closing date is NA, use the maximum closing date from the outbreak report
    dplyr::mutate(event_closing_date = if_else(is.na(event_closing_date), dummy_future_date, event_closing_date)) |> # assume NAs in end dates are not resolved or endemic
    dplyr::select(-outbreak_end_date, -epi_event_id_unique)
  
  ## Expand from start and closing date to include all months in between as rows ----
  ## for each row, indicate if the outbreak is new or ongoing apply logic that 
  ## if a country already has an outbreak ongoing, a new outbreak cannot start
  events <- events |>
    dplyr::mutate(
      month = purrr::map2(
        event_start_date, event_closing_date, ~ seq(.x, .y, by = "1 month")
      )
    ) |>
    tidyr::unnest(month) |>
    dplyr::mutate(
      outbreak_start = month == event_start_date,
      outbreak_ongoing = month != event_start_date
    ) |>
    dplyr::select(-event_start_date, -event_closing_date) |>
    dplyr::distinct() |>
    dplyr::group_by(country_iso3c, disease, month) |>
    dplyr::summarize(
      outbreak_start = any(outbreak_start),
      outbreak_ongoing = any(outbreak_ongoing),
      .groups = "drop"
    ) |>
    dplyr::mutate(outbreak_start = ifelse(outbreak_ongoing, FALSE, outbreak_start))
  
  ## Now get a full dataset by adding in months for when outbreak is not happening ----
  all_combos <- events |>
    tidyr::expand(
      country_iso3c,
      disease,
      month = seq(
        from =  lubridate::ymd("2005-01-01"), # start of record keeping
        to = one_step_ahead,
        by = "months"
      )
    )
  
  ## Expand events to all combos ----
  events <- dplyr::left_join(all_combos, events, by = dplyr::join_by(country_iso3c, disease, month)) |>
    dplyr::mutate(dplyr::across(c(outbreak_start, outbreak_ongoing), ~tidyr::replace_na(., FALSE)))
  
  ## Identify endemic events from nowcast model ----
  if(!is.null(nowcast)){
    
    assertthat::assert_that(identical(names(nowcast), c("country_iso3c", "disease", "report_period", "disease_status", "imputed")))
  
    ### Filter nowcast predictions to match diseases and countries in outbreak data
    nowcast <- nowcast |> 
      dplyr::filter(disease %in% unique(events$disease))  |> 
      dplyr::filter(country_iso3c %in% unique(events$country_iso3c))  |> 
      dplyr::filter(disease_status == "present")  
    
    ### Only use nowcast predictions for diseases that have appeared in the continent
    nowcast <- nowcast |> 
      mutate(continent = suppressWarnings(countrycode::countrycode(country_iso3c, "iso3c", "continent"))) 
    
    nowcast_disease_continent_lookup <- nowcast |> 
      filter(!imputed) |> 
      distinct(continent, disease) |> 
      drop_na()
    
    nowcast <- left_join(nowcast_disease_continent_lookup, nowcast)
    
    ### Expand nowcast from semester to months 
    year_lookup <- nowcast |>
      dplyr::distinct(report_period) |> 
      dplyr::mutate(report_period_string = stringr::str_split(format(report_period, nsmall = 1), "\\.")) |> 
      dplyr::mutate(report_semester = purrr::map_chr(report_period_string, ~.[[2]])) |> 
      dplyr::mutate(report_year = as.integer(purrr::map_chr(report_period_string, ~.[[1]]))) |> 
      dplyr::mutate(
        month = dplyr::case_when(
          report_semester == 0 ~ list(seq(1, 6)),
          report_semester == 5 ~ list(seq(7, 12))
        )
      )  |> 
      tidyr::unnest(month) |> 
      dplyr::mutate(month = lubridate::ymd(paste(report_year, month, "01"))) |> 
      dplyr::select(-report_period_string, -report_semester, -report_year)
    
    nowcast <- dplyr::left_join(nowcast, year_lookup, relationship = "many-to-many", by = dplyr::join_by(report_period)) |> 
      dplyr::select(-report_period, -imputed) 
    
    events <- dplyr::full_join(events, nowcast, by = dplyr::join_by(country_iso3c, disease, month)) |> 
      dplyr::mutate(endemic = dplyr::case_when(
        !is.na(disease_status) & !outbreak_start ~ TRUE, # reported in 6 months and not marked as outbreak (if it's an outbreak, we want to keep it as an outbreak)
        !is.na(disease_status) & is.na(outbreak_start) ~ TRUE, # reported in 6 month and not in outbreak reports
        !is.na(disease_status) & outbreak_ongoing ~ TRUE, # reported in 6 months and marked as continuing outbreak (this would be filtered out as a continuing outbreak anyway)
        .default = FALSE)) |> 
      dplyr::select(-disease_status) |> 
      dplyr::mutate(outbreak_start = tidyr::replace_na(outbreak_start, FALSE), 
                    outbreak_ongoing = tidyr::replace_na(outbreak_ongoing, FALSE))
    
  }else{
    ## No nowcast
    events$endemic <- FALSE
  }
  
  ## Filter for one year ahead of max date  ----
  # assign disease status to NA for anything in between max date and one year
  events <- events |> 
    dplyr::filter(month <= one_step_ahead)  |> 
    dplyr::mutate(dplyr::across(c(outbreak_start, outbreak_ongoing, endemic), ~dplyr::if_else(month > max_date, NA, .)))
  
  ## Add rolling windows and lag windows to support joins in augmentation ----
  # Note that if the number of months is not evenly divisible by 12, the first group (2005) will not have a full 12 month lag window
  # this is okay, because we filter 2005 from the model training (as we do not have 2004 disease data to inform the predictions)
  window_lookup <- tibble(month = rev(seq(min(events$month), max(events$month), by  = "month"))) |> 
    dplyr::mutate(window_group = (seq_along(month) - 1) %/% window_size) |> 
    dplyr::group_by(window_group) |> 
    dplyr::mutate(prediction_window = paste(min(month), "to", max(month))) |> 
    dplyr::mutate(lag_prediction_window = paste(min(month)-months(window_size), "to", max(month)-months(window_size))) |> 
    dplyr::mutate(lag_prediction_window_list = list(seq(min(month)-months(window_size), max(month)-months(window_size), by  = "month"))) |> 
    dplyr::ungroup() |> 
    dplyr::select(-window_group)
  
  events <- events |> dplyr::left_join(window_lookup, by = dplyr::join_by(month))
  
  assertthat::assert_that(!any(is.na(events$prediction_window)))
  
  ## Aggregate over windows ----
  # This works on monthly and yearly scale, but is slow and necessary on monthly
  if(time_scale != "monthly"){
    events <- events |>
      dplyr::group_by(country_iso3c, disease, prediction_window, lag_prediction_window, lag_prediction_window_list) |> 
      dplyr::summarize(
        outbreak_start = any(outbreak_start), # if any outbreak started in the window
        outbreak_ongoing = any(outbreak_ongoing) & !any(outbreak_start), # if no outbreak started but the disease was ongoing from a previous window
        endemic = any(endemic) & !any(outbreak_start), # if no outbreak started but the disease was endemic
        .groups = "drop"
      ) |> 
      dplyr::ungroup()
  }
  
  ## Remove the future prediction window if this is just for training ----
  if(training){
    events <- tidyr::drop_na(events, outbreak_start)
  }
  
  ## Add feature for whether there has been a previous outbreak
  # NA in 2005 dates is okay because will be filtered out
  events <- events |> 
    arrange(country_iso3c, disease, prediction_window) |> 
    group_by(country_iso3c, disease) |> 
    mutate(outbreak_previous = cumsum(tidyr::replace_na(outbreak_start, 0))>1|cumsum(tidyr::replace_na(endemic, 0))>1) |> 
    ungroup()

  return(events)
}