# Data dictionary for raw data downloads ----

## Create data dictionary directory in inst ----
# dir.create("inst/data_dictionary_raw", showWarnings = FALSE)

## Helper function to create CSV for data dictionary for dataset ----
# output_dict_csv <- function(var_name, var_type, var_description,
#                             filename) {
#   write.csv(
#     x = data.frame(
#       field = var_name, field_type = var_type, field_description = var_description
#     ),
#     file = filename, row.names = FALSE
#   )
#   
#   filename
# }

## CIA World Factbook shared borders ----

# path_to_zip <- "data-raw/cia-world-factbook/cia-world-factbook.zip"
# 
# unzip(
#   zipfile = path_to_zip,
#   files = "factbook-2020/fields/281.html",
#   exdir = dirname(path_to_zip)
# )
# 
# page <- file.path(dirname(path_to_zip), "factbook-2020/fields/281.html") |>
#   xml2::read_html()

## World Bank ----
indicators_list <- list(
  gdp_dollars = "NY.GDP.MKTP.CD", human_population = "SP.POP.TOTL"
)

inds <- purrr::imap(
  indicators_list, function(code, name) {
    ind <- jsonlite::fromJSON(
      paste0(
        "http://api.worldbank.org/v2/country/all/indicator/", code, 
        "?per_page=20000&format=json"
      )
    )
    
    ind <- ind[[2]] |>
      dplyr::select(country_iso3c = countryiso3code, year = date, value) |>
      dplyr::as_tibble() |>
      dplyr::filter(country_iso3c != "") |>
      tidyr::drop_na() |>
      dplyr::mutate(year = as.integer(year))
    
    names(ind)[3] <- name
    return(ind)
  }
)

wb_data <- Reduce(
  function(x, y) {
    dplyr::full_join(x, y, by = c("country_iso3c", "year"))
  },
  inds,
  dplyr::tibble(country_iso3c = character(0), year = integer(0))
)

var_name <- names(wb_data)
var_type <- lapply(wb_data, class) |> unlist()
var_description <- c(
  "ISO 3166-1 alpha-3 code for reference country",
  "Year in YYYY format",
  "Value for GDP in US Dollars",
  "Value for human population size"
)

wb_data <- data.frame(
  table = "world_bank_data",
  field = var_name,
  field_type = var_type,
  field_description = var_description
)

# output_dict_csv(
#   var_name, var_type, var_description,
#   filename = "inst/data_dictionary_raw/wb_data.csv"
# )

# ## FAO taxa and livestock ----
# 
# path_to_zip <- "data-raw/fao-taxa-population/fao-taxa-population.zip"
#   
# unzip(zipfile = path_to_zip, exdir = "data-raw/fao-taxa-population")
# 
# fao <- vroom::vroom(
#   file = file.path(
#     "data-raw/fao-taxa-population", "Production_Crops_Livestock_E_All_Data_(Normalized).csv"
#   ), 
#   col_types = cols(
#     `Area Code` = col_skip(),
#     Area = col_character(),
#     `Item Code` = col_skip(),
#     Item = col_character(),
#     `Element Code` = col_skip(),
#     Element = col_skip(),
#     `Year Code` = col_skip(),
#     Year = col_double(),
#     Unit = col_character(),
#     Value = col_double(),
#     Flag = col_skip()
#   ), 
#   locale = vroom::locale(encoding = "Latin1")) |>
#   janitor::clean_names()
# 
# var_name <- names(fao)
# var_type <- lapply(fao, class) |> unlist()
# var_description <- c(
#   "UN m49 area code",
#   "Reference country",
#   "FAO code for crop or livestock items",
#   "Name of crop or livestock items",
#   "Year in YYYY format",
#   "Units for value",
#   "Value for specific crop or livestock item"
# )
# 
# output_dict_csv(
#   var_name, var_type, var_description,
#   filename = "inst/data_dictionary_raw/fao_data.csv"
# )

## FAO crop production and taxa population ----

download_file = "data-raw/fao-production/Production_Crops_Livestock_E_All_Data_(Normalized).gz.parquet"

fao_production <- arrow::open_dataset(download_file) |> 
  dplyr::select(area = Area, item_code = Item.Code, item = Item, 
                element = Element, year = Year, unit = Unit, value = Value) |>
  dplyr::collect()

var_name <- names(fao_production)
var_type <- lapply(fao_production, class) |> unlist()
var_description <- c(
  "Reference country",
  "FAO code for crop or livestock item",
  "Name of crop or livestock item",
  "Type of production measured (e.g. area harvested, quantity by weight, number of animals)",
  "Year in YYYY format",
  "Units for value",
  "Value for specific crop or livestock item"
)

fao_production_data <- data.frame(
  table = "fao_production_data",
  field = var_name,
  field_type = var_type,
  field_description = var_description
)

# output_dict_csv(
#   var_name, var_type, var_description,
#   filename = "inst/data_dictionary_raw/fao_production_data.csv"
# )

## FAO trade (crops and livestock) ----

download_file = "data-raw/fao-trade/Trade_DetailedTradeMatrix_E_All_Data_(Normalized).gz.parquet"

fao_trade <- arrow::open_dataset(download_file) |>
  dplyr::select(reporter_countries = Reporter.Countries, 
                partner_countries = Partner.Countries, item_code = Item.Code, 
                item = Item, element_code = Element.Code, element = Element, 
                year = Year, unit = Unit, value = Value, flag = Flag) |>
  dplyr::collect()

var_name <- names(fao_trade)
var_type <- lapply(fao_trade, class) |> unlist()
var_description <- c(
  "Reporter country",
  "Partner country",
  "FAO code for crop or livestock item",
  "Name of crop or livestock item",
  "Code corresponding to import/export, quantity/value, and unit",
  "Whether trade is reported as export quantity, export value, import quantity, or import value",
  "Year in YYYY format",
  "Units for value",
  "Value for trade of specific crop or livestock item",
  "Flags (e.g. official figure, estimated value)"
)

fao_trade_data <- data.frame(
  table = "fao_trade_data",
  field = var_name,
  field_type = var_type,
  field_description = var_description
)

# output_dict_csv(
#   var_name, var_type, var_description,
#   filename = "inst/data_dictionary_raw/fao_trade_data.csv"
# )

## Bird migration ----

filenames <- list.files("data-raw/bli-bird-migration", full.names = TRUE)

## Wildlife migration ----

df <- arrow::open_dataset("data-raw/iucn-wildlife/iucn_wildlife.gz.parquet")

var_name <- names(df)
var_type <- lapply(dplyr::collect(df), class) |> unlist()
var_description <- c(
  "Taxonomic identifier provided by IUCN",
  "Scientific name",
  "Subspecies name",
  "Taxonomic rank",
  "Sub-population name",
  "IUCN Red List classification",
  "Country name"
)

iucn_wildlife_data <- data.frame(
  table = "iucn_wildlife_data",
  field = var_name,
  field_type = var_type,
  field_description = var_description
)

# output_dict_csv(
#   var_name, var_type, var_description,
#   filename = "inst/data_dictionary_raw/iucn_data.csv"
# )

## Migrant data ----

# path_to_file <- list.files("data-raw/un-human-migration", full.names = TRUE)[1]

#df <- readxl::read_xlsx(path_to_files[1])

# get country name from file
# country <- basename(path_to_file) |> stringr::str_remove(".xlsx")
#   
# if (country == "Republic of Moldova") { country <- "Rep of Moldova" }
# if (country == "Russian Federation") { country <- "Russian Fed" }
#   
# country_iso3c <- countrycode::countrycode(
#   country, origin = "country.name", destination = "iso3c"
# )
#   
# sheets <- readxl::excel_sheets(path_to_file)
# sheet_pref1 <- paste(country, "by Residence")
# sheet_pref2 <- paste(country, "by Citizenship")
# sheet <- ifelse(sheet_pref1 %in% sheets, sheet_pref1, sheet_pref2)
# 
# df <- readxl::read_xlsx(path_to_file, sheet = sheet, skip = 20) |>
#   janitor::clean_names() |>
#   dplyr::select(type, coverage, od_name, area, area_name, reg, reg_name, dev, dev_name)
# 
# var_name <- names(df)
# var_type <- lapply(df, class) |> unlist()
# var_description <- c(
#   "Type of migration. Can be either Emigrants or Immigrants",
#   "Coverage of information",
#   "Name of country of origin",
#   "Code for continent of country of origin",
#   "Name for continent of country of origin",
#   "Code for region of country of origin",
#   "Name for region of country of origin",
#   "Code for development status",
#   "Name for development status"
# )
# 
# output_dict_csv(
#   var_name, var_type, var_description,
#   filename = "inst/data_dictionary_raw/human_migration_data.csv"
# )

## Veterinarian population ----

df <- readxl::read_excel(path = "data-raw/woah-vet-population/Veterinarians_Vet_paraprofessionals.xlsx")

var_name <- names(df)
var_type <- lapply(df, class) |> unlist()
var_description <- c(
  "Name of reference country",
  "ISO 3166-1 alpha-3 code for reference country",
  "Year in YYYY format",
  "Number of veterinarians in animal health activities specifically in public administration",
  "Number of veterinarians in animal health activities specifically as private accredited practitioners",
  "Number of veterinarians in animal health activities in total",
  "Number of veterinarians in public health activities specifically in public administration",
  "Number of veterinarians in public health activities specifically as private accredited practitioners",
  "Number of veterinarians in public health activities in total",
  "Number of veterinarians in laboratories specifically in public administration",
  "Number of veterinarians in laboratories specifically as private accredited practitioners",
  "Number of veterinarians in laboratories in total",
  "Number of veterinarians in academic/training institutions",
  "Number of veterinary paraprofessionals in animal health activities",
  "Number of veterinary paraprofessionals in community animal health activities"
)

vet_population_data <- data.frame(
  table = "vet_population_data",
  field = var_name,
  field_type = var_type,
  field_description = var_description
)

# output_dict_csv(
#   var_name, var_type, var_description,
#   filename = "inst/data_dictionary_raw/vet_population_data.csv"
# )

## COMTRADE trade data ----

download_file = "data-raw/comtrade-livestock/2012_2023_960190.gz.parquet"

comtrade_dictionary <- readxl::read_xlsx(
  path = "inst/ComtradePlus - data items - 17 Mar 2020.xlsx",
  sheet = 1
) |>
  dplyr::filter(!`COMTRADE+ DATA ITEMS` %in% c("datasetCode", "flowCategory", "mosDesc"))

comtrade_data <- arrow::open_dataset(download_file) |>
  dplyr::collect()

var_name <- names(comtrade_data)
var_type <- lapply(comtrade_data, class) |> unlist()
var_description <- comtrade_dictionary$Description

comtrade_data <- data.frame(
  table = "comtrade_data",
  field = var_name, 
  field_type = var_type, 
  field_description = var_description
)


# output_dict_csv(
#   var_name, var_type, var_description,
#   filename = "inst/data_dictionary_raw/comtrade_data.csv"
# )

## EPPO index ----

eppo_index <- readxl::read_xlsx("data-raw/eppo-crop-reports/index_1967to2023.xlsx")

eppo_index <- eppo_index |>
  dplyr::rename(
    pest = Pest,
    country = Country,
    year_published = Year,
    issue = Issue,
    article_number = `RS Item`,
    title = Title,
    keyword1 = `Add Kwords1`,
    keyword2 = `Add Kwords2`
  )

var_name <- names(eppo_index)
var_type <- lapply(eppo_index, class) |> unlist()
var_description <- c(
  "Name of pest/pathogen",
  "Name of reference country",
  "Year article was published in YYYY format",
  "Issue number in which article was published",
  "Article number in year/number format",
  "Title of article",
  "First keyword describing content of article (e.g. new record, detailed record, absence)",
  "Second keyword describing content of article"
)

eppo_index_data <- data.frame(
  table = "eppo_index_data",
  field = var_name,
  field_type = var_type,
  field_description = var_description
)

## Combine raw data dictionaries ----

data_dictionary_raw <- rbind(
  wb_data, fao_production_data, fao_trade_data, iucn_wildlife_data,
  vet_population_data, comtrade_data, eppo_index_data
)

write.csv(data_dictionary_raw, "inst/data_dictionary_raw.csv", row.names = FALSE)

# output_dict_csv(
#   var_name, var_type, var_description,
#   filename = "inst/data_dictionary_raw/eppo_index_data.csv"
# )


## Combine dictionaries ----

# create_data_dict_worksheet <- function(file_path, wb) {
#   df <- read.csv(file_path)
#   
#   sheet_name <- basename(file_path)
#   
#   openxlsx::addWorksheet(wb = wb, sheetName = sheet_name)
#   
#   openxlsx::writeData(wb = wb, sheet = sheet_name, x = df)
#   
#   openxlsx::setColWidths(
#     wb = wb, sheet = sheet_name, 
#     cols = seq_len(ncol(df)), widths = "auto"
#   )
# }
# 
# 
# create_data_dict_xlsx <- function(file_paths, filename) {
#   data_dict_wb <- openxlsx::createWorkbook()
#   
#   lapply(
#     X = file_paths,
#     FUN = create_data_dict_worksheet,
#     wb = data_dict_wb
#   )
#   
#   openxlsx::saveWorkbook(wb = data_dict_wb, file = filename, overwrite = TRUE)
# }
# 
# create_data_dict_xlsx(
#   file_paths = list.files("inst/data_dictionary_raw", full.names = TRUE), 
#   filename = "inst/data_dictionary_raw.xlsx"
# )
# 
# 
# create_data_dict_set <- function(file_path) {
#   df <- read.csv(file_path)
#   
#   table_name <- basename(file_path) |> stringr::str_remove_all(".csv")
#   
#   df <- data.frame(table = table_name, df)
# }
# 
# create_data_dict_csv <- function(file_paths, filename) {
#   
#   lapply(
#     X = file_paths,
#     FUN = create_data_dict_set
#   ) |>
#     dplyr::bind_rows() |>
#     write.csv(file = filename, row.names = FALSE)
# }
# 
# create_data_dict_csv(
#   file_paths = list.files("inst/data_dictionary_raw", full.names = TRUE), 
#   filename = "inst/data_dictionary_raw.csv"
# )

#write.csv(xx, file = "inst/data_dictionary.csv", row.names = FALSE)




