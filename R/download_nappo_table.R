#' Download Crop Outbreak Data from NAPPO
#'
#' This function retrieves a structured table of crop disease outbreaks from NAPPO
#'
#' @return raw data file
#' 
#' @import rvest dplyr
#' 
#' @examples
#' # Download the table
#' download_nappo_table(directory = "data-raw")
#' 
#' @export
download_nappo_table <- function(directory, download_aws = as.logical(Sys.getenv("USE_AWS_DOWNLOAD", unset = FALSE))) {
  
  file_name <- "nappo_table.gz.parquet"
  
  if(download_aws) {
    download_aws_file(directory, file_name)
    return(file.path(directory, file_name))
  }
  
  parent_url <- "https://www.pestalerts.org/nappo/official-pest-reports/"
  parent_html <- rvest::read_html(parent_url)
  
  nappo_reports <- parent_html |>
    rvest::html_element("table") |>
    rvest::html_table()
  
  report_urls <- parent_html |>  rvest::html_elements("a") |> rvest::html_attr("href")
  # Manually remove URLs that are not reports
  report_urls <- report_urls[! report_urls %in% c('/admin/', '/nappo/', '/nappo/about-us/', 
                                                  '/nappo/contact/', '/nappo/emerging-pest-alerts/', 
                                                  '/nappo/official-pest-reports/', '/nappo/subscribe/', 
                                                  'https://www.nappo.org', 'https://www.nappo.org/', 
                                                  'https://cipm.ncsu.edu/', '#', NA)]
  report_urls <- paste0(parent_url, report_urls)
  
  nappo_reports <- cbind(nappo_reports, report_urls)
  nappo_reports <- nappo_reports |>
    dplyr::rename(url = report_urls)
  
  message(glue::glue("Saving {file_name}"))
  arrow::write_parquet(nappo_reports, file.path(directory, file_name))
  
  return(file.path(directory, file_name))
  
  
  return(nappo_reports)
}