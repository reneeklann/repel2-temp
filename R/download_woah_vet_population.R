#'
#' Get veterinarian data from WAHIS
#' 
#' @param directory Directory to save data
#' @param download_aws Whether to download from AWS bucket instead of data source. Requires having Sys.getenv("AWS_DATA_BUCKET_ID") set with a valid AWS bucket containing the data. Default is FALSE.
#' 
#' @return Relative path to downloaded data as parquet file
#'  
#' @export
#' 
#' @example 
#' download_woah_vet_population(directory = "data-raw/woah-vet-population", dataset = "taxa_population")
#'
download_woah_vet_population <- function(directory, download_aws = as.logical(Sys.getenv("USE_AWS_DOWNLOAD", unset = FALSE))) {

  # Veterinarians_Vet_paraprofessionals.xlsx was provided to EHA via email from WAHIS support June 1, 2023
  file_name.xlsx <- "Veterinarians_Vet_paraprofessionals.xlsx"
  file_name.par <- stringr::str_replace(file_name.xlsx, ".xlsx",".gz.parquet")
  
  message(glue::glue("Converting {file_name.xlsx} to {file_name.par}"))
  
  x <- readxl::read_excel(file.path(directory, file_name.xlsx))
  arrow::write_parquet(x, file.path(directory, file_name.par))
  
  return(file.path(directory, file_name.par))
  
}
