#' Scrape all free text articles from IPPC
#'
#' This function retrieves a tibble of articles and free text from IPPC
#'
#' @return tibble with article ID and free text as list
#'
#' @import rvest purrr stringi stringr tibble
#'
#' @examples
#'
#' @export
scrape_ippc_free_text <- function(ippc_table_downloaded, 
                                  directory,
                                  overwrite = FALSE,
                                  download_aws = as.logical(Sys.getenv("USE_AWS_DOWNLOAD", unset = FALSE))){
  
  file_name <- "ippc_free_text.gz.parquet"
  
  if(download_aws) {
    download_aws_file(directory, file_name)
    return(file.path(directory, file_name))
  }
  
  if(file.exists(file.path(directory, file_name)) && !overwrite) {
    message("File already exists, skipping download")
    return(file.path(directory, file_name))
  } 
  
  
  report_urls <- arrow::read_parquet(ippc_table_downloaded) |> dplyr::pull(url)
  
  # Get title and free text from each report
  x <- purrr::map_dfr(report_urls, function(report_url){
    
    tryCatch({
      message(report_url)
      report_html <- rvest::read_html(report_url)
      report_title <- report_html |> rvest::html_elements("h1") |> rvest::html_text()
      report_title <- report_title[report_title != ""]
      report_text <- report_html |> rvest::html_element("dl") |> rvest::html_text() |> 
        stringr::str_replace_all(pattern = "\n", replacement = "") |> stringr::str_squish() |>
        stringr::str_replace_all(pattern = '"', replacement = "'")
      tibble::tibble(report_title = report_title, text = report_text, url = report_url)
    }, error = function(err) {
      message("Error processing report: ", report_url, " - ", err$message)
      tibble::tibble(report_title = NULL, text = NULL, url = report_url)
    })
  })
  
  message(glue::glue("Saving {file_name}"))
  arrow::write_parquet(x, file.path(directory, file_name))
  
  return(file.path(directory, file_name))
}
