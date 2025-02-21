# Load packages (in packages.R) and load project-specific functions in R folder ----
suppressPackageStartupMessages(source("packages.R"))
for (f in list.files(here::here("R"), full.names = TRUE)) source (f)

# Read and process supporting data ----
all_countries <- misc_get_country_list(.format = "tibble")
all_countries_years <- misc_process_country_year()
all_connect_countries_years <- misc_process_connect_country_year()

# World Bank Indicators ----

## Get WB data via API ----
wb_data <- wb_get_indicators(
  indicators_list = list(
    gdp_dollars = "NY.GDP.MKTP.CD", human_population = "SP.POP.TOTL"
  )
)

## WB GDP ----
country_yearly_wb_gdp <- wb_process_gdp(wb_data, all_countries_years)


## WB human population ----
country_yearly_wb_human_population <- wb_process_human_pop(wb_data, all_countries_years)


# FAO taxa population ----

## Download FAO data
fao_taxa_population_download <- fao_download_taxa_population(here::here("data-raw"))

## Process taxa population data
country_yearly_fao_taxa_population <- fao_process_taxa_population(
  path_to_zip = fao_taxa_population_download,
  all_countries_years = all_countries_years
)


# Veterinarian population date ----



