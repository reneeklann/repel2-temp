#' Process Crop Outbreak Data from IPPC
#'
#' This function retrieves a structured table of crop disease outbreaks from IPPC
#'
#' @return processed outbreak table from IPPC data source
#'
#' @import dplyr
#' @importFrom countrycode countrycode
#'
#' @examples
#' # Download the table
#' process_ippc_table(path_to_file = "data-raw/ippc/ippc_reports.rds")
#'
#' @export
process_ippc_table <- function(ippc_table_downloaded, ippc_free_text_scraped, 
                               priority_crop_disease_lookup) {
  
  ippc_reports <- arrow::read_parquet(ippc_table_downloaded)
  ippc_free_text_scraped <- arrow::read_parquet(ippc_free_text_scraped)
  
  # Rename variables
  ippc_reports <- ippc_reports |>
    dplyr::rename(
      country = Country,
      report_number = `Report number`,
      date_published = `Date published`,
      last_updated = `Last updated`,
      pest = `Identity of Pest`,
      host_ippc = `Host(s) or Article(s)`,
      pest_status = `Status of pest (under ISPM No.8 2021)`,
      title = Title
    )
  
  # Clean pest_status
  ippc_reports <- ippc_reports |>
    dplyr::mutate(pest_status = stringr::str_replace_all(string = pest_status, pattern = "\n", replacement = "") |> stringr::str_squish()) |>
    dplyr::mutate(pest_status = dplyr::na_if(pest_status, ""))
  
  # Convert date_published and last_updated to dates and add variable year_published
  ippc_reports <- ippc_reports |>
    dplyr::mutate(date_published = lubridate::dmy(date_published)) |>
    dplyr::mutate(last_updated = lubridate::dmy(last_updated)) |>
    dplyr::mutate(year_published = lubridate::year(date_published)) |>
    dplyr::relocate(year_published, .after = report_number)
  
  # Handle some priority disease names
  ippc_reports <- ippc_reports |>
    dplyr::mutate(pest = ifelse(stringr::str_detect(title, "Pantoea stewartii subsp. stewartii"), "Pantoea stewartii subsp. stewartii - (ERWIST)", pest)) |>
    dplyr::mutate(pest = ifelse(stringr::str_detect(title, "Magnaporthe oryzae pathotype Triticum"), "Magnaporthe oryzae pathotype Triticum", pest))
  
  # Separate EPPO code from pest name
  ippc_reports <- ippc_reports |>
    dplyr::mutate(ippc_eppo_code = stringr::str_extract(string = pest, pattern = "\\s-\\s\\(.{5,6}\\)")) |>
    dplyr::mutate(ippc_eppo_code = stringr::str_replace(string = ippc_eppo_code, pattern = "\\s-\\s\\(", replacement = "")) |>
    dplyr::mutate(ippc_eppo_code = stringr::str_replace(string = ippc_eppo_code, pattern = "\\)", replacement = "")) |>
    dplyr::mutate(pest = stringr::str_replace(string = pest, pattern = "\\s-\\s\\(.{5,6}\\)", replacement = ""))
  
  ippc_reports <- ippc_reports |>
    dplyr::mutate(pest = ifelse(pest == "None", "", pest))
  
  # Manually fix country name (for country "NRO_training")
  ippc_reports <- ippc_reports |>
    dplyr::mutate(country = ifelse(report_number == "NRO-03/1", "Yemen", country))
  
  # Add country code and continent columns
  country_code <- countrycode::countrycode(
    sourcevar = ippc_reports$country, 
    origin = "country.name", 
    destination = "iso3c"
  )
  continent <- countrycode::countrycode(
    sourcevar = ippc_reports$country, 
    origin = "country.name", 
    destination = "continent"
  )
  
  ippc_reports <- cbind(ippc_reports, country_code, continent)
  ippc_reports <- ippc_reports |>
    dplyr::relocate(country_code, .after = country) |>
    dplyr::relocate(continent, .after = country_code)
  
  # Add source column
  ippc_reports <- ippc_reports |>
    dplyr::mutate(source = "IPPC")
  
  # Join to free text by report url
  ippc_reports <- ippc_reports |>
    dplyr::full_join(ippc_free_text_scraped, by = dplyr::join_by(url == url)) |>
    dplyr::select(-report_title)
  
  # Add column indicating whether a report refers to NAPPO
  nappo_url <- c("pestalert.org", "pestalerts.org")
  nappo_url <- stringr::str_c(stringr::str_flatten(nappo_url, "|"))
  nappo_url <- stringr::str_detect(ippc_reports$text, nappo_url)
  ippc_reports <- ippc_reports |>
    dplyr::mutate(cites_nappo = nappo_url)
  
  # Remove reports that refer to NAPPO
  ippc_reports <- ippc_reports |>
    dplyr::filter(cites_nappo == FALSE | is.na(cites_nappo))
  
  # Read priority crop disease lookup table and join to IPPC reports table
  priority_crop_disease_lookup <- readxl::read_xlsx(priority_crop_disease_lookup)
  ippc_reports <- ippc_reports |> 
    dplyr::left_join(priority_crop_disease_lookup, by = dplyr::join_by(pest==ippc_name))
  
  return(ippc_reports)
}
