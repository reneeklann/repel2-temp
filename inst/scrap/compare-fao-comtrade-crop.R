# compare coverage overlap between FAO crop trade in tonnes and COMTRADE dollars

# load packages (in packages.R) and load project-specific functions in R folder
suppressPackageStartupMessages(source("packages.R"))
for (f in list.files(here::here("R"), full.names = TRUE)) source (f)



# COMTRADE CROP DATA -----------------------------------------------
targets::tar_load(comtrade_crop_downloaded)

comtrade_commodity_codes <-  dplyr::left_join(
  tradestatistics::ots_commodities, 
  tradestatistics::ots_sections, 
  by = c("section_code", "section_fullname_english")
  ) |> 
  # vegetable products, wood, ag equipment
  dplyr::filter(section_code == "02" | 
                section_code == "09" | 
                commodity_code %in% c("820110", "820130", "820140", "820150", "820160", 
                                      "820190", "820840", "842481", "843210", "843221", 
                                      "843229", "843230", "843240", "843290", "843330", 
                                      "843340", "843351", "843352", "843353", "843359", 
                                      "843360", "843390", "843680", "843699", "871620")
                )

comtrade_files <- comtrade_crop_downloaded[!stringr::str_detect(comtrade_crop_downloaded, "empty")]
comtrade_files <- comtrade_files[stringr::str_detect(comtrade_files, paste(comtrade_commodity_codes$commodity_code, collapse = "|"))]

# now process following steps in process_comtrade()
comtrade <- arrow::open_dataset(comtrade_files)

# cmd code lookup 
cmd_code_lookup <- comtrade |> dplyr::distinct(cmd_code, cmd_desc) |> dplyr::collect()

# initial processing
comtrade <- comtrade |>
  dplyr::select(year = period,
                reporter_iso,
                partner_iso,
                flow_desc, 
                commodity_code = cmd_code,
                value = primary_value) |>
  dplyr::mutate(year = as.integer(year)) |>
  dplyr::filter(!is.na(value))

# add re-imports and re-exports into total import and export values
comtrade <- comtrade |> 
  dplyr::mutate(flow_desc = tolower(stringr::str_remove(flow_desc, "Re-"))) |> 
  dplyr::group_by(year, reporter_iso, partner_iso, commodity_code, flow_desc) |>
  dplyr::summarize(value = sum(value)) |> 
  dplyr::ungroup()

# assign country destination and origin
# for trades reported more than once (as import and export), assume max value
comtrade_bilateral <- comtrade |> 
  dplyr::mutate(country_origin = ifelse(flow_desc == "export", reporter_iso, partner_iso)) |> 
  dplyr::mutate(country_destination = ifelse(flow_desc == "export", partner_iso, reporter_iso)) |> 
  dplyr::select(-flow_desc, -reporter_iso, -partner_iso)   |> 
  dplyr::group_by(year, commodity_code, country_origin, country_destination) |>
  arrow::to_duckdb() |> # duckdb required for moving window functions
  dplyr::filter(value == max(value, na.rm = TRUE)) |> 
  arrow::to_arrow() |> 
  dplyr::distinct() |>
  dplyr::ungroup()  |> 
  dplyr::collect() |> 
  dplyr::left_join(comtrade_commodity_codes)|> 
  dplyr::filter(year >= 1993)



# FAO CROP TRADE DATA -----------------------------------------------
targets::tar_load(fao_trade_downloaded)
targets::tar_load(fao_trade_crop_item_codes)

# initial processing - filter by unit, year, and crop item codes
fao_crop_trade <- arrow::open_dataset(fao_trade_downloaded) |>
  dplyr::select(reporter_countries = Reporter.Countries,
                partner_countries = Partner.Countries,
                item_code = Item.Code,
                item = Item,
                element_code = Element.Code,
                element = Element,
                year = Year,
                unit = Unit,
                value = Value,
                flag = Flag) |>
  dplyr::filter(year >= 1993) |>
  dplyr::filter(unit == "t") |>
  dplyr::filter(item_code %in% fao_trade_crop_item_codes) |>
  dplyr::filter(!is.na(value))

# item code lookup - this can be used to pair with target taxa population
item_code_lookup <- fao_crop_trade |> dplyr::distinct(item, item_code) |> dplyr::collect()

# get country iso3c
fao_countries <- fao_crop_trade |>
  dplyr::distinct(reporter_countries, partner_countries) |>
  dplyr::collect() |>
  tidyr::pivot_longer(cols = c(reporter_countries, partner_countries)) |>
  dplyr::select(country_name = value) |>
  dplyr::distinct() |>
  dplyr::mutate(country_name_utf8 = iconv(country_name, from = "latin1", to = "UTF-8")) |>
  dplyr::mutate(country_iso3c = suppressWarnings(countrycode::countrycode(
    country_name_utf8, origin = "country.name", destination = "iso3c"
  ))) |>
  dplyr::select(-country_name_utf8)

fao_crop_trade <- fao_crop_trade |>
  dplyr::left_join(fao_countries, by = c("reporter_countries" = "country_name")) |>
  dplyr::rename(reporter_iso = country_iso3c) |>
  dplyr::left_join(fao_countries, by = c("partner_countries" = "country_name")) |>
  dplyr::rename(partner_iso = country_iso3c) |>
  dplyr::filter(!is.na(reporter_iso), !is.na(partner_iso)) |>
  dplyr::filter(reporter_iso != partner_iso) |>
  dplyr::select(year, reporter_iso, partner_iso, element, item_code, value)

# assign country destination and origin
# for trades reported more than once (as import and export), assume max value
fao_bilateral <- fao_crop_trade |>
  dplyr::mutate(country_origin = ifelse(element == "Export Quantity", reporter_iso, partner_iso)) |>
  dplyr::mutate(country_destination = ifelse(element == "Export Quantity", partner_iso, reporter_iso)) |>
  dplyr::select(-element, -reporter_iso, -partner_iso)  |>
  dplyr::group_by(year, item_code, country_origin, country_destination) |>
  arrow::to_duckdb() |> # duckdb required for moving window functions
  dplyr::filter(value == max(value, na.rm = TRUE)) |>
  arrow::to_arrow() |>
  dplyr::distinct() |>
  dplyr::ungroup() |>
  dplyr::collect() |> 
  dplyr::left_join(item_code_lookup) |>
  dplyr::filter(year >= 1993)



# compare -----------------------------------------------------------------

nrow(fao_bilateral)
nrow(comtrade_bilateral)

nrow(fao_bilateral |> dplyr::distinct(country_origin, country_destination))
nrow(comtrade_bilateral |> dplyr::distinct(country_origin, country_destination))

fao_bilateral$item |> unique()
comtrade_bilateral$commodity_fullname_english |> unique()

# COMTRADE has about 20% more origin/destination pairs
