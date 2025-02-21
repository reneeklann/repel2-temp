#'
#' Download full COMTRADE directory from AWS cache
#' 
#' Default is not to run the download from AWS. This is a convenience function to facilitate internal data sharing among collaborators.
#' 
#' @param directory Directory to save data
#' @param download_aws Whether to download from AWS bucket instead of data source. Requires having Sys.getenv("AWS_DATA_BUCKET_ID") set with a valid AWS bucket containing the data. Default is FALSE.
#' @param comtrade_livestock_download_start_dates Files are batched in AWS by start date
#' 
#' @return Relative path to downloaded directory
#'  
#' @export
#' 
misc_download_comtrade_from_aws <- function(directory = comtrade_livestock_raw_directory,
                                            download_aws = as.logical(Sys.getenv("USE_AWS_DOWNLOAD", unset = FALSE)),
                                            comtrade_livestock_download_start_dates) {
  
  if(download_aws){
    # files were saved separately by start date
    purrr::walk(comtrade_livestock_download_start_dates, function(start_date) {
      containerTemplateUtils::aws_s3_download(path = directory,
                                              bucket = Sys.getenv("AWS_DATA_BUCKET_ID"),
                                              key = paste0(directory, "/", start_date),
                                              check = TRUE)
      
    })
  }
  
  return(directory)
}
