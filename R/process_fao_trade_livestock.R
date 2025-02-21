#' Process FAO Livestock Trade Data
#'
#' This function processes the FAO Livestock trade data, including data 
#' transformation and imputation.
#' 
#' @param download_file Path to downloaded data file
#' @param all_connect_countries_years Target containing all combinations of country ISO code pairs and year
#'
#' @return A tibble containing processed bilateral livestock head trade 
#'   data, including the origin country, destination country, and source.
#'   
#' @example
#' process_fao_trade_livestock(download_file = "data-raw/fao-livestock-trade/Trade_DetailedTradeMatrix_E_All_Data_(Normalized).gz.parquet", all_connect_countries_years)
#'
#' @export
#' 
process_fao_trade_livestock <- function(download_file,
                                        all_connect_countries_years,
                                        check = TRUE,
                                        index_fields = c(
                                          "Reporter.Countries", "Partner.Countries", 
                                          "Item.Code", "Item", "Element.Code",
                                          "Element", "Year", "Unit", "Value",
                                          "Flag"
                                        ),
                                        index_units = c("An", "1000 An")) {
  # Read fao livestock trade download ----
  fao_livestock_trade <- arrow::open_dataset(download_file)
  
  # Check FAO download ----
  check_fao_trade_download(
    fao_livestock_trade, 
    index_fields = index_fields, 
    index_units = index_units
  )
  
  # Initial processing ----
  fao_livestock_trade <- fao_livestock_trade |> 
    dplyr::select(reporter_countries = Reporter.Countries, 
                  partner_countries = Partner.Countries, 
                  item_code = Item.Code,
                  item = Item,
                  element_code = Element.Code,
                  element = Element,
                  year = Year, 
                  unit = Unit, 
                  value = Value,
                  flag = Flag) |> 
    dplyr::filter(year >= 2000) |> 
    dplyr::filter(unit %in% c("An", "1000 An")) |>
    dplyr::filter(!is.na(value)) |>
    dplyr::mutate(value = ifelse(unit == "1000 An", value * 1000, value)) |>
    dplyr::mutate(unit = "Head") 
  
  # Check: are there multiple reports per year? Should be 1
  # fao_livestock_trade |>
  #   dplyr::group_by(year, reporter_countries, partner_countries, item_code, element) |>
  #   dplyr::count() |>
  #   dplyr::ungroup() |>
  #   dplyr::distinct(n) |>
  #   dplyr::collect()
  
  # item code lookup - this can be used to pair with target taxa population
  item_code_lookup <- fao_livestock_trade |> dplyr::distinct(item, item_code) |> dplyr::collect()
  
  # get country iso3c
  fao_countries <- fao_livestock_trade |> 
    dplyr::distinct(reporter_countries, partner_countries) |>
    dplyr::collect() |> 
    tidyr::pivot_longer(cols = c(reporter_countries, partner_countries)) |> 
    dplyr::select(country_name = value) |> 
    dplyr::distinct() |> 
    dplyr::mutate(country_name_utf8 = iconv(country_name, from = "latin1", to = "UTF-8")) |> 
    dplyr::mutate(country_iso3c = suppressWarnings(countrycode::countrycode(
      country_name_utf8, origin = "country.name", destination = "iso3c"
    ))) |> 
    dplyr::select(-country_name_utf8)
  
  fao_livestock_trade <- fao_livestock_trade |>
    dplyr::left_join(fao_countries, by = c("reporter_countries" = "country_name")) |> 
    dplyr::rename(reporter_iso = country_iso3c) |> 
    dplyr::left_join(fao_countries, by = c("partner_countries" = "country_name")) |> 
    dplyr::rename(partner_iso = country_iso3c) |> 
    dplyr::filter(!is.na(reporter_iso), !is.na(partner_iso)) |>
    dplyr::filter(reporter_iso != partner_iso) |>
    dplyr::select(year, reporter_iso, partner_iso, element, item_code, value)
  
  # assign country destination and origin
  # for trades reported more than once (as import and export), assume max value
  fao_bilateral <- fao_livestock_trade |> 
    dplyr::mutate(country_origin = ifelse(element == "Export Quantity", reporter_iso, partner_iso)) |> 
    dplyr::mutate(country_destination = ifelse(element == "Export Quantity", partner_iso, reporter_iso)) |> 
    dplyr::select(-element, -reporter_iso, -partner_iso)  |> 
    dplyr::group_by(year, item_code, country_origin, country_destination) |>
    arrow::to_duckdb() |> # duckdb required for moving window functions
    dplyr::filter(value == max(value, na.rm = TRUE)) |> 
    arrow::to_arrow() |> 
    dplyr::distinct() |>
    dplyr::ungroup() 
  
  #  now aggregate over item code, by year-origin-destination
  fao_bilateral_summary <- fao_bilateral |> 
    dplyr::group_by(year, country_origin, country_destination) |>
    dplyr::summarize(fao_livestock_heads = sum(value)) |>
    dplyr::ungroup() |> 
    dplyr::collect()
  
  # join into all_connect_countries_years
  fao_bilateral_summary_all <- fao_bilateral_summary |>
    dplyr::right_join(
      y = all_connect_countries_years, 
      by = c("year", "country_origin", "country_destination")
    ) |>
    dplyr::arrange(year, country_origin, country_destination) |>
    dplyr::group_split(country_origin, country_destination) |> 
    purrr::map_dfr(~na_interp(., "fao_livestock_heads")) |>
    dplyr::mutate(imputed_value = ifelse(is.na(fao_livestock_heads), TRUE, imputed_value)) |> 
    #dplyr::mutate(fao_livestock_heads = tidyr::replace_na(fao_livestock_heads, 0)) |> 
    dplyr::mutate(source = "FAO")

  return(fao_bilateral_summary_all)
  
}
