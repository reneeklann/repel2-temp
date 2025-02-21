#' Get COMTRADE crop-related commodity codes
#'
#' This function gets commodity codes for vegetable products, wood,
#' and agricultural equipment
#'
#' @return A vector of commodity codes
#' 
#' @importFrom tradestatistics ots_commodities
#' @import dplyr
#'
#' @examples
#'
#' @export

get_comtrade_crop_commodity_codes <- function() {
  
  commodity_codes <- tradestatistics::ots_commodities
  
  # Section 02, "Vegetable products"
  commodity_codes_vegetable_products <- commodity_codes |>
    dplyr::filter(section_code == "02")
  # 304 codes

  # Section 09, "Wood and articles of wood..."
  commodity_codes_wood <- commodity_codes |>
    dplyr::filter(section_code == "09")
  # 94 codes
  
  # Agricultural equipment - sections 15, 16, 17
  commodity_codes_ag_equipment <- commodity_codes |>
    dplyr::filter(commodity_code %in% c("820110", # Tools, hand; spades and shovels
                                        "820130", # Tools, hand; mattocks, picks, hoes and rakes
                                        "820140", # Tools, hand; axes, bill hooks and similar hewing tools...
                                        "820150", # Tools, hand; one-handed secateurs (including poultry shears)
                                        "820160", # Tools, hand; hedge shears, two-handed pruning shears...
                                        "820190", # Tools, hand; forks, scythes, sickles, hay knives...
                                        "820840", # Tools; knives and cutting blades, for agricultural...
                                        "842481", # Mechanical appliances; for projecting, dispersing...
                                        "843210", # Ploughs; for soil preparation
                                        "843221", # Harrows; disc harrows
                                        "843229", # Harrows; (excluding disc), scarifiers, cultivators...
                                        "843230", # Seeders, planters and transplanters
                                        "843240", # Spreaders and distributors; for manure and fertilizers,
                                        "843290", # Machinery; parts of machinery for soil preparation...
                                        "843330", # Haymaking machinery
                                        "843340", # Balers; straw or fodder balers, including pick-up balers
                                        "843351", # Combine harvester-threshers
                                        "843352", # Threshing machinery; other than combine harvester-threshers
                                        "843353", # Harvesting machinery; for roots or tubers
                                        "843359", # Harvesting machinery; n.e.c. in heading no. 8433
                                        "843360", # Machines; for cleaning, sorting or grading eggs, fruit...
                                        "843390", # Harvesting machinery; parts, including parts... 
                                        "843680", # Machinery; for agricultural, horticultural or forestry use
                                        "843699", # Machinery; parts of that machinery for agricultural...
                                        "871620"  # Trailers and semi-trailers...for agricultural purposes
    )
    )
  # 25 codes
  
  commodity_codes_crop <- rbind(commodity_codes_vegetable_products, commodity_codes_wood, commodity_codes_ag_equipment)
  # 423 codes
  
  commodity_codes_crop <- commodity_codes_crop |>
    dplyr::pull(commodity_code)
  
  return(commodity_codes_crop)
}
