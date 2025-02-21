#' Processing IUCN Wildlife and GROMs Migratory Species Data
#'
#' This function performs data transformation to identify migratory species and calculate 
#' the number of migratory wildlife shared between countries.
#'
#' @param iucn_download_file The path to the file containing the IUCN wildlife data.
#' @param groms_download_file The path to the file containing the IUCN wildlife data.
#' @param all_connect_countries_years Target containing all combinations of country ISO code pairs and year
#'
#' @return A tibble containing the number of migratory wildlife shared between 
#'   countries.
#'
#' @example
#' process_wildlife_migration(iucn_download_file = "data-raw/iucn-wildlife/iucn_wildlife.gz.parquet", groms_download_file = "data-raw/groms-migratory-species/groms_migratory_species.gz.parquet", all_connect_countries_years)
#'
#' @export
#' 
process_wildlife_migration <- function(iucn_download_file,
                                       groms_download_file,
                                       all_connect_countries_years) {

  # get list of bird species from Catalogue of Life
  aves <- misc_get_bird_species()
  
  groms <- arrow::read_parquet(groms_download_file) |> 
    pull(1)
  
  # read in IUCN data and filter for migratory species 
  wildlife <- arrow::read_parquet(iucn_download_file) |>
    dplyr::select(scientific_name, country) |>
    dplyr::distinct() |>
    dplyr::filter(country != "DT") |> # disputed territory
    dplyr::filter(scientific_name %in% groms) |>
    dplyr::mutate(
      country = countrycode::countrycode(
        country, origin = "iso2c", destination = "iso3c"
      )
    ) 
  
  wildlife_grp <- wildlife |>
    dplyr::group_by(country) 
  
  wildlife_list <- dplyr::group_split(wildlife_grp) |>
    purrr::set_names(dplyr::pull(dplyr::group_keys(wildlife_grp), country))
  
  # get all possible combinations of countries and look up intersection of species
  combos <- utils::combn(
    x = unique(wildlife$country), m = 2, simplify = FALSE, FUN = sort
  )
  combo_names <- purrr::map(combos, ~paste(., collapse = "-"))
  
  wildlife_intersects <- purrr::map(combos, function(x) {
    dplyr::intersect(
      wildlife_list[[x[1]]]$scientific_name, 
      wildlife_list[[x[2]]]$scientific_name
    )
  }) |> 
    purrr::set_names(combo_names)
  
  # generate tibble of number animals shared by countries
  wildlife_intersects_count <- purrr::imap_dfr(
    wildlife_intersects, 
    ~dplyr::tibble(countries = .y, n_migratory_wildlife = length(.x))
  ) |>
    tidyr::separate(
      countries, into = c("country_origin", "country_destination"), sep = "-"
    ) 
  
  # because data is non-directional, copy the data for the opposite direction
  wildlife_bilateral <- wildlife_intersects_count |>
    dplyr::bind_rows(
      wildlife_intersects_count |>
        dplyr::rename(
          country_destination = country_origin, 
          country_origin = country_destination
        )
    )
  
  all_countries <- all_connect_countries_years |> 
    select(-year) |> 
    distinct()
  
  wildlife_bilateral_all <- wildlife_bilateral |>
    dplyr::right_join(all_countries) |>
    dplyr::mutate(
      imputed_value = is.na(n_migratory_wildlife),
      n_migratory_wildlife = tidyr::replace_na(n_migratory_wildlife, 0),
      source = "IUCN"
    )
  
  return(wildlife_bilateral_all)

}
