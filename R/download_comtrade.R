#' Download UN COMTRADE trade data by period and commodity
#'
#' This function retrieves COMTRADE data by specifying the period and commodity 
#' codes. The data is downloaded and saved as RDS files.
#'
#' @param start_date The starting year of the period (default: 2000).
#' @param end_date The ending year of the period (default: current year).
#' @param commodity_code The commodity codes for which the data will be 
#'   retrieved.
#' @param directory The directory where the downloaded data will be saved.
#' @param overwrite Whether to re-download and overwrite existing files (default FALSE)
#'
#' @examples
#' download_comtrade(
#'   start_date = 2012, end_date = 2023, 
#'   commodity_code = 430310, 
#'   directory = "data-raw/comtrade-livestock"
#' )
#'
#' @export
download_comtrade <- function(start_date,
                              end_date,
                              commodity_code,
                              directory,
                              overwrite = FALSE,
                              ...) { 
  
  
  overwrite <- as.logical(overwrite)
    
  file_name <- paste0(start_date, "_", end_date, "_", commodity_code)
  
  message(glue::glue("Downloading {file_name}"))
  
  existing_files <- list.files(file.path(directory))
  existing_file <- existing_files[stringr::str_detect(existing_files, file_name)]
  
  if(length(existing_file) && !overwrite) {
    message("File already exists, skipping download")
    return(file.path(directory, existing_file))
  } 
  
  x <- comtradr::ct_get_data(
    start_date = start_date,
    end_date = end_date, 
    commodity_code = commodity_code,
    flow_direction = c("Import", "Re-export", "Export", "Re-import"),
    reporter = "everything",
    partner = "everything"
  )
  
  
  
  if(ncol(x) == 1) {
    # save as an empty file for tracking with targets
    message(glue::glue("Data not available for this commodity code and dates, saving {file_name} as an empty file"))
    file_name <- paste0(file_name, "_empty.gz.parquet")
    arrow::write_parquet(x, file.path(directory, file_name), compression = "gzip", compression_level = 5)
    return(file.path(directory, file_name))
  }
  
  file_name <- paste0(file_name, ".gz.parquet")
  message(glue::glue("Saving {file_name}"))
  arrow::write_parquet(x, file.path(directory, file_name), compression = "gzip", compression_level = 5)
  
  return(file.path(directory, file_name))
}
