#'
#' Augment WAHIS six month dataset with border country, taxa population, human
#' population, and veterinarian population
#' 
#' @param country_livestock_six_month_disease
#' @param country_yearly_human_population
#' @param wahis_disease_taxa_lookup
#' @param country_yearly_taxa_population
#' @param country_yearly_vet_population
#' @param connect_static_shared_borders
#'
#'
#'
augment_wahis_six_months <- function(country_livestock_six_month_disease_status,
                                     country_yearly_gdp,
                                     country_yearly_human_population,
                                     country_yearly_taxa_population,
                                     country_yearly_vet_population,
                                     connect_static_shared_borders
) {
  
  ## Create lag periods and corresponding lag years ----
  ## (for matching with yearly data)
  
  # We are predicting disease status for the year-semester based on the status/case lags from 6, 12, and 18 months
  # For attack surface vars, let's just use 6 month lags
  
  six_month_disease_status <- country_livestock_six_month_disease_status |>
    dplyr::mutate(
      year_lag_6 = floor(report_period - 0.5)
    )
  
  ## GDP (yearly) ----
  gdp <- country_yearly_gdp |>
    dplyr::select(country_iso3c, year, gdp_dollars)
  
  six_month_disease_status <- dplyr::left_join(
    six_month_disease_status, gdp,  by = c("country_iso3c", "year_lag_6" = "year")
  ) |>
    dplyr::mutate(missing_gdp = is.na(gdp_dollars)) |> 
    dplyr::mutate(
      log_gdp_dollars_year_lag_6 = prepvar(gdp_dollars, trans_fn = log10)
    ) |>
    dplyr::select(-gdp_dollars) 
  
  ## Human populations (yearly) ----
  hpop <- country_yearly_human_population |>
    dplyr::select(country_iso3c, year, human_population)
  
  six_month_disease_status <- dplyr::left_join(
    six_month_disease_status, hpop,  by = c("country_iso3c", "year_lag_6" = "year")
    ) |>
    dplyr::mutate(missing_human_population = is.na(human_population)) |> 
    dplyr::mutate(
      log_human_population_year_lag_6 = prepvar(human_population, trans_fn = log10)
    ) |>
    dplyr::select(-human_population)
  
  # Target taxa population (yearly)
  # e.g. for ASF, how many swine are there in the country?
  taxa_population <- country_yearly_taxa_population
  
  #assertthat::assert_that(length(setdiff(unique(taxa_population$disease), unique(six_month_disease_status$disease))) == 0)# all diseases in the taxa lookup are represented in the actual data

  six_month_disease_status <- six_month_disease_status |> 
    dplyr::left_join(taxa_population,  by = c("country_iso3c", 
                                              "year_lag_6" = "year", 
                                              "disease")
    ) |>
    dplyr::mutate(missing_taxa_population = is.na(target_taxa_population)) |> 
    dplyr::mutate(
      log_taxa_population_year_lag_6 = prepvar(
        (target_taxa_population + 1),
        trans_fn = log10
      )
    ) |>
    dplyr::select(-target_taxa_population)
  
  # Vet capacity (yearly)
  vets <- country_yearly_vet_population |>
    dplyr::select(country_iso3c, year, veterinarian_count)
  
  six_month_disease_status <- dplyr::left_join(
    six_month_disease_status, vets,  by = c("country_iso3c", "year_lag_6" = "year")
    ) |>
    dplyr::mutate(missing_veterinarian_count = is.na(veterinarian_count)) |> 
    dplyr::mutate(
      log_veterinarians_year_lag_6 = prepvar((veterinarian_count + 1), trans_fn = log10)
    ) |>
    dplyr::select(-veterinarian_count)
  
  # Get disease status for connect variables (i.e., travel and trade from outbreak locations) ---------
  # Which countries have disease outbreak in a given time period?
  # Shared borders 
  borders <- connect_static_shared_borders |>
    dplyr::mutate(shared_border = as.logical(shared_border)) |>
    dplyr::filter(shared_border) |> 
    dplyr::select(country_iso3c = country_origin, country_border = country_destination)
    
  border_lookup <- country_livestock_six_month_disease_status |> 
    dplyr::select(country_border = country_iso3c, report_period, disease, disease_status_lag_6, disease_status_lag_12, disease_status_lag_18) |> 
    dplyr::distinct() |> 
    tidyr::pivot_longer(cols = c(disease_status_lag_6, disease_status_lag_12, disease_status_lag_18),
                        names_to = "lag_period", values_to = "status"
                          ) 

  border_lookup <- dplyr::left_join(borders, border_lookup, 
                              by = dplyr::join_by(country_border),
                              relationship = "many-to-many") |> 
    dplyr::group_by(country_iso3c, report_period, disease) |> 
    dplyr::summarize(shared_border_disease_status_6_12_18 = ifelse("present" %in% status, "present",
                                                         ifelse("absent" %in% status, "absent",
                                                                "missing"))) |>
    dplyr::ungroup() 
  
  dupes <- border_lookup |> janitor::get_dupes(country_iso3c, report_period, disease)
  assertthat::assert_that(nrow(dupes)==0)

  six_month_disease_status <- dplyr::left_join(
    six_month_disease_status, border_lookup,  by = c("country_iso3c", "report_period", "disease")
  )  |> 
    dplyr::mutate(shared_border_disease_status_6_12_18 = tidyr::replace_na(shared_border_disease_status_6_12_18, "missing"))
    
  
  # Output
  six_month_disease_status <- six_month_disease_status |>
    dplyr::select(-year_lag_6, dplyr::starts_with("report_period")) |> 
    mutate_if(is.character, as.factor) |> 
    mutate_if(is.logical, as.double) 
  
  assertthat::assert_that(!any(map_lgl(six_month_disease_status, ~any(is.na(.)))))
  
  return(six_month_disease_status)
}

