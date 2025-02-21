#' Download Index of Crop Outbreak Data from EPPO
#'
#' This function retrieves a structured table of crop disease outbreaks from EPPO
#'
#' @return raw data excel file
#'
#' @importFrom here here
#' @importFrom utils download.file
#'
#' @examples
#' # Download the table
#' download_eppo_index(directory = "data-raw")
#'
#' @export
download_eppo_index <- function(directory, download_aws = as.logical(Sys.getenv("USE_AWS_DOWNLOAD", unset = FALSE))){
  
  last_year <- as.integer(format(Sys.Date(), "%Y")) - 1
  
  file_name <- "eppo_index.xlsx"
  
  if(download_aws) {
    download_aws_file(directory, file_name)
    return(file.path(directory, file_name))
  }
  
  utils::download.file(paste0("https://www.eppo.int/media/uploaded_images/RESOURCES/eppo_publications/INDEX_1967to", last_year, ".xlsx"),
                       destfile =  file.path(directory, file_name), method = "curl")
  
  return(file.path(directory, file_name))
}