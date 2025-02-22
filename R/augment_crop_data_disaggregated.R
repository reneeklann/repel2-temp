#' Augment Crop Outbreak Data
#'
#' This function augments the crop outbreak data from EPPO, IPPC, and NAPPO 
#' by combining various datasets related to disease outbreaks, country 
#' characteristics, trade, and more. The augmented data is prepared for further 
#' analysis and modeling.
#'
#' @param connect_crop_outbreaks
#' @param extracted_data_processed
#' @param country_yearly_gdp
#' @param country_yearly_human_population
#' @param country_yearly_crop_production
#' @param connect_static_shared_borders
#' @param connect_static_wildlife_migration
#' @param connect_yearly_fao_trade_crop
#' @param connect_yearly_comtrade_crop
#' @param connect_yearly_comtrade_crop_file
#' @return
#' @export
augment_crop_data_disaggregated <- function(connect_crop_outbreaks, 
                                            extracted_data_processed, 
                                            country_yearly_gdp, 
                                            country_yearly_human_population, 
                                            country_yearly_crop_production, 
                                            connect_static_shared_borders, 
                                            connect_static_wildlife_migration, 
                                            connect_yearly_fao_trade_crop, 
                                            connect_yearly_comtrade_crop
                                            # connect_yearly_comtrade_crop_file
                                            ) {
  
  # targets::tar_load(connect_crop_outbreaks)
  
  # targets::tar_load(connect_crop_outbreaks_for_prediction)
  # connect_crop_outbreaks <- connect_crop_outbreaks_for_prediction
  
  # targets::tar_load(extracted_data_processed)
  # targets::tar_load(country_yearly_gdp)
  # targets::tar_load(country_yearly_human_population)
  # targets::tar_load(country_yearly_crop_production)
  # targets::tar_load(connect_static_shared_borders)
  # targets::tar_load(connect_static_wildlife_migration)
  # targets::tar_load(connect_yearly_fao_trade_crop)
  # targets::tar_load(connect_yearly_comtrade_crop)
  # targets::tar_load(connect_yearly_comtrade_crop_file)
  
  assertthat::has_name(
    connect_crop_outbreaks,
    c("country_iso3c", "disease", "prediction_window", "lag_prediction_window",
      "outbreak_start", "outbreak_ongoing")
  )
  
  # Expand connect_crop_outbreaks to get lag years for joining ---------
  # assign weight to lag year
  # this was developed for the yearly pipeline, so it is redundant and slow for the monthly pipeline
  outbreak_status <- connect_crop_outbreaks |> 
    dplyr::mutate(lag_year = purrr::map(lag_prediction_window_list, lubridate::year)) |> 
    tidyr::unnest(lag_year) |> 
    dplyr::select(-lag_prediction_window_list) |> 
    dplyr::group_by_all() |> 
    dplyr::count(name = "weight") |> 
    dplyr::ungroup()

  # Remove prediction windows that include 1992 as a lag year (we do not have outbreak data prior to 1993) ---------
  prediction_window_to_remove <- outbreak_status |> 
    dplyr::filter(lag_year == 1992) |> 
    dplyr::pull(prediction_window) |> 
    unique()
  
  outbreak_status <- outbreak_status |> 
    dplyr::filter(!prediction_window %in% prediction_window_to_remove)
  
  # Disease taxonomy ---------
  # Kingdom
  taxonomy <- extracted_data_processed |>
    dplyr::select(disease, kingdom) |>
    dplyr::filter(!is.na(disease)) |>
    dplyr::distinct()
  
  outbreak_status <- dplyr::left_join(
    outbreak_status, taxonomy, by = dplyr::join_by(disease)
  )
  
  # Country characteristics ("attack surface" variables) ---------
  
  # Continent (static)
  outbreak_status <- outbreak_status |>
    dplyr::mutate(
      continent = as.factor(
        suppressWarnings(
          countrycode::countrycode(
            country_iso3c,  origin = "iso3c", destination = "continent"
          )
        )
      )
    ) |> 
    dplyr::mutate(continent = dplyr::case_when(country_iso3c %in% c("CEU", "MEL") ~ "Europe",
                                               TRUE ~ continent)) |>
    dplyr::relocate(continent, .after = country_iso3c)
  
  if(any(is.na(outbreak_status$continent))){
    unknown_countries <- unique(outbreak_status$country_iso3c[is.na(outbreak_status$continent)])
    outbreak_status <- outbreak_status |> 
      dplyr::filter(!country_iso3c %in% unknown_countries)
    connect_crop_outbreaks <- connect_crop_outbreaks |> 
      dplyr::filter(!country_iso3c %in% unknown_countries)
    warning(paste("Country codes", paste(unknown_countries, collapse = ", "), "unrecognized. Removing from the dataset."))
  }
  
  # GDP (yearly)
  gdp <- country_yearly_gdp |>
    dplyr::select(country_iso3c, year, gdp_dollars)
  
  outbreak_status <- dplyr::left_join(
    outbreak_status, gdp, by = c("country_iso3c", "lag_year" = "year")
  ) |>
    dplyr::mutate(log_gdp_dollars = prepvar(gdp_dollars, trans_fn = log10)) |>
    dplyr::select(-gdp_dollars)
  
  # Human populations (yearly)
  hpop <- country_yearly_human_population |>
    dplyr::select(country_iso3c, year, human_population)
  
  outbreak_status <- dplyr::left_join(
    outbreak_status, hpop, by = c("country_iso3c", "lag_year" = "year")) |>
    dplyr::mutate(
      log_human_population = prepvar(human_population, trans_fn = log10)
    ) |>
    dplyr::select(-human_population)
  
  # Yearly crop production
  # For now sum production of all crops
  crop_production <- country_yearly_crop_production |>
    dplyr::group_by(country_iso3c, year) |>
    dplyr::summarize(total_production = sum(value)) |>
    dplyr::ungroup()
  
  outbreak_status <- dplyr::left_join(
    outbreak_status, crop_production, by = c("country_iso3c", "lag_year" = "year")) |>
    dplyr::mutate(
      log_crop_production = prepvar((total_production + 1), trans_fn = log10)
    ) |>
    dplyr::select(-total_production)
  
  # Get disease status for connect variables (i.e., travel and trade from outbreak locations) ---------
  
  # Which countries have disease outbreak in a given time period?
  disease_status_present <- connect_crop_outbreaks |>
    dplyr::filter(outbreak_start | outbreak_ongoing) |>
    dplyr::select(country_origin = country_iso3c, 
                  present_window = prediction_window, # rename for clarity, this is window in which diseases were present
                  disease)
  
  outbreak_status <- outbreak_status |>
    dplyr::mutate(outbreak_start = as.integer(outbreak_start))
  
  # Set up country origin/destination combinations
  # Origin is countries that have the disease present during the lag window
  # Destination is the country we are predicting
  outbreak_status <- outbreak_status |>
    dplyr::left_join(
      disease_status_present, 
      by = dplyr::join_by(lag_prediction_window == present_window, "disease"),
      relationship = "many-to-many"
    ) |>
    dplyr::rename(country_destination = country_iso3c) |>
    # don't want to filter cases where country_origin == country_destination 
    # because if a given destination has only one origin (itself), it will be fully removed from the data
    dplyr::mutate(
      country_origin = dplyr::if_else(
        country_origin == country_destination, NA_character_, country_origin 
      )
    ) |>
    dplyr::relocate(country_origin, .before = country_destination)
  
  # Identify if the disease is present anywhere in the world
  disease_status_present_any <- disease_status_present |>
    dplyr::distinct(present_window, disease) |>
    dplyr::mutate(disease_present_anywhere = TRUE)
  
  outbreak_status <- outbreak_status |>
    dplyr::left_join(
      disease_status_present_any, 
      by = dplyr::join_by(lag_prediction_window == present_window, "disease"),
    ) |>
    dplyr::mutate(
      disease_present_anywhere = tidyr::replace_na(disease_present_anywhere, FALSE)
    )
  
  # Static connect variables ---------
  
  # Shared borders 
  borders <- connect_static_shared_borders |>
    dplyr::mutate(shared_border = as.logical(shared_border)) |>
    dplyr::select(-source)
  
  outbreak_status <- dplyr::left_join(
    outbreak_status, borders, by = c("country_destination", "country_origin")
  ) |>
    dplyr::relocate(shared_border, .after = continent)
  
  # Migratory wildlife
  wildlife <- connect_static_wildlife_migration |>
    dplyr::mutate(n_migratory_wildlife = as.integer(n_migratory_wildlife)) |>
    dplyr::select(-source, -imputed_value)
  
  outbreak_status <- dplyr::left_join(
    outbreak_status, wildlife, by = c("country_destination", "country_origin")
  )
  
  # Time-varying (yearly) connect variables ---------
  
  # Country destination and origins are set up to reflect the offset
  # If we are predicting disease in country x in 2022, it is joined with country origins from 2021
  
  # FAO crop trade 
  fao_trade <- connect_yearly_fao_trade_crop |>
    dplyr::mutate(year = as.integer(year)) |> 
    dplyr::select(-source, -imputed_value)
  
  outbreak_status <- dplyr::left_join(
    outbreak_status, fao_trade, 
    by = c("country_destination", "country_origin", "lag_year" = "year")
  )
  
  # COMTRADE
  # connect_yearly_comtrade_crop <- read.csv(connect_yearly_comtrade_crop_file)
  comtrade_trade <- connect_yearly_comtrade_crop |>
    dplyr::mutate(year = as.integer(year)) |> 
    dplyr::select(-source, -imputed_value)
  
  outbreak_status <- dplyr::left_join(
    outbreak_status, comtrade_trade, 
    by = c("country_destination", "country_origin", "lag_year" = "year")
  )
  
  # Post Processing ---------
  
  # Summarize by country origin and prediction window (~60 seconds to run)
  # takes the weighed average across the years in the lag prediction window
  # every row will be a unique combination of country_destination, country_origin, prediction_window, disease
  # weighting will treat NAs as 0s
  outbreak_status <- outbreak_status |>
    dplyr::select(-lag_prediction_window) |>
    dplyr::group_by(country_destination, country_origin,
                    disease, kingdom, prediction_window,
                    outbreak_start, outbreak_ongoing, disease_present_anywhere,
                    continent, shared_border) |>
    dplyr::summarize(dplyr::across(c(log_gdp_dollars,
                                     log_human_population,
                                     log_crop_production,
                                     n_migratory_wildlife,
                                     fao_crop_quantity,
                                     comtrade_dollars),
                                   ~sum(. * weight, na.rm = TRUE)/ sum(weight))) |>
    dplyr::ungroup()
  
  # For disaggregated imports, remove NAs in country_origins, unless there are
  # no imports at all, as we do not want to lose country record
  outbreak_status <- outbreak_status |>
    dplyr::group_by(country_destination, continent, disease, prediction_window) |> 
    dplyr::mutate(no_origin = all(is.na(country_origin))) |>
    dplyr::ungroup() |>
    dplyr::filter(!(!no_origin & is.na(country_origin))) |> 
    # removing na if country/disease has at least one country_origin
    dplyr::select(-no_origin)
  
  # Data check against expected country, disease, windows
  country_disease_window_combo <- connect_crop_outbreaks |> 
    # dplyr::filter(!disease %in% diseases_not_in_taxa_lookup) |> 
    dplyr::filter(!prediction_window %in% prediction_window_to_remove) |> 
    dplyr::distinct(country_destination = country_iso3c, disease, prediction_window) |> 
    dplyr::arrange(country_destination, disease, prediction_window)
  check <- outbreak_status |> 
    dplyr::distinct(country_destination, disease, prediction_window) |> 
    dplyr::arrange(country_destination, disease, prediction_window)
  assertthat::assert_that(identical(country_disease_window_combo, check))
  
  outbreak_status <- outbreak_status |>
    dplyr::mutate(
      outbreak_start = outbreak_start > 0,
      # endemic = endemic > 0,
      outbreak_ongoing = outbreak_ongoing > 0,
      shared_border = as.integer(shared_border)
    )
  
  outbreak_status <- outbreak_status |>
    dplyr::select(
      country_iso3c = country_destination,
      continent,
      country_origin,
      disease,
      kingdom,
      disease_present_anywhere,
      prediction_window,
      log_gdp_dollars,
      log_human_population,
      log_crop_production, 
      outbreak_start,
      outbreak_ongoing, 
      n_migratory_wildlife_from_outbreaks = n_migratory_wildlife,
      shared_borders_from_outbreaks = shared_border,
      comtrade_dollars_from_outbreaks = comtrade_dollars,
      fao_crop_quantity_from_outbreaks = fao_crop_quantity,
      dplyr::everything()
    )
  
  return(outbreak_status)
}
