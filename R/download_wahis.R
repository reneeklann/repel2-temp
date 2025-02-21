#' Download WAHIS Veterinary Disease Data
#'
#' This function downloads event, outbreak, six month status, six month control, and six month quantitative data 
#' from the WAHIS (World Animal Health Information System) database and saves it as CSV files.
#'
#' @param token Character vector containing the Dolt token for authorization. 
#'   By default, it uses the token from the system environment variable 
#'   "DOLT_TOKEN".
#' @param wahis_table The table from wahis dolt to download. Options are c("wahis_epi_events", "wahis_outbreaks", "wahis_six_month_status", "wahis_six_month_controls", "wahis_six_month_quantitative")
#' @param dolt_commit_hash The commit hash of the dolt database version. Defaults to latest on main branch.
#' @param directory The directory where the downloaded data will be stored.
#' 
#' @return Relative path to downloaded data as parquet file
#'  
#' @export
#' 
#' @example 
#' download_wahis(token = Sys.getenv("DOLT_TOKEN"), wahis_table = "wahis_epi_events", directory = "data-raw/wahis-outbreak-reports")
#' 
download_wahis <- function(token, 
                           wahis_table = c("wahis_epi_events", "wahis_outbreaks", "wahis_six_month_status", "wahis_six_month_controls", "wahis_six_month_quantitative"),
                           dolt_commit_hash = NULL,
                           directory) {
  
  wahis_table <- match.arg(wahis_table) 
  
  if(is.null(dolt_commit_hash)) dolt_commit_hash <- "main"
  
  x <- httr::GET(
    url = glue::glue("https://www.dolthub.com/csv/ecohealthalliance/wahisdb/{dolt_commit_hash}/{wahis_table}"),
    config = httr::add_headers(authorization = token)
  ) |>
    httr::content(as = "parsed", type = "text/csv", show_col_types = FALSE) 
  
  if(dolt_commit_hash != "main") wahis_table <- paste(wahis_table, dolt_commit_hash, sep = "_")
    
  file_name <- paste0(wahis_table, ".gz.parquet")
  
  message(glue::glue("Saving {file_name}"))
  arrow::write_parquet(x, file.path(directory, file_name), compression = "gzip", compression_level = 5)
  
  return(file.path(directory, file_name))
}