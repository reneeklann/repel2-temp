#' Process Veterinary Population Data from WOAH
#'
#' This function processes annual veterinary population data from WOAH
#'
#' @param path_to_file The path to the veterinary population data XLSX file.
#' @param all_countries_years A data frame containing all combinations of 
#'   countries and years.
#'
#' @return A processed tibble of veterinary population data with interpolated values.
#'
#' @example
#' process_vet_population("data-raw/woah-vet-population/Veterinarians_Vet_paraprofessionals.gz.parquet", all_countries_years)
#'
#' @export
#' 
process_vet_population <- function(download_file,
                                   all_countries_years) {
  
  vet_data <- arrow::read_parquet(download_file)
  
  vet_data <- vet_data |>
    tidyr::pivot_longer(cols = 4:15) |>
    dplyr::rename(
      country = Country,
      country_iso3c = CountryID,
      year = Year,
      veterinarian_field = name,
      total_count = value
    ) |>
    dplyr::group_by(country_iso3c, year) %>%
    dplyr::summarize(
      veterinarian_count = matrixStats::sum2(suppressWarnings(as.integer(total_count))),
      .groups = "drop_last"
    ) |> 
    dplyr::ungroup() |>
    dplyr::right_join(all_countries_years, by = c("country_iso3c", "year")) |>
    dplyr::arrange(country_iso3c, year) |>
    dplyr::group_split(country_iso3c) |>
    purrr::map_dfr(~na_interp(., "veterinarian_count")) |>
    dplyr::mutate(source = "WOAH annual reports")
  
  return(vet_data)
}
