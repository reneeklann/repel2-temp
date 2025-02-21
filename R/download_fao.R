#'
#' Get trade and taxa population data from FAO
#' 
#' @param directory Directory to save data
#' @param dataset Name of dataset to retrieve via FAO
#' @param download_aws Whether to download from AWS bucket instead of data source. Requires having Sys.getenv("AWS_DATA_BUCKET_ID") set with a valid AWS bucket containing the data. Default is FALSE.
#' 
#' @return Relative path to downloaded data as parquet file
#'  
#' @export
#' 
#' @example 
#' download_fao(directory = "data-raw/fao-taxa-population", dataset = "production")
#'
download_fao <- function(directory, 
                         dataset = c("production", "trade"),
                         download_aws = as.logical(Sys.getenv("USE_AWS_DOWNLOAD", unset = FALSE))) {
  
  dataset <- match.arg(dataset)
  
  file_name.csv <- switch(dataset, 
                          "production" = "Production_Crops_Livestock_E_All_Data_(Normalized).csv",
                          "trade" =  "Trade_DetailedTradeMatrix_E_All_Data_(Normalized).csv")
  file_name.par <- stringr::str_replace(file_name.csv, ".csv",".gz.parquet")
  
  if(download_aws) {
    download_aws_file(directory, file_name.par)
    return(file.path(directory, file_name.par))
  }
  
  message(glue::glue("Downloading FAO {dataset} data (zipped)"))
  
  url <- switch(dataset, 
                "production" = "https://fenixservices.fao.org/faostat/static/bulkdownloads/Production_Crops_Livestock_E_All_Data_(Normalized).zip",
                "trade" = "http://fenixservices.fao.org/faostat/static/bulkdownloads/Trade_DetailedTradeMatrix_E_All_Data_(Normalized).zip")
  
  download_filename <- "fao.zip"
  
  download.file(
    url = url,
    destfile =  file.path(
      directory, download_filename
    )
  )
  
  message("Unzipping")
  path_to_zip <- file.path(directory, download_filename)
  zip::unzip(zipfile = path_to_zip, exdir = dirname(path_to_zip))
  
  message(glue::glue("Converting {file_name.csv} to {file_name.par}"))
  
  x <- read.csv(file.path(directory, file_name.csv))
  arrow::write_parquet(x, file.path(directory, file_name.par))
  
  existing_files <- list.files(file.path(directory), full.names = TRUE)
  
  existing_files_remove <- existing_files[!existing_files == file.path(directory, file_name.par)]
  file.remove(existing_files_remove)
  
  return(file.path(directory, file_name.par))
  
}

