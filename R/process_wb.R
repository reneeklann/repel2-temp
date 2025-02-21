
#' Process World Bank GDP and human population data
#'
#' This function processes the World Bank data by joining it with a tibble 
#' containing all countries and years combination, performing interpolation for 
#' missing values, and adding a source label.
#'
#' @param download_file Path to downloaded data file
#' @param field_name What to name the value field. Either "gdp_dollars" or "human_population"
#' @param all_countries_years Target containing all combinations of country ISO codes and year
#'
#' @return A tibble with the processed data, including interpolated values 
#'   for missing data and a source label.
#'
#' @example
#' process_wb(download_file = "data-raw/wb-human-population/SP.POP.TOTL.gz.parquet", field_name = "human_population", all_countries_years)
#'
#' @export
#' 
process_wb <- function(download_file, 
                       field_name, 
                       all_countries_years, 
                       index_fields = c("countryiso3code", "date", "value")) {
  ## Read WB GDP dataset for parquet download ----
  x <- arrow::open_dataset(download_file)
  
  ## Check if dataset has expected field names ----
  check_wb_download(x, index_fields = index_fields)
  
  ## Process WB GDP dataset ----
  x <- x |> 
    dplyr::select(country_iso3c = countryiso3code, year = date, value) |> 
    dplyr::filter(country_iso3c != "") |>
    dplyr::mutate(year = as.integer(year)) |> 
    dplyr::rename(!!field_name := value) |> 
    dplyr::right_join(all_countries_years, by = c("country_iso3c", "year")) |>
    dplyr::arrange(country_iso3c, year) |> 
    dplyr::collect() |> 
    dplyr::group_split(country_iso3c) |> 
    purrr::map_dfr(~na_interp(., field_name)) |>
    dplyr::mutate(source = "WB")
  
  return(x)
}



