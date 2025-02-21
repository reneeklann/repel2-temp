#' Process Index of Crop Outbreak Data from EPPO
#'
#' This function retrieves a structured table of crop disease outbreaks from EPPO
#'
#' @return processed outbreak index from EPPO data source
#'
#' @import dplyr
#' @importFrom countrycode countrycode
#'
#' @examples
#' # Download the table
#' process_eppo_index(eppo_index_downloaded")
#'
#' @export
process_eppo_index <- function(eppo_index_downloaded, eppo_free_text_processed, 
                               priority_crop_disease_lookup) {
  
  eppo_index <- readxl::read_xlsx(eppo_index_downloaded)
  
  # Rename variables
  eppo_index <- eppo_index |>
    dplyr::rename(
      pest = Pest,
      country = Country,
      year_published = Year,
      issue = Issue,
      article_number = `RS Item`,
      title = Title,
      keyword1 = `Add Kwords1`,
      keyword2 = `Add Kwords2`
    )
  
  # Convert year_published to integer
  eppo_index <- eppo_index |>
    dplyr::mutate(year_published = as.integer(year_published))
  
  # Standardize article_number so it can be joined to free text
  eppo_index <- eppo_index |>
    dplyr::mutate(article_number = stringr::str_replace_all(article_number, pattern = "/00", replacement = "/")) |>
    dplyr::mutate(article_number = stringr::str_replace_all(article_number, pattern = "/0", replacement = "/"))
  
  # Fix incorrect article numbers
  eppo_index <- eppo_index |> 
    dplyr::mutate(article_number = ifelse(title == "Dendroctonus valens: addition to the EPPO Alert List", "2019/99", article_number)) |>
    dplyr::mutate(article_number = ifelse(title == "Alien Hydrocotyle species in Belgium", "2021/72", article_number))
  
  # Remove duplicate rows
  eppo_index <- eppo_index[!duplicated(eppo_index), ]
  
  # Add unique IDS
  eppo_index <- eppo_index |>
    dplyr::group_by(article_number) |>
    dplyr::arrange(pest, .by_group = TRUE) |>
    dplyr::mutate(eppo_unique_id = paste0(article_number, "-", seq(1:dplyr::n()))) |>
    dplyr::ungroup()
  
  # Correct misspelled or ambiguous country names
  eppo_index$country[eppo_index$country == "Azerbeijan"] <- "Azerbaijan"
  eppo_index$country[eppo_index$country == "Boliva"] <- "Bolivia"
  eppo_index$country[eppo_index$country == "Czecoslovakia (former)"] <- "Czechoslovakia (former)"
  eppo_index$country[eppo_index$country == "Lichtenstein"] <- "Liechtenstein"
  eppo_index$country[eppo_index$country == "Lybia"] <- "Libya"
  eppo_index$country[eppo_index$country == "Micronesia"] <- "Federated States of Micronesia"
  eppo_index$country[eppo_index$country == "Soudan"] <- "Sudan"
  eppo_index$country[eppo_index$country == "Virgin Islands"] <- "British Virgin Islands"
  
  # Fix incorrect country (is Brazil but should be Australia)
  eppo_index <- eppo_index |> 
    dplyr::mutate(country = ifelse(article_number == "2018/173" & pest == "Xanthomonas euvesicatoria", "Australia", country)) |>
    dplyr::mutate(country = ifelse(article_number == "2018/173" & pest == "Xanthomonas perforans", "Australia", country)) |>
    dplyr::mutate(country = ifelse(article_number == "2018/173" & pest == "Xanthomonas vesicatoria", "Australia", country))
  
  # Add country code and continent fields
  country_code <- countrycode::countrycode(
    sourcevar = eppo_index$country, 
    origin = "country.name", 
    destination = "iso3c"
  )
  continent <- countrycode::countrycode(
    sourcevar = eppo_index$country, 
    origin = "country.name", 
    destination = "continent"
  )
  eppo_index <- cbind(eppo_index, country_code, continent)
  eppo_index <- eppo_index |>
    dplyr::relocate(country_code, .after = country) |>
    dplyr::relocate(continent, .after = country_code)
  
  # Split index by date - don't hardcode what year the index goes up to
  eppo_index_1992 <- eppo_index |>
    dplyr::filter(year_published <= 1992)
  current_year <- as.integer(format(Sys.Date(), "%Y"))
  eppo_index_1993 <- eppo_index |>
    dplyr::filter(year_published >= 1993 & year_published < current_year)
  
  # Add field indicating whether article number appears multiple times in index
  eppo_index_1993 <- eppo_index_1993 |>
    dplyr::group_by(article_number) |>
    dplyr::mutate(multiple_reports = dplyr::n() > 1) |>
    dplyr::ungroup()
  
  # Split free text by date
  eppo_free_text_processed_1992 <- eppo_free_text_processed |>
    dplyr::filter(year_published <= 1992)
  eppo_free_text_processed_1993 <- eppo_free_text_processed |>
    dplyr::filter(year_published >= 1993 & year_published < current_year)
  eppo_free_text_processed_current_year <- eppo_free_text_processed |>
    dplyr::filter(year_published == current_year)
  
  # Join index and free text 1993-most recent index year
  eppo_1993_joined <- eppo_index_1993 |> 
    dplyr::full_join(eppo_free_text_processed_1993, by = dplyr::join_by(article_number))
  eppo_1993_joined <- eppo_1993_joined |>
    dplyr::select(-year_issue, -year_published.x, -issue.x, -title.x)
  eppo_1993_joined <- eppo_1993_joined |>
    dplyr::rename(
      title = title.y,
      year_published = year_published.y,
      issue = issue.y
    )
  
  # Filter out rows with unspecified pest or country
  eppo_1993_joined <- eppo_1993_joined |>
    dplyr::filter(!is.na(pest)) |>
    dplyr::filter(!is.na(country) & 
                  !(country %in% c("Conference", "EAEU", "EPPO", "EU", "Eurasian Economic Union (EAEU)", "European Union", "IYPH")))
  
  # Filter out keywords for conferences, interceptions, and invasive plants
  eppo_1993_joined <- eppo_1993_joined |>
    dplyr::filter(!(keyword1 %in% c("Conference", "Interception", "Interceptions", "Invasive alien plant", "Invasive alien plants") | 
                    keyword2 %in% c("Conference", "Interception", "Interceptions", "Invasive alien plant", "Invasive alien plants")))
  
  # Read priority crop disease lookup table and join to 1993-most recent index year table
  priority_crop_disease_lookup <- readxl::read_xlsx(priority_crop_disease_lookup)
  eppo_1993_joined <- eppo_1993_joined |> 
    dplyr::left_join(priority_crop_disease_lookup, by = dplyr::join_by(pest==eppo_name))
  
  # Bind years 1993-present
  eppo_full <- dplyr::bind_rows(eppo_1993_joined, eppo_free_text_processed_current_year)
  
  # Add source variable
  eppo_full <- eppo_full |>
    dplyr::mutate(source = "EPPO")
  
  # Reorder columns
  eppo_full <- eppo_full |>
    dplyr::relocate(source) |>
    dplyr::relocate(pest, .after = source) |>
    dplyr::relocate(country, .after = pest) |>
    dplyr::relocate(country_code, .after = country) |>
    dplyr::relocate(continent, .after = country_code) |>
    dplyr::relocate(year_published, .after = continent) |>
    dplyr::relocate(issue, .after = year_published) |>
    dplyr::relocate(article_number, .after = issue) |>
    dplyr::relocate(eppo_unique_id, .after = article_number) |>
    dplyr::relocate(title, .after = eppo_unique_id) |>
    dplyr::relocate(text, .after = title) |>
    dplyr::relocate(keyword1, .after = text) |>
    dplyr::relocate(keyword2, .after = keyword1) |>
    dplyr::select(-year_issue)
  
  return(eppo_full)
}
