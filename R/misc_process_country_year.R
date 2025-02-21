#'
#' Process all country-year combinations
#' 
#' @param from Starting year to make country-year combinations
#' @param to Ending year to make country-year combinations
#' 
#' @return A tibble of country-year combinations or connected country-year
#'   combinations
#' 
#' @export
#' @rdname misc_process_country_year
#' 
#' @examples
#' misc_process_country_year()
#' misc_process_connect_country_year()
#'
misc_process_country_year <- function(from = 2000, 
                                      to = format(Sys.Date(), "%Y")) {

  all_countries <- misc_get_country_list(.format = "tibble")

  all_years <- dplyr::tibble(year = seq(from = from, to = to))

  all_countries_years <- all_countries |>
    tidyr::crossing(all_years) |>
    dplyr::rename(country_iso3c = iso3c)
  
  all_countries_years
}

#' @rdname misc_process_country_year
#' @export
#'
misc_process_connect_country_year <- function(from = 2000,
                                              to = format(Sys.Date(), "%Y")) {
  all_countries <- misc_get_country_list(.format = "tibble")
    
  all_countries_connect <- all_countries |>
    dplyr::bind_cols(all_countries) |>
    purrr::set_names("country_origin", "country_destination") |>
    tidyr::expand(country_origin, country_destination) |>
    dplyr::filter(country_origin != country_destination)
  
  all_years <- dplyr::tibble(year = seq(from = from, to = to))
  
  all_connect_countries_years <- all_countries_connect |>
    tidyr::crossing(all_years) |> 
    dplyr::relocate(year, .before = country_origin) |>
    dplyr::arrange(year, country_origin, country_destination) # order to be enforced for comtrade processing
  
  
  all_connect_countries_years
}

#'
#' Get list of countries
#' 
#' @param .format Should output be a vector (default) or a tibble.
#' 
#' @return A vector or a tibble of country codes in ISO3 standards
#'
#' @export
#' 
#' @example
#' misc_get_country_list()
#'
#'

misc_get_country_list <- function(.format = c("vector", "tibble")) {
  .format <- match.arg(.format)
  
  if (.format == "vector") {
    c("ABW", "AFG", "AGO", "AIA", "ALB", "FIN", "AND", "ARE", "ARG",  
      "ARM", "ASM", "ATA", "AUS", "ATF", "ATG", "AUT", "AZE", "BDI",  
      "BEL", "BEN", "BFA", "BGD", "BGR", "BHR", "BHS", "BIH", "BLM",  
      "BLR", "BLZ", "BMU", "BOL", "BRA", "BRB", "BRN", "BTN", "BWA",  
      "CAF", "CAN", "CHE", "CHL", "CHN", "CIV", "CMR", "COD", "COG",  
      "COK", "COL", "COM", "CPV", "CRI", "CUB", "CUW", "CYM", "CYP",
      "CZE", "DEU", "DJI", "DMA", "DNK", "DOM", "DZA", "ECU", "EGY",
      "ERI", "ESP", "EST", "ETH", "FJI", "FLK", "REU", "MYT", "GUF",
      "MTQ", "GLP", "FRA", "FRO", "GAB", "GBR", "GEO", "GGY", "GHA",
      "GIN", "GMB", "GNB", "GNQ", "GRC", "GRD", "GRL", "GTM", "GUM",  
      "GUY", "HND", "HRV", "HTI", "HUN", "IDN", "IMN", "IND", "CCK",  
      "CXR", "IRL", "IRN", "IRQ", "ISL", "ISR", "ITA", "SMR", "JAM",
      "JEY", "JOR", "JPN", "KAZ", "KEN", "KGZ", "KHM", "KIR", "KNA",
      "KOR", "KWT", "LAO", "LBN", "LBR", "LBY", "LCA", "LIE", "LKA",
      "LSO", "LTU", "LUX", "LVA", "MAR", "MCO", "MDA", "MDG", "MDV",
      "MEX", "MHL", "MKD", "MLI", "MLT", "MMR", "MNE", "MNG", "MNP",
      "MOZ", "MRT", "MSR", "MUS", "MWI", "MYS", "NAM", "NCL", "NER",
      "NFK", "NGA", "NIC", "NIU", "NLD", "NOR", "NPL", "NRU", "NZL",
      "OMN", "PAK", "PAN", "PCN", "PER", "PHL", "PLW", "PNG", "POL",  
      "PRI", "PRK", "PRT", "PRY", "PSE", "PYF", "QAT", "ROU", "RUS",
      "RWA", "ESH", "SAU", "SDN", "SSD", "SEN", "SGP", "SGS", "SHN",
      "SLB", "SLE", "SLV", "SOM", "SPM", "SRB", "STP", "SUR", "SVK",
      "SVN", "SWE", "SWZ", "SXM", "SYC", "SYR", "TCA", "TCD", "TGO",  
      "THA", "TJK", "TKM", "TLS", "TON", "TTO", "TUN", "TUR", "TWN",
      "TZA", "UGA", "UKR", "URY", "USA", "UZB", "VAT", "VCT", "VEN",
      "VNM", "VUT", "WLF", "WSM", "YEM", "ZAF", "ZMB", "ZWE", "HKG")
  } else {
    dplyr::tibble(
      iso3c = c("ABW", "AFG", "AGO", "AIA", "ALB", "FIN", "AND", "ARE", "ARG",  
                "ARM", "ASM", "ATA", "AUS", "ATF", "ATG", "AUT", "AZE", "BDI",  
                "BEL", "BEN", "BFA", "BGD", "BGR", "BHR", "BHS", "BIH", "BLM",  
                "BLR", "BLZ", "BMU", "BOL", "BRA", "BRB", "BRN", "BTN", "BWA",  
                "CAF", "CAN", "CHE", "CHL", "CHN", "CIV", "CMR", "COD", "COG",  
                "COK", "COL", "COM", "CPV", "CRI", "CUB", "CUW", "CYM", "CYP",
                "CZE", "DEU", "DJI", "DMA", "DNK", "DOM", "DZA", "ECU", "EGY",
                "ERI", "ESP", "EST", "ETH", "FJI", "FLK", "REU", "MYT", "GUF",
                "MTQ", "GLP", "FRA", "FRO", "GAB", "GBR", "GEO", "GGY", "GHA",
                "GIN", "GMB", "GNB", "GNQ", "GRC", "GRD", "GRL", "GTM", "GUM",  
                "GUY", "HND", "HRV", "HTI", "HUN", "IDN", "IMN", "IND", "CCK",  
                "CXR", "IRL", "IRN", "IRQ", "ISL", "ISR", "ITA", "SMR", "JAM",
                "JEY", "JOR", "JPN", "KAZ", "KEN", "KGZ", "KHM", "KIR", "KNA",
                "KOR", "KWT", "LAO", "LBN", "LBR", "LBY", "LCA", "LIE", "LKA",
                "LSO", "LTU", "LUX", "LVA", "MAR", "MCO", "MDA", "MDG", "MDV",
                "MEX", "MHL", "MKD", "MLI", "MLT", "MMR", "MNE", "MNG", "MNP",
                "MOZ", "MRT", "MSR", "MUS", "MWI", "MYS", "NAM", "NCL", "NER",
                "NFK", "NGA", "NIC", "NIU", "NLD", "NOR", "NPL", "NRU", "NZL",
                "OMN", "PAK", "PAN", "PCN", "PER", "PHL", "PLW", "PNG", "POL",  
                "PRI", "PRK", "PRT", "PRY", "PSE", "PYF", "QAT", "ROU", "RUS",
                "RWA", "ESH", "SAU", "SDN", "SSD", "SEN", "SGP", "SGS", "SHN",
                "SLB", "SLE", "SLV", "SOM", "SPM", "SRB", "STP", "SUR", "SVK",
                "SVN", "SWE", "SWZ", "SXM", "SYC", "SYR", "TCA", "TCD", "TGO",  
                "THA", "TJK", "TKM", "TLS", "TON", "TTO", "TUN", "TUR", "TWN",
                "TZA", "UGA", "UKR", "URY", "USA", "UZB", "VAT", "VCT", "VEN",
                "VNM", "VUT", "WLF", "WSM", "YEM", "ZAF", "ZMB", "ZWE", "HKG") 
    )
  }
}
