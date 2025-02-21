#' Get pest names that were not standardized with EPPO database
#'
#' This function
#' 
#' @return 
#' 
#' @import dplyr
#'
#' @examples
#'
#' @param pest_names_standardized
#' 
#' @export
check_pest_names_not_standardized <- function(pest_names_standardized, crop_disease_taxonomy_manual) {
  
  pest_names_not_standardized <- pest_names_standardized |>
  dplyr::select(pest, preferred_name) |>
  dplyr::filter(!is.na(pest) & is.na(preferred_name)) |>
  dplyr::distinct()
  
  crop_disease_taxonomy_manual <- read.csv(crop_disease_taxonomy_manual)
  
  pest_names_not_standardized <- pest_names_not_standardized |>
    dplyr::filter(!pest %in% crop_disease_taxonomy_manual$pest)
  
  if(nrow(pest_names_not_standardized) > 0) {
    message(paste("The following disease names are not standardized:", stringr::str_flatten(pest_names_not_standardized$pest, collapse = ", ")))
  }
  
  return(pest_names_not_standardized)
}
