#' Download GROMS Migratory Species list
#'
#' @param directory Directory to save data
#' @param download_aws Whether to download from AWS bucket instead of data source. Requires having Sys.getenv("AWS_DATA_BUCKET_ID") set with a valid AWS bucket containing the data. Default is FALSE.
#' 
#' @return Relative path to downloaded data as parquet file
#'
#' @export
#' 
#' @example 
#' download_groms_migratory_species(directory = "data-raw/groms-migratory-species")
#'
download_groms_migratory_species <- function(directory, download_aws = as.logical(Sys.getenv("USE_AWS_DOWNLOAD", unset = FALSE))) {
  
  file_name <- "groms_migratory_species.gz.parquet"
  
  if(download_aws) {
    download_aws_file(directory, file_name)
    return(file.path(directory, file_name))
  }
  
  x <- xml2::read_html(
    "http://groms.de/groms_neu/view/order_stat_patt_spanish.php?search_pattern="
  )
  
  x <- rvest::html_table(x)[[2]] |>
    slice(-1) 
  
  
  message(glue::glue("Saving {file_name}"))
  arrow::write_parquet(x, file.path(directory, file_name))
  
  return(file.path(directory, file_name))
  
}
