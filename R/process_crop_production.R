#' Process FAO crop production data
#'
#' This function processes crop production data by joining it with a tibble 
#' containing all countries and years combination, performing interpolation for 
#' missing values, and adding a source label.
#'
#' @param download_file Path to downloaded data file
#' @param all_countries_years Target containing all combinations of country ISO codes and year
#'
#' @return A tibble with the processed data, including interpolated values 
#'   for missing data and a source label.
#'
#' @example
#' process_crop_production(download_file = "data-raw/fao-production/Production_Crops_Livestock_E_All_Data_(Normalized).gz.parquet", fao_crop_production_item_codes, all_countries_years)
#'
#' @export
#' 
process_crop_production <- function(download_file,
                                    fao_crop_production_item_codes,
                                    all_countries_years) {
  
  
  fao_crop_production <- arrow::open_dataset(download_file) |> 
    dplyr::select(area = Area, item_code = Item.Code, item = Item, 
                  element = Element, year = Year, unit = Unit, value = Value) |>
    dplyr::filter(element == "Production") |>
    dplyr::filter(item_code %in% fao_crop_production_item_codes) |>
    dplyr::filter(!is.na(value))
  
  # remove area "China" (keep "China, mainland") so iso3c "CHN" isn't double-counted
  fao_crop_production <- fao_crop_production |>
    dplyr::filter(area != "China")
  
  # get country iso3c
  fao_countries <- fao_crop_production |> 
    dplyr::distinct(area) |> 
    dplyr::collect() |> 
    dplyr::mutate(area_utf8 = iconv(area, from = "latin1", to = "UTF-8")) |> 
    dplyr::mutate(country_iso3c = suppressWarnings(countrycode::countrycode(
      area_utf8, origin = "country.name", destination = "iso3c"
    ))) |> 
    dplyr::select(-area_utf8)
  
  fao_crop_production <- fao_crop_production |>
    dplyr::left_join(fao_countries, by = "area") |> 
    dplyr::filter(!is.na(country_iso3c)) |> 
    dplyr::collect() 
  
  all_countries_years_crop_items <- all_countries_years |>
    tidyr::crossing(dplyr::tibble(item_code = unique(fao_crop_production$item_code)))
  
  fao_crop_production <- fao_crop_production |>
    dplyr::right_join(
      y = all_countries_years_crop_items, 
      by = c("country_iso3c", "year", "item_code")
    ) |>
    dplyr::arrange(country_iso3c, item_code, year) |>
    dplyr::group_split(country_iso3c, item_code) |>
    purrr::map_dfr(~na_interp(., "value")) |>
    dplyr::mutate(imputed_value = ifelse(is.na(value), TRUE, imputed_value)) |> 
    dplyr::mutate(value = replace_na(value, 0)) |> 
    dplyr::mutate(source = "FAO")
  
  return(fao_crop_production)
}
