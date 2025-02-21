#' Download Crop Outbreak Data from IPPC
#'
#' This function retrieves a structured table of crop disease outbreaks from IPPC
#'
#' @return raw data file
#' 
#' @importFrom here here
#' @importFrom rvest html_element
#' @importFrom rvest html_table
#' 
#' @examples
#' # Download the table
#' download_ippc_table(directory = "data-raw")
#' 
#' @export
download_ippc_table <- function(directory, download_aws = as.logical(Sys.getenv("USE_AWS_DOWNLOAD", unset = FALSE))) {
  
  file_name <- "ippc_table.gz.parquet"
  
  if(download_aws) {
    download_aws_file(directory, file_name)
    return(file.path(directory, file_name))
  }
  
  parent_url <- "https://www.ippc.int/en/countries/all/pestreport/"
  parent_html <- rvest::read_html(parent_url)
  
  ippc_reports <- parent_html |>
    rvest::html_element("table") |>
    rvest::html_table()
  
  report_urls <- parent_html |>  rvest::html_elements("a") |> rvest::html_attr("href")
  report_urls <- paste0("https://www.ippc.int", report_urls[grepl("pestreports", report_urls)])
  
  ippc_reports <- cbind(ippc_reports, report_urls)
  ippc_reports <- ippc_reports |>
    dplyr::rename(url = report_urls)
  
  # Remove duplicate URLs
  ippc_reports <- ippc_reports |> 
    dplyr::distinct(url, .keep_all = TRUE) 
  
  message(glue::glue("Saving {file_name}"))
  arrow::write_parquet(ippc_reports, file.path(directory, file_name))
  
  return(file.path(directory, file_name))
}
