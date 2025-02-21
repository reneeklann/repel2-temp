#' Scrape all free text articles from EPPO
#'
#' This function retrieves a tibble of article titles and free text from EPPO
#'
#' @return tibble with article titles and free text
#'
#' @import rvest purrr
#' @importFrom tibble tibble
#'
#' @examples
#'
#' @export
scrape_eppo_free_text <- function(eppo_report_urls, 
                                  directory, 
                                  overwrite = FALSE,
                                  download_aws = as.logical(Sys.getenv("USE_AWS_DOWNLOAD", unset = FALSE))){
  
  file_name <- "eppo_free_text.gz.parquet"
  
  if(download_aws) {
    download_aws_file(directory, file_name)
    return(file.path(directory, file_name))
  }
  
  if(file.exists(file.path(directory, file_name)) && !overwrite) {
    message("File already exists, skipping download")
    return(file.path(directory, file_name))
  } 
  
  # we need newlines to subset paragraphs for OpenAI data extraction, 
  # so the following function gets all the paragraphs and concatenates them with newlines
  
  # using div, p, ul introduced the problem of duplicated text - 
  # sometimes multiple copies of the full text plus all the individual paragraphs
  # article_url <- "https://gd.eppo.int/reporting/article-6367"
  # article_url <- "https://gd.eppo.int/reporting/article-6981"
  
  # get free text from each article
  x <- purrr::map_dfr(eppo_report_urls, function(article_url){
    tryCatch({
      message(article_url)
      article_html <- rvest::read_html(article_url)
      article_title <- article_html |> rvest::html_element("h2") |> rvest::html_text(trim = TRUE)
      # article_text <- article_html |> rvest::html_element(".content") |> rvest::html_elements("div, p, ul") |> 
      #   rvest::html_text() |> paste(collapse = "\n") |> 
      #   stringr::str_replace_all(pattern = '"', replacement = "'")
      # dealing with the problem of duplicated text by getting the full text (element ".content"), 
      # getting all the paragraphs (elements "div, p, ul"), and using str_squish() then removing elements that match the full text
      article_text_full <- article_html |> rvest::html_element(".content") |> rvest::html_text() |> stringr::str_squish()
      article_text <- article_html |> rvest::html_element(".content") |> rvest::html_elements("div, p, ul") |> 
        rvest::html_text() |> unique() |> stringr::str_squish()
      article_text <- article_text[!article_text %in% article_text_full]
      article_text <- article_text |> paste(collapse = "\n") |> stringr::str_replace_all(pattern = '"', replacement = "'")
      tibble::tibble(title = article_title, text = article_text, url = article_url)
    }, error = function(err) {
      message("Error processing article: ", basename(article_url), " - ", err$message)
      tibble::tibble(title = NULL, text = NULL, url = article_url)
    })
  })
  
  message(glue::glue("Saving {file_name}"))
  arrow::write_parquet(x, file.path(directory, file_name))
  
  return(file.path(directory, file_name))
}
