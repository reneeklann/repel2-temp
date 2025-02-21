#' Get FAO crop production item codes
#'
#' This function uses a lookup table to create a vector of crop-related item codes.
#'
#' @return A vector of item codes
#'
#' @examples
#'
#' @export

get_fao_crop_production_item_codes <- function() {

  # read production item group table and filter crop item groups
  # csv downloaded from https://www.fao.org/faostat/en/#data/QCL, Definitions and standards, Item Group
  fao_crop_production_item_groups <- read.csv("data-raw/fao-crop-lookup/fao_crop_production_item_groups.csv")
  fao_crop_production_item_groups <- fao_crop_production_item_groups |>
    janitor::clean_names() |>
    dplyr::select(-c(factor, hs_code, hs07_code)) |>
    dplyr::filter(item_group %in% c("Crops, primary", "Crops Processed")) |>
    dplyr::filter(item_group_code %in% c("1714", "QD"))
  # item group code QD corresponds to "Crops Processed"
  # item group codes QC and 1714 both correspond to "Crops, primary"
  # QC includes all the items in 1714, plus "Cereals, primary", "Fruit Primary", etc.
  
  fao_crop_production_item_codes <- unique(fao_crop_production_item_groups$item_code)
  
  fao_crop_production_item_codes

}
