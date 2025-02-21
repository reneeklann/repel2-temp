#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param file_name
#' @param directory
#' @param bucket
#' @return
#' @author Emma Mendelsohn
#' @export
download_aws_file <- function(directory,
                              file_name,
                              bucket = Sys.getenv("AWS_DATA_BUCKET_ID")) {
  
  message(glue::glue("Skipping download from source. Pulling cached {file_name} from AWS"))
  
  containerTemplateUtils::aws_s3_download(path = file.path(directory, file_name),
                                          bucket = bucket,
                                          key = file.path(directory, file_name),
                                          check = TRUE)
  
}
