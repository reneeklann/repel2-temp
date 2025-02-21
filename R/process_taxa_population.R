
#' Process FAO taxa population data
#'
#' This function processes taxa population data by joining it with a tibble 
#' containing all countries and years combination, performing interpolation for 
#' missing values, and adding a source label.
#'
#' @param download_file Path to downloaded data file
#' @param all_countries_years Target containing all combinations of country ISO codes and year
#'
#' @return A tibble with the processed data, including interpolated values 
#'   for missing data and a source label.
#'
#'
#' @export
#' 
clean_fao_taxa_population <- function(download_file,
                                      wahis_disease_taxa_lookup,
                                      index_fields = c("Area", "Item", "Year", "Unit", "Value"),
                                      index_units = c("An", "1000 An")) {
  
  # these are the taxa names in the wahis dataset
  wahis_taxa <- unique(wahis_disease_taxa_lookup$standardized_taxon_name)
  
  # read FAO taxa dataset ----
  fao_taxa <- arrow::open_dataset(download_file)
  
  # check FAO taxa dataset ----
  check_fao_taxa_download(fao_taxa, index_fields = index_fields, index_units = index_units)
  
  # filter production dataset for livestock
  fao_taxa <- fao_taxa |> 
    dplyr::select(area = Area, item = Item, year = Year, unit = Unit, value = Value) |> 
    dplyr::filter(unit %in% c("An", "1000 An")) |>
    dplyr::filter(!is.na(value)) |> 
    dplyr::mutate(value = ifelse(unit == "1000 An", value * 1000, value)) |>
    dplyr::mutate(unit = "Head")  |> 
    dplyr::filter(
      item %in% c("Asses", "Camels", "Other camelids", "Cattle", "Chickens",
                  "Goats", "Horses", "Mules", "Mules and hinnies", "Sheep",
                  "Cattle and Buffaloes", "Poultry Birds", "Sheep and Goats",
                  "Buffaloes", "Buffalo", "Ducks", "Geese and guinea fowls", 
                  "Geese", "Pigs", "Swine / pigs", "Turkeys", 
                  "Rabbits and hares", "Camelids, other", "Rodents, other",
                  "Other rodents", "Pigeons, other birds")
    )
  
  # get country iso3c
  fao_countries <- fao_taxa |> 
    dplyr::distinct(area) |> 
    dplyr::collect()  |> 
    dplyr::mutate(area_utf8 = iconv(area, from = "latin1", to = "UTF-8")) |> 
    dplyr::mutate(country_iso3c = suppressWarnings(countrycode::countrycode(
      area_utf8, origin = "country.name", destination = "iso3c"
    ))) |> 
    dplyr::select(-area_utf8) |>
    dplyr::filter(area != "China")
  
  fao_taxa <- fao_taxa |>
    dplyr::left_join(fao_countries, by = "area") |> 
    dplyr::filter(!is.na(country_iso3c)) |> 
    dplyr::collect() 
  
  fao_taxa <- fao_taxa |> 
    # recode is not arrow compatible
    dplyr::mutate(
      taxa = dplyr::recode(
        item, 
        "Asses" = "horse",
        "Camels" = "camel",
        "Other camelids" = "camel",
        "Cattle" = "cattle" ,
        "Chickens"  = "bird",
        "Goats" = "goat",
        "Horses" = "horse",
        "Mules"  = "horse",
        "Mules and hinnies" = "horse",
        "Sheep"  = "sheep",
        "Cattle and Buffaloes" = "cattle", 
        "Poultry Birds" = "bird",
        "Sheep and Goats" = "sheep/goat",
        "Buffaloes"  = "buffalo",
        "Buffalo" = "buffalo",
        "Ducks"  = "bird",
        "Geese and guinea fowls" = "bird",
        "Geese" = "bird",
        "Pigs"  = "swine",
        "Swine / pigs" = "swine",
        "Turkeys"  = "bird",
        "Rabbits and hares" = "rabbit",
        "Camelids, other" = "camel",
        "Rodents, other" = "rodent",
        "Other rodents" = "rodent",
        "Pigeons, other birds" = "bird"
      )
    ) |> 
    tidyr::drop_na(taxa)  |> 
    dplyr::group_by(country_iso3c, year, taxa) |> 
    dplyr::summarize(population = sum(value)) |> 
    dplyr::ungroup()
  
  # split sheep/goat herds 50/50
  sheep_goat <- fao_taxa |> 
    dplyr::filter(taxa == "sheep/goat") |> 
    dplyr::mutate(population = round(population/2)) |> 
    dplyr::mutate(taxa = "sheep")
  sheep_goat <- dplyr::bind_rows(sheep_goat, sheep_goat |> dplyr::mutate(taxa = "goat"))
  
  fao_taxa <- fao_taxa |> 
    dplyr::filter(taxa != "sheep/goat") |> 
    dplyr::bind_rows(sheep_goat) |> 
    dplyr::group_by(country_iso3c, year, taxa) |> 
    dplyr::summarize(population = sum(population)) |> 
    dplyr::ungroup()
  
  assertthat::assert_that(all(unique(fao_taxa$taxa) %in% wahis_taxa))
  
  return(fao_taxa)
}



#' Process FAO taxa population data
#'
#' This function processes taxa population data by joining it with a tibble 
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
#' process_wb(download_file = "data-raw/fao-taxa-population/Production_Crops_Livestock_E_All_Data_(Normalized).gz.parquet", all_country_years)
#'
#' @export
#' 
process_taxa_population <- function(fao_taxa_population,
                                    wahis_disease_taxa_lookup,
                                    all_countries_years) {
  
 
  # expand all country years to include all taxa
  all_countries_years_taxa <- all_countries_years |>
    tidyr::crossing(dplyr::tibble(taxa = unique(fao_taxa_population$taxa)))
  
  fao_taxa_population <- fao_taxa_population |>
    dplyr::right_join(
      y = all_countries_years_taxa, 
      by = c("country_iso3c", "year", "taxa")
    ) |>
    dplyr::arrange(country_iso3c, taxa, year) |>
    dplyr::group_split(country_iso3c, taxa) |>
    purrr::map_dfr(~na_interp(., "population")) |>
    dplyr::mutate(imputed_value = ifelse(is.na(population), TRUE, imputed_value)) |> 
    dplyr::mutate(population = replace_na(population, 0)) |> 
    dplyr::mutate(source = "FAO")
  
  # now get target taxa population by disease
  disease_taxa_lookup <- wahis_disease_taxa_lookup |> rename(disease = standardized_disease_name, taxa = standardized_taxon_name) 
  
  target_taxa_population <- fao_taxa_population |>
    dplyr::left_join( # repeat the population value for every disease for which that taxa is a target taxa
      disease_taxa_lookup, by = "taxa",
      relationship = "many-to-many"
    ) |>
    dplyr::group_by(country_iso3c, year, disease) |>
    dplyr::summarize( # now get total taxa population by disease
      target_taxa_population = sum(population, na.rm = TRUE), .groups = "drop"
    ) |>
    dplyr::ungroup()
  
  return(target_taxa_population)
  
}
