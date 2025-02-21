#'
#' Get Comtrade livestock commodity codes
#' 
#' This function wraps around the `ots_commodities` and `ots_sections` datasets
#' found in the `tradestatistics` package and filters the appropriate
#' commodities for the REPEL2 livestock model
#' 
#' @return A vector of Comtrade commodity codes specific for livestock
#' 
#' @examples
#' get_comtrade_livestock_commodity_codes()
#' 
#' @importFrom tradestatistics ots_commodities ots_sections
#' @importFrom dplyr left_join filter pull
#' @importFrom stringr str_detect
#' 
#' @export
#'
get_comtrade_livestock_commodity_codes <- function() {
  
  tradestatistics::ots_commodities |>
    dplyr::filter(
      ## live animals and animal meat ----
      stringr::str_detect(commodity_code, "^01[0-9]{1,6}$|^02[0-9]{1,6}$") |
        ## dairy and animal products ----
      stringr::str_detect(commodity_code, "^04[0-9]{1,6}$|^05[0-9]{1,6}$") |
        ## animal oil ----
      commodity_code %in% c(
        "150110", "150120", "150190", "150210", "150290", "150300", "150410",
        "150420", "150430", "150500", "150600", "151610", "151710", "151790",
        "151800", "152190", "152200", "160100", "160210", "160220", "160231",
        "160232", "160239", "160241", "160242", "160249", "160250", "160290",
        "160300", "430219"
      ) |
        ## fur, leather, and animal skin ----
      stringr::str_detect(commodity_code, "^41[0-9]{1,6}$|^42[0-9]{1,6}$|^43[0-9]{1,6}$") |
        ## Add commodities related to fabric/textile of animal origin and ----
      ## commodities related to animal blood and blood products and
      ## machinery used for preparing animal products
      commodity_code %in% c(
        "300190", "300210", "310100", "320300", "350300", "380290", "382100",
        "510810", "510820", "510211", "510219", "510220", "510310", "510320",
        "510330", "510400", "510531", "510539", "510540", "510910", "510990",
        "511000", "511111", "511119", "511120", "511130", "511190", "511211",
        "511219", "511220", "511230", "511290", "511300", "550952", "550961",
        "550991", "550999", "551020", "551090", "551513", "551522", "551631",
        "551632", "551633", "551634", "560221", "560229", "570110", "570190",
        "570231", "570239", "570241", "570249", "570291", "570299", "570310",
        "570390", "580110", "600310", "600610", "610210", "610331", "610341", 
        "610431", "610441", "610451", "610461", "611011", "611019", "611594", 
        "611691", "620111", "620191", "620211", "620291", "620311", "620331", 
        "620341", "620411", "620421", "620431", "620441", "620451", "620461",
        "620620", "621420", "630120", "670300", "670490", "843610", "847920", 
        "960190"
      )
    ) |>
    dplyr::pull(commodity_code)
}