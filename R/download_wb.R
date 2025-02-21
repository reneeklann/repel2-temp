#'
#' Get country GDP and Population from World Bank API
#' 
#' @param directory Directory to save data
#' @param indicator Name of indicator to retrieve via World Bank API
#' @param download_aws Whether to download from AWS bucket instead of data source. Requires having Sys.getenv("AWS_DATA_BUCKET_ID") set with a valid AWS bucket containing the data. Default is FALSE.
#' 
#' @return Relative path to downloaded data as parquet file
#'  
#' @export
#' 
#' @example 
#' download_wb(directory = "data-raw/wb-gdp", indicator = "NY.GDP.MKTP.CD")
#'
download_wb <- function(directory, indicator, download_aws = as.logical(Sys.getenv("USE_AWS_DOWNLOAD", unset = FALSE))) {
  
  file_name <- paste0(indicator, ".gz.parquet")
  
  if(download_aws) {
    download_aws_file(directory, file_name)
    return(file.path(directory, file_name))
  }
  
  x <- jsonlite::fromJSON(
    paste0(
      "http://api.worldbank.org/v2/country/all/indicator/", indicator, 
      "?per_page=20000&format=json"
    )
  )
  
  x <- x[[2]]
  
  message(glue::glue("Saving {file_name}"))
  arrow::write_parquet(x, file.path(directory, file_name), compression = "gzip", compression_level = 5)
  
  return(file.path(directory, file_name))
}
