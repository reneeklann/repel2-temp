#' Download CIA World Factbook 2020 Archive
#'
#' This function downloads the CIA World Factbook 2020 archive from the official 
#' website and saves it in the specified directory.
#'
#' @param directory Directory to save data
#' @param download_aws Whether to download from AWS bucket instead of data source. Requires having Sys.getenv("AWS_DATA_BUCKET_ID") set with a valid AWS bucket containing the data. Default is FALSE.
#' 
#' @return Relative path to downloaded data as parquet file
#'
#' @export
#' 
#' @example 
#' download_shared_borders(directory = "data-raw/shared-borders")
#'
download_shared_borders <- function(directory = shared_borders_directory, download_aws = as.logical(Sys.getenv("USE_AWS_DOWNLOAD", unset = FALSE))) {

  # This function downloads archived pages from the CIA world factbook 
  # now throws 403 error when accessed programmatically 
  # therefore code that downloads and accesses the data is commented out
  # instead we are git tracking a cached version of the html
  
  # Not run -----
  # file_name <- "factbook-2020.zip"
  # download.file(
  #   url = "https://www.cia.gov/the-world-factbook/about/archives/download/factbook-2020.zip",
  #   destfile =  here::here(
  #     directory, file_name
  #   )
  # )
  # zip::unzip(
  #   zipfile = path_to_zip,
  #   files = "factbook-2020/fields/281.html",
  #   exdir = dirname(path_to_zip)
  # )
  
  file_name.html <- "281.html"
  file_name.par <- stringr::str_replace(file_name.html, ".html",".gz.parquet")
  
  if(download_aws) {
    download_aws_file(directory, file_name.par)
    return(file.path(directory, file_name.par))
  }
  
  message(glue::glue("Converting {file_name.html} to {file_name.par}"))
  
  x <- xml2::read_html(file.path(directory, file_name.html)) |> 
    rvest::html_table() 
  
  arrow::write_parquet(x[[1]], file.path(directory, file_name.par))
  
  return(file.path(directory, file_name.par))
  
}
