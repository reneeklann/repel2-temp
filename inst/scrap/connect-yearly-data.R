# Load packages (in packages.R) and load project-specific functions in R folder ----
suppressPackageStartupMessages(source("packages.R"))
for (f in list.files(here::here("R"), full.names = TRUE)) source (f)


# Read and process supporting data ----
all_countries <- misc_get_country_list(.format = "tibble")
all_countries_years <- misc_process_country_year()
all_connect_countries_years <- misc_process_connect_country_year()


# UN human migration ----

## Download UN human migration dataset ----
un_human_migration_download <- un_download_human_migration(directory = here::here("data-raw"))

## Process UN human migration dataset ----
connect_yearly_un_human_migration <- un_process_human_migration(
  path_to_files = un_human_migration_download,
  all_connect_countries_years = all_connect_countries_years
)


# FAO livestock trade ----

## Download FAO livestock trade dataset ----
fao_livestock_download <- fao_download_livestock(directory = here::here("data-raw"))

## Process FAO livestock trade dataset----

### FAO livestock item code lookup ----
fao_livestock_item_code_lookup <- fao_get_livestock_item_id(path_to_file = fao_livestock_download)

### FAO livestock trade ----
connect_yearly_fao_livestock <-fao_process_livestock(
  path_to_file = fao_livestock_download,
  all_connect_countries_years = all_connect_countries_years
)


# OTS dataset ----


