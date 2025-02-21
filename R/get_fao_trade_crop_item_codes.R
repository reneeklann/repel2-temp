#' Get FAO trade crop-related item codes
#'
#' This function uses a lookup table to create a vector of crop-related item codes.
#'
#' @return A vector of item codes
#'
#' @examples
#'
#' @export

get_fao_trade_crop_item_codes <- function() {
  
  fao_trade_crop_item_codes <- read.csv("data-raw/fao-crop-lookup/fao_trade_crop_item_codes.csv")
  fao_trade_crop_item_codes <- fao_trade_crop_item_codes |>
    dplyr::filter(crop == TRUE)
  fao_trade_crop_item_codes <- unique(fao_trade_crop_item_codes$item_code)
  # 396 crop item codes
  
  fao_trade_crop_item_codes
}
