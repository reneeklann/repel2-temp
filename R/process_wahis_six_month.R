#' @title
#' @param wahis_six_month_status
#' @param wahis_six_month_controls
#' @param wahis_six_month_quantitative
#' @param 
#' @return
#' @export
process_wahis_six_month <- function(wahis_six_month_status_downloaded,
                                    wahis_six_month_controls_downloaded,
                                    wahis_six_month_quantitative_downloaded,
                                    max_date,
                                    training = TRUE
) {
  
  ## Get max date ----
  max_date <- stringr::str_split(max_date, "-")[[1]]
  max_year <- as.integer(max_date[[1]])
  max_semester_code <- ifelse(as.integer(max_date[[2]]) <= 6, 1, 2)
  max_report_period <- (max_year + (max_semester_code - 1) / 2) - 0.5 # get the period before to avoid data leakage from the future
  
  ## Process WAHIS six-month status dataset ----
  wahis_six_month_status <- arrow::read_parquet(wahis_six_month_status_downloaded)
  wahis_six_month_controls <- arrow::read_parquet(wahis_six_month_controls_downloaded)
  wahis_six_month_quantitative <- arrow::read_parquet(wahis_six_month_quantitative_downloaded)
  
  ### Country name and code cleaning, create continent field ----
  #### process_wahis_country() will issue a warning if there are any NAs in the countries
  wahis_six_month_status_cleaned_country <- wahis_six_month_status |> 
    dplyr::mutate(      
      country_iso3c = process_wahis_country(country),
    ) |> 
    tidyr::drop_na(country_iso3c)
  
  ### Create report_period field ----
  wahis_status <- wahis_six_month_status_cleaned_country |> 
    dplyr::mutate(report_period = year + (semester_code - 1) / 2) 
  
  ### Disease status cleaning ----
  # wahis_six_month_status |> distinct(disease_status, occurence_code)
  wahis_status <- wahis_status |> 
    dplyr::mutate(
      disease_status = case_when(disease_status == "-" ~"present", # disease limited to one or more zones 
                                 disease_status == "suspected" ~ "present", # disease suspected
                                 .default = disease_status)
    ) |>  
    dplyr::select(
      country_iso3c, #continent, 
      year, report_period,
      disease = standardized_disease_name,
      # disease_population = animal_category, # not considering disease population for now
      disease_status
    )
  
  ### Summarize by country, report period, disease --- 
  #### Here we enforce that if disease is not market as present, assume it is absent
  wahis_status <- wahis_status |> 
    dplyr::group_by(country_iso3c, report_period, disease) |> 
    dplyr::summarize(
      disease_status = ifelse(
        "present" %in% disease_status , "present", 
        "absent" 
        #ifelse("absent" %in% disease_status, "absent", "unreported")
      )
    )|> 
    dplyr::ungroup()
  
  dupes <- wahis_status |> janitor::get_dupes(country_iso3c, report_period, disease)
  assertthat::assert_that(nrow(dupes)==0)
  
  ### identify missing reports
  #### 2005 is beginning of outbreak reporting. 6 month reports begin in 2009. 
  #### We need 2005 in the range for prediction purposes - can eventually use quantitative reports to fill in the gaps
  #### Also add one to the max report period for prediction purposes
  report_period_range <- seq(2005,  max_report_period + 1, by = 0.5)
  expand_country_period <- wahis_status |> 
    dplyr::distinct(country_iso3c) |> 
    tidyr::expand(country_iso3c, report_period = report_period_range)
  
  missing_reports <- dplyr::anti_join(expand_country_period, wahis_status |> 
                                        dplyr::distinct(country_iso3c, report_period)) |> 
    dplyr::mutate(missing_report = TRUE)
  
  ### expand all possible disease-country combinations up until one year ahead from max prediction date ----
  expand_country_disease_period <- wahis_status |> 
    dplyr::distinct(country_iso3c, disease) |> 
    tidyr::expand(country_iso3c, disease, report_period = report_period_range) |> 
    dplyr::left_join(missing_reports, by = dplyr::join_by(country_iso3c, report_period)) |> 
    dplyr::mutate(missing_report = tidyr::replace_na(missing_report, FALSE))
  
  #### Bring in every combination of country-disease-period, which will create NAs in disease_status
  #### Some of these NAs will be because the full report is missing, others will be because the disease was not listed in the report (not as "present", "absent")
  #### Note there will also be NAs in missing_report if report_period_range doesn't extend to the most recent actual reports
  
  wahis_status <- dplyr::full_join(wahis_status, expand_country_disease_period, by = dplyr::join_by(country_iso3c, report_period, disease)) |> 
    dplyr::mutate(missing_disease = is.na(disease_status) & !missing_report) |> 
    dplyr::mutate(disease_status = tidyr::replace_na(disease_status, "missing"))
  
  #### Let's only predict for missing reports, should the diseases that are listed be only those that have ever been in the continent?
  wahis_status <- wahis_status |> 
    dplyr::filter(!missing_disease) |> 
    dplyr::select(-missing_disease, -missing_report)

  ## Create data.frame of lag periods ----
  ### Joining deals with missing data
  ### Alternative would be to expand for every combination of disease country year semester, use the lag function, and filter out the expanded values
  wahis_status <- wahis_status |> 
    dplyr::mutate(
      report_period_lag_6 = report_period - 0.5,
      report_period_lag_12 = report_period - 1.0,
      report_period_lag_18 = report_period - 1.5
    )
  
  wahis_status_lag_lookup <- wahis_status |> 
    dplyr::select(
      country_iso3c, report_period, 
      disease, #disease_population, taxa, 
      disease_status_lag = disease_status#, 
      #cases_lag = cases
    ) 
  
  dupes <- wahis_status_lag_lookup |> janitor::get_dupes(country_iso3c, report_period, disease)
  assertthat::assert_that(nrow(dupes)==0)
  
  ### Get lagged disease status and cases ----
  #### This could be more flexible to allow for multiple lag windows
  #### Also note that including taxa may limit the availability of lags, it could be that the taxa were reported one semester but not the previous
  wahis_status <- wahis_status |> 
    dplyr::left_join(wahis_status_lag_lookup,
                     by = dplyr::join_by(
                       country_iso3c,
                       disease,
                       #disease_population,
                       #taxa,
                       report_period_lag_6 == report_period)) |>
    dplyr::rename(disease_status_lag_6 = disease_status_lag#,
                  #cases_lag_6 = cases_lag
    ) |>
    dplyr::left_join(wahis_status_lag_lookup, 
                     by = dplyr::join_by(
                       country_iso3c, 
                       disease, 
                       #disease_population,
                       #taxa,
                       report_period_lag_12 == report_period)) |> 
    dplyr::rename(disease_status_lag_12 = disease_status_lag #,
                  #cases_lag_12 = cases_lag
    ) |> 
    dplyr::left_join(wahis_status_lag_lookup, 
                     by = dplyr::join_by(
                       country_iso3c, 
                       disease, 
                       #disease_population,
                       #taxa,
                       report_period_lag_18 == report_period)) |> 
    dplyr::rename(disease_status_lag_18 = disease_status_lag#,
                  #cases_lag_18 = cases_lag
    ) 
  
  ## Label/handle missingness ----
  wahis_status <- wahis_status |> 
    dplyr::mutate(dplyr::across(dplyr::starts_with("disease_status_lag"), ~tidyr::replace_na(., "missing"))) 

  ## Process WAHIS six-month controls dataset to get controls ----
  
  ### process_wahis_country() will issue a warning if there are any NAs in the countries
  ### Set NAs in taxa to unknown
  wahis_controls <- wahis_six_month_controls |>
    dplyr::mutate(
      country_iso3c = process_wahis_country(country),
      control_measure = stringr::str_replace_all(
        control_measure, pattern = " ", replacement = "_"
      )
    ) |> 
    tidyr::drop_na(country_iso3c) |> 
    #dplyr::mutate(taxa = tidyr::replace_na(standardized_taxon_name, "unknown")) |> 
    dplyr::distinct()  |> 
    dplyr::mutate(report_period = year + (semester_code - 1) / 2) |> 
    dplyr::select(
      country_iso3c, report_period,
      disease = standardized_disease_name,
      #disease_population = animal_category,
      #taxa,
      control_measure
    ) |> 
    dplyr::distinct()
  
  dupes <- wahis_controls |> janitor::get_dupes(country_iso3c, report_period, disease, control_measure)
  assertthat::assert_that(nrow(dupes)==0)
  
  
  control_measures <- unique(wahis_controls$control_measure)
  
  ### Pivot wide control measures 
  wahis_controls <- wahis_controls |> 
    tidyr::pivot_wider(
      names_from = control_measure, values_from = control_measure
    ) |>
    janitor::clean_names() # removes dashes
  
  dupes <- wahis_controls |> janitor::get_dupes(country_iso3c, report_period, disease)
  assertthat::assert_that(nrow(dupes)==0)
  
  ### Control fields should indicate whether the method was applied any time in the last three semesters
  ### Very cluncky approach!
  
  #### First join in controls for each lagged semester
  wahis_status <- wahis_status |> 
    dplyr::left_join(
      wahis_controls, 
      by = dplyr::join_by(country_iso3c, 
                          disease, 
                          # disease_population,
                          # taxa,
                          report_period_lag_6 == report_period
      ))|>
    dplyr::left_join(
      wahis_controls, 
      by = dplyr::join_by(country_iso3c, 
                          disease, 
                          # disease_population,
                          # taxa,
                          report_period_lag_12 == report_period
      ))|>
    dplyr::left_join(
      wahis_controls, 
      by = dplyr::join_by(country_iso3c, 
                          disease, 
                          # disease_population,
                          # taxa,
                          report_period_lag_18 == report_period
      ))
  
  #### Then iterate through each of the three merged fields and determine if the control was ever applied
  #### Rename the field to indicate "control" and over lagged months 6, 12, and 18
  for(cm in janitor::make_clean_names(control_measures)){
    wahis_status <- wahis_status |> 
      dplyr::mutate(!!paste0("control_", cm, "_6_12_18") := coalesce(!!sym(cm), !!sym(paste0(cm, ".x")), !!sym(paste0(cm, ".y")))) |> 
      dplyr::select(-paste0(cm, ".x"), -paste0(cm, ".y"), -dplyr::all_of(cm))
  }
  
  #### Set to 0s and 1s
  wahis_status <- wahis_status |> 
    dplyr::mutate(
      dplyr::across(
        .cols = dplyr::starts_with("control_"),
        .fns = function(x) ifelse(is.na(x), 0, 1)
      )
    )
  
  ## Additional "ever" variables ----
  wahis_status <- wahis_status |> 
    dplyr::group_by(country_iso3c) |> 
    dplyr::mutate(first_reporting_semester = report_period == min(report_period)) |> 
    dplyr::ungroup()
  
  ever_country <- wahis_status |> 
    dplyr::group_by(country_iso3c, disease, report_period) |> 
    dplyr::summarize(present = any(disease_status=="present")) |> 
    dplyr::ungroup() |> 
    dplyr::arrange(country_iso3c, disease, report_period) |> 
    dplyr::group_by(country_iso3c, disease) |> 
    dplyr::mutate(disease_ever_in_country = cumsum(present)>1) |> 
    dplyr::ungroup() |> 
    dplyr::select(-present)
  
  continent_lookup <- wahis_six_month_status_cleaned_country |> 
    dplyr::select(country_iso3c, continent = world_region) |> 
    dplyr::distinct()
  
  wahis_status <- wahis_status |> 
    dplyr::left_join(continent_lookup, by = dplyr::join_by(country_iso3c)) 
  
  
  ever_continent <- wahis_status |> 
    dplyr::group_by(continent, disease, report_period) |> 
    dplyr::summarize(present = any(disease_status=="present")) |> 
    dplyr::ungroup() |> 
    dplyr::arrange(continent, disease, report_period) |> 
    dplyr::group_by(continent, disease) |> 
    dplyr::mutate(disease_ever_in_continent = cumsum(present)>1) |> 
    dplyr::ungroup() |> 
    dplyr::select(-present)
  
  wahis_status <- wahis_status |> 
    dplyr::left_join(ever_country, by = dplyr::join_by(country_iso3c, disease, report_period)) |> 
    dplyr::left_join(ever_continent, by = dplyr::join_by(continent, disease, report_period))  
  
  ## Check NAs
  ### NAs in cases field are okay because it doesn't go into model
  assertthat::assert_that(!any(map_lgl(wahis_status, ~any(is.na(.)))))
  
  ## Training/prediction logic
  if(training){
    wahis_status <- wahis_status |> 
      dplyr::filter(disease_status != "missing") |> 
      dplyr::filter(report_period <= max_report_period)
  }else{
    wahis_status <- wahis_status |> 
      dplyr::filter(report_period <= (max_report_period  + 1)) # Add one to the max report period for prediction purposes
    
  }
  
  return(wahis_status)
}