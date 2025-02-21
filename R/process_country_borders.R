#' Process Country Shared Borders from CIA World Factbook 2020 Archive
#'
#' This function processes the country shared border information obtained from 
#' the CIA World Factbook 2020 archive.
#'
#'
#' @param download_file Path to downloaded data file
#' @param all_connect_countries_years Target containing all combinations of country ISO code pairs and year
#'
#'@return A tibble containing processed bilateral country shared border 
#'   information, including the origin country, destination country, 
#'   shared border, and source.
#'   
#' @example
#' # Process GDP data from World Bank
#' process_country_borders(download_file =  "data-raw/shared-borders/281.gz.parquet", all_connect_countries_years)
#'
#' @export
#' 
process_country_borders <- function(download_file,
                                    all_connect_countries_years) {
  
  borders <- arrow::read_parquet(download_file) |> 
    janitor::clean_names() |> 
    # remove countries that do not have borders
    dplyr::mutate(
      land_boundaries = ifelse(
        stringr::str_detect(land_boundaries, "border countries"),
        land_boundaries, NA
      )
    ) |>
    tidyr::drop_na(land_boundaries) |>
    # remove note section
    dplyr::mutate(
      land_boundaries = stringr::str_split(land_boundaries, "note:")
    ) |>
    dplyr::mutate(land_boundaries = purrr::map(land_boundaries, ~.[[1]])) |>
    dplyr::mutate(
      land_boundaries = stringr::str_remove_all(land_boundaries, "\n        \n      \n      \n          metropolitan France - total:\n        2751 \n        \n      \n      \n          French Guiana - total:\n        1205")
    ) |>
    # extract section with border countries
    dplyr::mutate(
      land_boundaries = stringr::str_extract(land_boundaries, ":[^:]+$")
    ) |>
    # remove spaces and numbers and measurement units
    dplyr::mutate(
      land_boundaries = stringr::str_remove(land_boundaries, ":\n        ")
    ) |>
    dplyr::mutate(
      land_boundaries = stringr::str_remove_all(land_boundaries, "[0-9]+")
    ) |>
    dplyr::mutate(
      land_boundaries = stringr::str_remove_all(land_boundaries, " km")
    ) |>
    dplyr::mutate(
      land_boundaries = stringr::str_remove_all(land_boundaries, " \\(.*\\)|\\.")
    ) |>
    # separate rows for each bordering country
    tidyr::separate_rows(land_boundaries, sep = ",") |>
    dplyr::mutate(land_boundaries = trimws(land_boundaries))
  
  borders_bilateral <- borders |>
    dplyr::mutate_all(
      ~suppressWarnings(countrycode::countrycode(., "country.name", "iso3c"))
    ) |>
    tidyr::drop_na() |>
    purrr::set_names(c("country_origin", "country_destination"))
  
  borders_bilateral <-  dplyr::bind_rows(
    borders_bilateral,
    borders_bilateral |>
      dplyr::rename(
        country_origin = country_destination,
        country_destination = country_origin
      )
  ) |>
    dplyr::distinct() |>
    dplyr::mutate(shared_border = TRUE)
  
  all_countries <- all_connect_countries_years |> 
    select(-year) |> 
    distinct()
  
  borders_bilateral_all <- borders_bilateral |>
    dplyr::right_join(all_countries) |>
    dplyr::mutate(
      shared_border = tidyr::replace_na(shared_border, FALSE),
      source = "CIA"
    )
  
  return(borders_bilateral_all)
  
}
