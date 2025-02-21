#' 
#' Create directory with a .gitkeep file
#' 
#' @param directory Directory to save the World Bank data into
#' 
#' @return Path to the directory
#' 
#' @export
#' 
#' @example 
#' create_data_directory("data-raw/wb-gdp")
#' 
create_data_directory <- function(directory_path) {
  
  dir.create(directory_path, recursive = TRUE, showWarnings = FALSE)
  file.create(file.path(directory_path, ".gitkeep"))
  
  return(file.path(directory_path))
}