#' Process EPPO Free Text
#'
#' This function retrieves a structured table of crop disease outbreaks from EPPO
#'
#' @return processed outbreak index from EPPO data source
#'
#' @import dplyr
#' @importFrom countrycode countrycode
#'
#' @examples
#'
#' @export
process_eppo_free_text <- function(eppo_free_text_scraped) {
  
  # Create columns year_issue and article_number
  eppo_free_text_processed <- arrow::read_parquet(eppo_free_text_scraped) |> 
    dplyr::mutate(year_issue = stringr::str_extract(text, pattern = "\\d{2}\\s-\\s\\d{4}"),
                  article_number = stringr::str_extract(text, pattern = "\\d{4}/\\d{2,3}"))
  
  # Create columns year_published and issue from year_issue
  eppo_free_text_processed <- eppo_free_text_processed |>
    dplyr::mutate(year_published = stringr::str_extract(year_issue, pattern = "(19|20)\\d{2}"), 
                  issue = stringr::str_extract(year_issue, pattern = "0[1-9]|1[0,1,2]")) |>
    dplyr::mutate(year_published = as.integer(year_published))
  
  # Standardize article_number so it can be joined to eppo_index
  eppo_free_text_processed <- eppo_free_text_processed |>
    dplyr::mutate(article_number = stringr::str_replace_all(article_number, pattern = "/00", replacement = "/")) |>
    dplyr::mutate(article_number = stringr::str_replace_all(article_number, pattern = "/0", replacement = "/"))
  
  # Correct issue numbers for 1987 (there are more than 12 issues)
  eppo_free_text_processed <- eppo_free_text_processed |>
    dplyr::mutate(issue = ifelse(title == "American lupin aphid in Europe", "03", issue)) |>
    dplyr::mutate(issue = ifelse(title == "Witches' broom disease of Lime in Sultanate·of Oman", "03", issue)) |>
    dplyr::mutate(issue = ifelse(title == "Fireblight Outbreaks in Certain Greek Islands", "04", issue)) |>
    dplyr::mutate(issue = ifelse(title == "Outbreak of fireblight in Sweden in 1986", "04", issue)) |>
    dplyr::mutate(issue = ifelse(title == "Ceratocystis fimbriata f.sp. platani", "04", issue)) |>
    dplyr::mutate(issue = ifelse(title == "Non-occurrence of Ceratitis capitata in Netherlands", "07", issue)) |>
    dplyr::mutate(issue = ifelse(title == "Non-occurrence of Peronospora tabacina in Netherlands", "07", issue)) |>
    dplyr::mutate(issue = ifelse(title == "A2 quarantine bacteria in Italy", "07", issue)) |>
    dplyr::mutate(issue = ifelse(title == "Presence of Globodera pallida in Portugal", "08", issue)) |>
    dplyr::mutate(issue = ifelse(title == "Erwinia chrysanthemi as a cause of potato blackleg", "08", issue)) |>
    dplyr::mutate(issue = ifelse(title == "Fireblight in the United Kingdom (Northern Ireland)", "08", issue)) |>
    dplyr::mutate(issue = ifelse(title == "Presence of Xanthomonas fragariae in Portugal on imported strawberry plants", "08", issue)) |>
    dplyr::mutate(issue = ifelse(title == "Status of Frankliniella occidentalis in EPPO region", "08", issue)) |>
    dplyr::mutate(issue = ifelse(title == "Status of Opogona sacchari in EPPO region", "08", issue)) |>
    dplyr::mutate(issue = ifelse(title == "Temporary ban on the import of certain plants in order to prevent the spread of Frankliniella occidentalis", "09", issue)) |>
    dplyr::mutate(issue = ifelse(title == "Non-occurrence of Globodera rostochiensis in Israel", "09", issue)) |>
    dplyr::mutate(issue = ifelse(title == "Modification of Previous Decision taken on 21 August 1987 concerning the temporary ban of certain imports (see EPPO Reporting Service RSE - 488)", "09", issue)) |>
    dplyr::mutate(issue = ifelse(title == "Outbreak of Bemisia tabaci in the United Kingdom", "09", issue))
  
  eppo_free_text_processed <- eppo_free_text_processed |>
    dplyr::mutate(text = stringr::str_replace_all(string = text, pattern = "\r", replacement = ""))
  
  return(eppo_free_text_processed)
}
