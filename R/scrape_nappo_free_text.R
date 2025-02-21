#' Scrape all free text reports from NAPPO
#'
#' This function retrieves a tibble of articles and free text from NAPPO
#'
#' @return tibble with article ID and free text as list
#'
#' @import rvest purrr stringi stringr tibble
#'
#' @examples
#'
#' @export
scrape_nappo_free_text <- function(nappo_table_downloaded, 
                                   directory, 
                                   overwrite = FALSE,
                                   download_aws = as.logical(Sys.getenv("USE_AWS_DOWNLOAD", unset = FALSE))){
  
  file_name <- "nappo_free_text.gz.parquet"
  
  if(download_aws) {
    download_aws_file(directory, file_name)
    return(file.path(directory, file_name))
  }
  
  if(file.exists(file.path(directory, file_name)) && !overwrite) {
    message("File already exists, skipping download")
    return(file.path(directory, file_name))
  } 
  
  report_urls <- arrow::read_parquet(nappo_table_downloaded) |> dplyr::pull(url)
  
  # Get title and free text from each report
  x <- purrr::map_dfr(report_urls, function(report_url){
    message(report_url)
    report_html <- rvest::read_html(report_url)
    report_title <- report_html |> rvest::html_element("h3") |> rvest::html_text() |> 
      stringr::str_replace_all(pattern = "\n", replacement = "") |> stringr::str_squish()
    report_pest <- report_html |> rvest::html_element("h3") |>  rvest::html_elements("em") |> 
      rvest::html_text() |> stringr::str_squish()
    report_pest <- report_pest |> unique() |> paste(collapse = " ")
    report_text <- report_html |> rvest::html_element("main") |> 
      rvest::html_element("div.row.bg-content-custom.p-4.shadow.text-justify.rounded") |> 
      rvest::html_text() |> stringr::str_replace_all(pattern = "\n", replacement = "") |> 
      stringr::str_squish() |> stringr::str_replace_all(pattern = '"', replacement = "'")
    tibble::tibble(report_title = report_title, pest = report_pest, text = report_text, url = report_url)
  })
  
  message(glue::glue("Saving {file_name}"))
  arrow::write_parquet(x, file.path(directory, file_name))
  
  return(file.path(directory, file_name))
  
}