# Create data dictionary for processed datasets ----


## Shared country borders ----

tar_load(connect_static_shared_borders)

var_name <- names(connect_static_shared_borders)
var_type <- lapply(connect_static_shared_borders, class) |> unlist()
var_description <- c(
  "ISO 3166-1 alpha-3 code for origin or reference country",
  "ISO 3166-1 alpha-3 code for destination or connecting country",
  "Is the origin and destination country sharing borders?",
  "Source of information"
)


table1 <- data.frame(
  table = "connect_static_shared_borders",
  field = var_name,
  field_type = var_type,
  field_description = var_description
)

## Country distances ----

# tar_load(connect_static_country_distance)
# 
# var_name <- names(connect_static_country_distance)
# var_type <- lapply(connect_static_country_distance, class) |> unlist()
# var_description <- c(
#   "ISO 3166-1 alpha-3 code for origin or reference country",
#   "ISO 3166-1 alpha-3 code for destination or connecting country",
#   "Distance between centroids of origin and destination country in metres"
# )
# 
# 
# table2 <- data.frame(
#   table = "connect_static_country_distance",
#   field = var_name,
#   field_type = var_type,
#   field_description = var_description
# )

## World Bank Gross Domestic Product ----

tar_load(country_yearly_gdp)

var_name <- names(country_yearly_gdp)
var_type <- lapply(country_yearly_gdp, class) |> unlist()
var_description <- c(
  "ISO 3166-1 alpha-3 code for reference country",
  "Year in YYYY format",
  "Value of gross domestic product (GDP) in US dollars",
  "Is the value for gross domestic product (GDP) imputed?",
  "Source of information"
)


table3 <- data.frame(
  table = "country_yearl_gdp",
  field = var_name,
  field_type = var_type,
  field_description = var_description
)

## World Bank human population ----

tar_load(country_yearly_human_population)

var_name <- names(country_yearly_human_population)
var_type <- lapply(country_yearly_human_population, class) |> unlist()
var_description <- c(
  "ISO 3166-1 alpha-3 code for reference country",
  "Year in YYYY format",
  "Human population size",
  "Is the human population size imputed?",
  "Source of information"
)


table4 <- data.frame(
  table = "country_yearly_wb_human_population",
  field = var_name,
  field_type = var_type,
  field_description = var_description
)

## UN human migration ----

# tar_load(connect_yearly_un_human_migration)
# 
# var_name <- names(connect_yearly_un_human_migration)
# var_type <- lapply(connect_yearly_un_human_migration, class) |> unlist()
# var_description <- c(
#   "ISO 3166-1 alpha-3 code for origin or reference country",
#   "ISO 3166-1 alpha-3 code for destination or connecting country",
#   "Year in YYYY format",
#   "Number of human migrants between origin and destination country",
#   "Is the value for the number of human migrants imputed?",
#   "Source of information"
# )
# 
# 
# table5 <- data.frame(
#   table = "connect_yearly_un_human_migration",
#   field = var_name,
#   field_type = var_type,
#   field_description = var_description
# )

## IUCN wildlife migration ----

tar_load(connect_static_wildlife_migration)

var_name <- names(connect_static_wildlife_migration)
var_type <- lapply(connect_static_wildlife_migration, class) |> unlist()
var_description <- c(
  "ISO 3166-1 alpha-3 code for origin or reference country",
  "ISO 3166-1 alpha-3 code for destination or connecting country",
  "Number of migratory wildlife between origin and destination country",
  "Is the number of migratory wildlife imputed?",
  "Source of information"
)


table6 <- data.frame(
  table = "connect_static_wildlife_migration",
  field = var_name,
  field_type = var_type,
  field_description = var_description
)

## BLI bird migration ----

# tar_load(connect_static_bli_bird_migration)
# 
# var_name <- names(connect_static_bli_bird_migration)
# var_type <- lapply(connect_static_bli_bird_migration, class) |> unlist()
# var_description <- c(
#   "ISO 3166-1 alpha-3 code for origin or reference country",
#   "ISO 3166-1 alpha-3 code for destination or connecting country",
#   "Number of migratory birds between origin and destination country",
#   "Source of information"
# )
# 
# 
# table7 <- data.frame(
#   table = "connect_static_bli_bird_migration",
#   field = var_name,
#   field_type = var_type,
#   field_description = var_description
# )
## FAO taxa population ----

tar_load(country_yearly_taxa_population)

var_name <- names(country_yearly_taxa_population)
var_type <- lapply(country_yearly_taxa_population, class) |> unlist()
var_description <- c(
  "ISO 3166-1 alpha-3 code for reference country",
  "Year in YYYY format",
  "Disease name",
  "Population size across all taxa affected by disease"
)


table8 <- data.frame(
  table = "country_yearly_taxa_population",
  field = var_name,
  field_type = var_type,
  field_description = var_description
)

## FAO crop production ----

tar_load(country_yearly_crop_production)

var_name <- names(country_yearly_crop_production)
var_type <- lapply(country_yearly_crop_production, class) |> unlist()
var_description <- c(
  "Name of reference country",
  "2-4 digit crop item code",
  "Crop item name",
  "Element (production quantity)",
  "Year in YYYY format",
  "Unit of production quantity",
  "ISO 3166-1 alpha-3 code for reference country",
  "Crop production quantity (in metric tons)",
  "Is the crop production quantity imputed?",
  "Source of information"
)


table9 <- data.frame(
  table = "country_yearly_crop_production",
  field = var_name,
  field_type = var_type,
  field_description = var_description
)

## FAO livestock trade ----

tar_load(connect_yearly_fao_trade_livestock)

var_name <- names(connect_yearly_fao_trade_livestock)
var_type <- lapply(connect_yearly_fao_trade_livestock, class) |> unlist()
var_description <- c(
  "Year in YYYY format",
  "ISO 3166-1 alpha-3 code for origin or reference country",
  "ISO 3166-1 alpha-3 code for destination or connecting country",
  "Value of livestock trade for specific livestock item between origin and destination country",
  "Is the value for livestock trade for specific livestock item between origin and destination country imputed?",
  "Source of information"
)


table10 <- data.frame(
  table = "connect_yearly_fao_trade_livestock",
  field = var_name,
  field_type = var_type,
  field_description = var_description
)

## FAO crop trade ----

tar_load(connect_yearly_fao_trade_crop)

var_name <- names(connect_yearly_fao_trade_crop)
var_type <- lapply(connect_yearly_fao_trade_crop, class) |> unlist()
var_description <- c(
  "Year in YYYY format",
  "ISO 3166-1 alpha-3 code for origin or reference country",
  "ISO 3166-1 alpha-3 code for destination or connecting country",
  "Quantity of all crop items traded between origin and destination country (in metric tons)",
  "Is the quantity of all crop items traded between origin and destination country imputed?",
  "Source of information"
)


table11 <- data.frame(
  table = "connect_yearly_fao_trade_crop",
  field = var_name,
  field_type = var_type,
  field_description = var_description
)

## UN Comtrade ----

tar_load(connect_yearly_comtrade_livestock)

var_name <- names(connect_yearly_comtrade_livestock)
var_type <- lapply(connect_yearly_comtrade_livestock, class) |> unlist()
var_description <- c(
  "Year in YYYY format",
  "ISO 3166-1 alpha-3 code for origin or reference country",
  "ISO 3166-1 alpha-3 code for destination or connecting country",
  "Value in US dollars of trade between origin and destination country",
  "Is the value for trade between origin and destination country imputed?",
  "Source of information"
)


table11 <- data.frame(
  table = "connect_yearly_comtrade_livestock",
  field = var_name,
  field_type = var_type,
  field_description = var_description
)

## COMTRADE crop-related trade ----

tar_load(connect_yearly_comtrade_crop)

var_name <- names(connect_yearly_comtrade_crop)
var_type <- lapply(connect_yearly_comtrade_crop, class) |> unlist()
var_description <- c(
  "Year in YYYY format",
  "ISO 3166-1 alpha-3 code for origin or reference country",
  "ISO 3166-1 alpha-3 code for destination or connecting country",
  "Value in US dollars of trade between origin and destination country",
  "Is the value of trade between origin and destination country imputed?",
  "Source of information"
)


table12 <- data.frame(
  table = "connect_yearly_comtrade_crop",
  field = var_name,
  field_type = var_type,
  field_description = var_description
)

## WOAH veterinarian population ----

tar_load(country_yearly_vet_population)

var_name <- names(country_yearly_vet_population)
var_type <- lapply(country_yearly_vet_population, class) |> unlist()
var_description <- c(
  "ISO 3166-1 alpha-3 code for reference country",
  "Year in YYYY format",
  "Number of veterinarians",
  "Is the value for the number of veterinarians imputed?",
  "Source of information"
)


table13 <- data.frame(
  table = "country_yearly_vet_population",
  field = var_name,
  field_type = var_type,
  field_description = var_description
)

## WAHIS EPI events ----

table14 <- httr::GET(
  url = "https://www.dolthub.com/csv/ecohealthalliance/wahisdb/main/schema_fields",
  config = httr::add_headers(authorization = Sys.getenv("DOLT_TOKEN"))
) |>
  httr::content(as = "parsed", type = "text/csv", show_col_types = FALSE) |>
  dplyr::filter(table == "wahis_epi_events") |>
  dplyr::select(field, field_type, field_description) |>
  #write.csv(file = "inst/data_dictionary/wahis_epi_events.csv", row.names = FALSE)
  dplyr::mutate(table = "wahis_epi_events", .before = field)

## WAHIS outbreaks ----

table15 <- httr::GET(
  url = "https://www.dolthub.com/csv/ecohealthalliance/wahisdb/main/schema_fields",
  config = httr::add_headers(authorization = Sys.getenv("DOLT_TOKEN"))
) |>
  httr::content(as = "parsed", type = "text/csv", show_col_types = FALSE) |>
  dplyr::filter(table == "wahis_outbreaks") |>
  dplyr::select(field, field_type, field_description) |>
  #write.csv(file = "inst/data_dictionary/wahis_outbreaks.csv", row.names = FALSE)
  dplyr::mutate(table = "wahis_outbreaks", .before = field)

## EPPO Reporting Service ----

tar_load(eppo_index_processed)

var_name <- names(eppo_index_processed)
var_type <- lapply(eppo_index_processed, class) |> unlist()
var_description <- c(
  "Source of information",
  "Name of pest/pathogen",
  "Name of country",
  "ISO 3166-1 alpha-3 code for country",
  "Continent of country",
  "Year article was published in YYYY format",
  "Issue number in which article was published",
  "Article number in year/number format",
  "Title of article",
  "Full text of article",
  "First keyword describing content of article (e.g. new record, detailed record, absence, etc.)",
  "Second keyword describing content of article",
  "URL of article",
  "Common name of pest/pathogen",
  "Scientific name of pest/pathogen",
  "EPPO code of pest/pathogen",
  "Whether pest/pathogen is a project priority",
  "Pest/pathogen name used by IPPC",
  "Pest/pathogen name used by NAPPO",
  "Kingdom of pest/pathogen",
  "Phylum of pest/pathogen",
  "class of pest/pathogen",
  "Order of pest/pathogen",
  "Family of pest/pathogen",
  "Genus of pest/pathogen",
  "Species of pest/pathogen",
  "Mode of transmission of pest/pathogen",
  "Crops affected by pest/pathogen",
  "Source of lookup table information"
)


table16 <- data.frame(
  table = "eppo_index_processed",
  field = var_name,
  field_type = var_type,
  field_description = var_description
)

## IPPC pest reports ----

tar_load(ippc_table_processed)

var_name <- names(ippc_table_processed)
var_type <- lapply(ippc_table_processed, class) |> unlist()
var_description <- c(
  "Name of country that provided report",
  "ISO 3166-1 alpha-3 code for country that provided report",
  "Continent of country that provided report",
  "Unique report number",
  "Year report was published in YYYY format",
  "Date report was published in YYYY-MM-DD format",
  "Date report was last updated in YYYY-MM-DD format",
  "Name of pest/pathogen",
  "Name of host plant(s)",
  "Status of pest according to ISPM categories",
  "Title of report",
  "URL of report",
  "EPPO code of pest/pathogen given in report",
  "Source of information",
  "Full text of report",
  "Whether report references and includes link to report from NAPPO",
  "Common name of pest/pathogen",
  "Scientific name of pest/pathogen",
  "EPPO code of pest/pathogen",
  "Whether pest/pathogen is a project priority",
  "Pest/pathogen name used by EPPO",
  "Pest/pathogen name used by NAPPO",
  "Kingdom of pest/pathogen",
  "Phylum of pest/pathogen",
  "class of pest/pathogen",
  "Order of pest/pathogen",
  "Family of pest/pathogen",
  "Genus of pest/pathogen",
  "Species of pest/pathogen",
  "Mode of transmission of pest/pathogen",
  "Crops affected by pest/pathogen",
  "Source of lookup table information"
)


table17 <- data.frame(
  table = "ippc_table_processed",
  field = var_name,
  field_type = var_type,
  field_description = var_description
)

## NAPPO pest reports ----

tar_load(nappo_table_processed)

var_name <- names(nappo_table_processed)
var_type <- lapply(nappo_table_processed, class) |> unlist()
var_type <- var_type[-7]
var_description <- c(
  "Name of country that provided report",
  "ISO 3166-1 alpha-3 code for country that provided report",
  "Continent of country that provided report",
  "Title of report",
  "Year report was published in YYYY format",
  "Date report was published in YYYY-MM-DD format",
  "URL of report",
  "Source of information",
  "Name of pest/pathogen",
  "Full text of report",
  "Common name of pest/pathogen",
  "Scientific name of pest/pathogen",
  "EPPO code of pest/pathogen",
  "Whether pest/pathogen is a project priority",
  "Pest/pathogen name used by EPPO",
  "Pest/pathogen name used by IPPC",
  "Kingdom of pest/pathogen",
  "Phylum of pest/pathogen",
  "class of pest/pathogen",
  "Order of pest/pathogen",
  "Family of pest/pathogen",
  "Genus of pest/pathogen",
  "Species of pest/pathogen",
  "Mode of transmission of pest/pathogen",
  "Crops affected by pest/pathogen",
  "Source of lookup table information"
)


table18 <- data.frame(
  table = "nappo_table_processed",
  field = var_name,
  field_type = var_type,
  field_description = var_description
)

## WAHIS augmented datasets

targets::tar_load(c(augmented_livestock_data_aggregated, augmented_livestock_data_disaggregated))

var_name <- names(augmented_livestock_data_aggregated)
var_type <- lapply(augmented_livestock_data_aggregated, class) |> unlist()
var_description <- c(
  "ISO 3166-1 alpha-3 code for reference country",
  "Name of continent to which reference country belongs to",
  "Is disease present anywhere?",
  "Name of disease",
  "Prediction window",
  "Reference country GDP in log dollars",
  "Reference country log human population",
  "Reference country log target taxa population",
  "Reference country log number of veterinarians",
  "Has an outbreak started in reference country?",
  "Is there an ongoing outbreak in the reference country?",
  "Is disease endemic in reference country?",
  "Number of migratory wildlife coming into reference country from countries with outbreaks of the disease",
  "Number of borders shared by reference country from countries with outbreaks of the disease",
  "Trade in dollars received by reference country from countries with outbreaks of the disease",
  "Number of livestock heads received by reference country from countries with outbreaks of the disease"
)

table19 <- data.frame(
  table = "augmented_livestock_data_aggregated",
  field = var_name,
  field_type = var_type,
  field_description = var_description
)

var_name <- names(augmented_livestock_data_disaggregated)
var_type <- lapply(augmented_livestock_data_disaggregated, class) |> unlist()
var_description <- c(
  "ISO 3166-1 alpha-3 code for reference country",
  "Name of continent to which reference country belongs to",
  "Is disease present anywhere?",
  "Name of disease",
  "Year in YYYY-MM-DD format",
  "Prediction window",
  "Reference country GDP in log dollars",
  "Reference country log human population",
  "Reference country log target taxa population",
  "Reference country log number of veterinarians",
  "Has an outbreak started in reference country?",
  "Is there an ongoing outbreak in the reference country?",
  "Is disease endemic in reference country?",
  "Number of migratory wildlife coming into reference country from countries with outbreaks of the disease",
  "Number of borders shared by reference country from countries with outbreaks of the disease",
  "Trade in dollars received by reference country from countries with outbreaks of the disease",
  "Number of livestock heads received by reference country from countries with outbreaks of the disease"
)

table20 <- data.frame(
  table = "augmented_livestock_data_disaggregated",
  field = var_name,
  field_type = var_type,
  field_description = var_description
)


## Combine dictionaries ----

rbind(
  table1, table3, table4, table6, table8, table9, table10, table11, table12, 
  table13, table14, table15, table16, table17, table18, table19, table20
) |>
  write.csv("inst/data_dictionary.csv", row.names = FALSE)
