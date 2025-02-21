#' Check that current Comtrade download has expected field names
#' 
#' @param commodity_code Single commodity code value to use for testing. Default
#'   to "020629" as this commodity has non-empty downloads since 2000
#' @param index_fields Character vector of field names to verify test download
#'   against. The default is set to the field names that are currently
#'   present and utilised in the Comtrade processing function. This should
#'   be changed whenever a change in field names has been detected
#' 
#' 
#'

check_comtrade_download_fields <- function(commodity_code = "020629",
                                           index_fields = c(
                                             "period", "reporter_iso", "partner_iso", 
                                             "flow_desc", "cmd_code", "cmd_desc", 
                                             "primary_value"
                                           )) {
  ## Download test commodity dataset ----
  current_date <- format(Sys.Date(), "%Y")

  current_date <- ifelse(
    Sys.Date() < as.Date(paste0(current_date, "-06-30")), 
    as.integer(current_date) - 1,
    current_date
  )
  
  x <- comtradr::ct_get_data(
    start_date = current_date,
    end_date = current_date, 
    commodity_code = commodity_code,
    flow_direction = c("Import", "Re-export", "Export", "Re-import"),
    reporter = "everything",
    partner = "everything"
  )
  
  if (all(index_fields %in% names(x))) {
    message("Currently available Comtrade dataset for download has the expected field names.")
    TRUE
  } else {
    warning(
      "Currently available Comtrade dataset for download has different field names from previous downloads. 
      Please verify and adjust Comtrade processing function accordingly."
    )
    FALSE
  }
}


#'
#' Check FAO download
#' 
#' @param fao_livestock_trade Arrow dataset object of FAO livestock trade read
#'   from FAO livestock download parquet file
#' @param index_fields Character vector of field names to verify current download
#'   against. The default is set to the field names that are currently
#'   present and utilised in the FAO livestock trade processing function. This should
#'   be changed whenever a change in field names has been detected
#' @param index_units Character vector of expected values of the `unit` field
#'   in the current FAO livestock trade processing function. This should be
#'   changed whenever a change in unit values has been detected.
#' 
#' 

check_fao_trade_download <- function(fao_livestock_trade,
                                     index_fields = c(
                                       "Reporter.Countries", "Partner.Countries", 
                                       "Item.Code", "Item", "Element.Code",
                                       "Element", "Year", "Unit", "Value",
                                       "Flag"
                                     ),
                                     index_units = c("An", "1000 An")) {
  ## Check field names ----
  if (all(index_fields %in% names(fao_livestock_trade))) {
    message(
      "Currently available FAO livestock trade dataset downloaded has the expected field names"
    )
  } else {
    stop(
      "Currently available FAO livestock trade dataset downloaded has different field names from previous downloads. 
      Please verify and adjust FAO livestock trade processing function accordingly."
    )
  }
  
  fao_livestock_trade <- dplyr::collect(fao_livestock_trade)
  
  ## Check values in units ----
  if (all(index_units %in% unique(fao_livestock_trade$Unit))) {
    message("Values for the unit field in FAO livestock trade dataset downloaded are as expected.")
  } else {
    stop(
      "Current values for unit field in FAO livestock trade dataset downloaded are different from previous downloads.
      Please verify and adjust FAO livestock trade processing accordingly."
    )
  }
}


#'
#' Check FAO taxa population download
#'
#' @param fao_taxa Arrow dataset object of FAO livestock trade read
#'   from FAO livestock download parquet file
#' @param index_fields Character vector of field names to verify current download
#'   against. The default is set to the field names that are currently
#'   present and utilised in the FAO livestock trade processing function. This should
#'   be changed whenever a change in field names has been detected
#' @param index_units Character vector of expected values of the `unit` field
#'   in the current FAO livestock trade processing function. This should be
#'   changed whenever a change in unit values has been detected.
#'

check_fao_taxa_download <- function(fao_taxa,
                                    index_fields = c("Area", "Item", "Year", "Unit", "Value"),
                                    index_units = c("An", "1000 An")) {
  ## Check field names ----
  if (all(index_fields %in% names(fao_taxa))) {
    message(
      "Currently available FAO taxa dataset downloaded has the expected field names"
    )
  } else {
    stop(
      "Currently available FAO taxa dataset downloaded has different field names from previous downloads. 
      Please verify and adjust FAO taxa processing function accordingly."
    )
  }
  
  fao_taxa <- dplyr::collect(fao_taxa)
  
  ## Check values in units ----
  if (all(index_units %in% unique(fao_taxa$Unit))) {
    message("Values for the unit field in FAO taxa dataset downloaded are as expected.")
  } else {
    stop(
      "Current values for unit field in FAO taxa dataset downloaded are different from previous downloads.
      Please verify and adjust FAO taxa processing accordingly."
    )
  }
}


#'
#' Check WB downloads
#'
#' @param wb_gdp Arrow dataset object of World Bank dataset read from World Bank 
#'   download parquet file
#' @param index_fields Character vector of field names to verify current download
#'   against. The default is set to the field names that are currently
#'   present and utilised in the World Bank dataset processing function. This should
#'   be changed whenever a change in field names has been detected
#'
check_wb_download <- function(wb_data,
                              index_fields = c("countryiso3code", "date", "value")) {
  ## Check field names ----
  if (all(index_fields %in% names(wb_data))) {
    message(
      "Currently available WB dataset downloaded has the expected field names"
    )
  } else {
    stop(
      "Currently available WB dataset downloaded has different field names from previous downloads. 
      Please verify and adjust World Bank dataset processing function accordingly."
    )
  }
}


#'
#' Check WAHIS downloads
#'
#' @param wahis_epi_events_downloaded Path to downloaded WAHIS epi events parquet file
#' @param index_fields Character vector of field names to verify current download
#'   against. The default is set to the field names that are currently
#'   present and utilised in the WAHIS epi events dataset processing function. 
#'   This should be changed whenever a change in field names has been detected
#'

check_wahis_epi_events <- function(wahis_epi_events_downloaded,
                                   index_fields = c(
                                     "terra_aqua", "epi_event_id_unique",
                                     "event_start_date", "event_confirmation_date", 
                                     "event_closing_date", "date_last_occurrence", 
                                     "iso_code", "standardized_disease_name")) {
  ## Read parquet file ----
  wahis_epi_events <- arrow::read_parquet(wahis_epi_events_downloaded)
  
  ## Check field names ----
  if (all(index_fields %in% names(wahis_epi_events))) {
    message(
      "Currently available WAHIS epi events dataset downloaded has the expected field names"
    )
  } else {
    stop(
      "Currently available WAHIS epi events dataset downloaded has different field names from previous downloads. 
      Please verify and adjust WAHIS epi events dataset processing function accordingly."
    )
  }
}



#'
#' Check WAHIS downloads
#'
#' @param wahis_outbreaks_downloaded Path to WAHIS outbreaks dataset parquet file
#' @param index_fields Character vector of field names to verify current download
#'   against. The default is set to the field names that are currently
#'   present and utilised in the WAHIS outbreaks dataset processing function. 
#'   This should be changed whenever a change in field names has been detected
#'

check_wahis_outbreaks <- function(wahis_outbreaks_downloaded,
                                  index_fields = c("epi_event_id_unique", 
                                                   "outbreak_start_date", 
                                                   "outbreak_end_date")) {
  ## Read parquet file ----
  wahis_outbreaks <- arrow::read_parquet(wahis_outbreaks_downloaded)
  
  ## Check field names ----
  if (all(index_fields %in% names(wahis_outbreaks))) {
    message(
      "Currently available WAHIS outbreaks dataset downloaded has the expected field names"
    )
  } else {
    stop(
      "Currently available WAHIS outbreaks dataset downloaded has different field names from previous downloads. 
      Please verify and adjust WAHIS outbreaks dataset processing function accordingly."
    )
  }
}