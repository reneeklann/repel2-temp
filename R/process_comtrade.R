#' Process UN COMTRADE trade data
#'
#' This function processes the UN Comtrade data, including data 
#' transformation and imputation.
#' 
#' @param download_directory Path to downloaded directory containing all downloaded files
#' @param all_connect_countries_years Target containing all combinations of country ISO code pairs and year
#'
#' @return A tibble containing processed bilateral comtrade 
#'   data, including the origin country, destination country, and source.
#'   
#' @example
#' process_comtrade(download_files = comtrade_livestock_downloaded,  start_date = 2000, all_connect_countries_years)
#'
#' @export
#' 
process_comtrade <- function(download_files,
                             start_date,
                             all_connect_countries_years,
                             comtrade_download_check,
                             ...) {
  
  # Check if current download has expected and required fields ----
  if (!comtrade_download_check)
    stop("Downloaded Comtrade dataset doesn't have expected field names.
         Please verify and adjust Comtrade processing function accordingly.")
  
  # Do not include empty files in dataset
  download_files <- download_files[!stringr::str_detect(download_files, "empty")]
  
  comtrade <- arrow::open_dataset(download_files)
  
  # # cmd code lookup 
  # cmd_code_lookup <- comtrade |> dplyr::distinct(cmdCode, cmdDesc) |> dplyr::collect()
  
  # cmd code lookup - variables are in snake case
  cmd_code_lookup <- comtrade |> dplyr::distinct(cmd_code, cmd_desc) |> dplyr::collect()
  
  # # Initial processing
  # comtrade <- comtrade |>
  #   dplyr::select(year = period,
  #                 reporter_iso = reporterISO,
  #                 partner_iso = partnerISO,
  #                 flow_desc = flowDesc, 
  #                 commodity_code = cmdCode,
  #                 value = primaryValue) |>
  #   dplyr::mutate(year = as.integer(year)) |>
  #   dplyr::filter(!is.na(value))
  
  # Initial processing - variables are in snake case
  comtrade <- comtrade |>
    dplyr::select(year = period,
                  reporter_iso,
                  partner_iso,
                  flow_desc, 
                  commodity_code = cmd_code,
                  value = primary_value) |>
    dplyr::mutate(year = as.integer(year)) |>
    dplyr::filter(!is.na(value))
  
  # # Check: are there multiple reports per year? Should be 1 but a few dupes from ISR to A79 in the mid 90s crop data
  # comtrade |>
  #   group_by(year, reporter_iso, partner_iso, commodity_code, flow_desc) |>
  #   count() |>
  #   ungroup() |>
  #   distinct(n) |>
  #   collect()
  
  # Add re-imports and re-exports into total import and export values
  comtrade <- comtrade |> 
    dplyr::mutate(flow_desc = tolower(stringr::str_remove(flow_desc, "Re-"))) |> 
    dplyr::group_by(year, reporter_iso, partner_iso, commodity_code, flow_desc) |>
    dplyr::summarize(value = sum(value)) |> 
    dplyr::ungroup()
  
  # assign country destination and origin
  # for trades reported more than once (as import and export), assume max value
  comtrade_bilateral <- comtrade |> 
    dplyr::mutate(country_origin = ifelse(flow_desc == "export", reporter_iso, partner_iso)) |> 
    dplyr::mutate(country_destination = ifelse(flow_desc == "export", partner_iso, reporter_iso)) |> 
    dplyr::select(-flow_desc, -reporter_iso, -partner_iso)   |> 
    dplyr::group_by(year, commodity_code, country_origin, country_destination) |>
    arrow::to_duckdb() |> # duckdb required for moving window functions
    dplyr::filter(value == max(value, na.rm = TRUE)) |> 
    arrow::to_arrow() |> 
    dplyr::distinct() |>
    dplyr::ungroup() 
  
  # now aggregate over commodity code, by year-origin-destination
  comtrade_bilateral_summary <- comtrade_bilateral |> 
    dplyr::group_by(year, country_origin, country_destination) |>
    dplyr::summarize(comtrade_dollars = sum(value)) |>
    dplyr::ungroup() |> 
    dplyr::filter(year > start_date) |> 
    dplyr::collect()
  
  # join into all_connect_countries_years
  comtrade_bilateral_summary_all <- comtrade_bilateral_summary |>
    dplyr::right_join(
      y = all_connect_countries_years, 
      by = c("year", "country_origin", "country_destination")
    ) |>
    dplyr::arrange(year, country_origin, country_destination) |>
    dplyr::group_split(country_origin, country_destination) |> 
    purrr::map_dfr(~na_interp(., "comtrade_dollars")) |>
    dplyr::mutate(imputed_value = ifelse(is.na(comtrade_dollars), TRUE, imputed_value)) |> 
    #dplyr::mutate(comtrade_dollars = tidyr::replace_na(comtrade_dollars, 0)) |> 
    dplyr::mutate(source = "COMTRADE")
  
  return(comtrade_bilateral_summary_all)
  
}
