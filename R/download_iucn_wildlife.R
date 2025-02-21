#' Download IUCN Wildlife Data
#'
#' This function downloads wildlife data from the IUCN Red List API for each 
#' country
#'
#' @param token The API token for accessing the IUCN Red List API.
#' @param directory Directory to save data
#' @param download_aws Whether to download from AWS bucket instead of data source. Requires having Sys.getenv("AWS_DATA_BUCKET_ID") set with a valid AWS bucket containing the data. Default is FALSE.
#' 
#' @return Relative path to downloaded data as parquet file
#'
#' @export
#' 
#' @example 
#' download_iucn_wildlife(token = Sys.getenv("IUCN_REDLIST_KEY"), directory = "data-raw/iucn-wildlife")
#'
download_iucn_wildlife <- function(token, directory, download_aws = as.logical(Sys.getenv("USE_AWS_DOWNLOAD", unset = FALSE))) {
  
  # This function gets lists of migratory species from the IUCN Red list
  # IUCN is currently not providing tokens to new users
  # therefore code that downloads and accesses the data is commented out
  # instead we are git tracking a cached version of the dataset
  
  # Not run -----
  # # Create API URL
  # api_url <- paste0(
  #   "https://apiv3.iucnredlist.org/api/v3/country/list?token=", token
  # )
  # 
  # ## Test if URL is accessible (200 status)
  # api_url_status <- httr::HEAD(url = api_url) |>
  #   httr::status_code()
  # 
  # assertthat::assert_that(!httr::http_error(api_url))
  # 
  # ## Get list of available countries
  # countries <- jsonlite::fromJSON(
  #   paste0("https://apiv3.iucnredlist.org/api/v3/country/list?token=", token)
  # )$results
  # 
  # ## For each country, download the data and iteratively add to a dataframe
  # x <- purrr::map_df(countries$isocode, function(iso) {
  #   
  #   message(glue::glue("Downloading migratory species for {iso}"))
  #   
  #   result <- jsonlite::fromJSON(
  #     paste0(
  #       "https://apiv3.iucnredlist.org/api/v3/country/getspecies/",
  #       iso, "?token=", token
  #     )
  #   )$result
  #   
  #   if (length(result)) {
  #     result <- result |> dplyr::mutate(country = iso)
  #   } else {
  #     result <- NULL
  #   }
  #   
  #   result
  # })
  
  file_name <- "iucn_wildlife.gz.parquet"
  
  # if(download_aws) {
  #   download_aws_file(directory, file_name)
  #   return(file.path(directory, file_name))
  # }
  
  # message(glue::glue("Saving {file_name}"))
  # arrow::write_parquet(x, file.path(directory, file_name))
  
  return(file.path(directory, file_name))
  
}

