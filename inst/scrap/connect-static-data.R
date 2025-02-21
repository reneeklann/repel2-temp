# Load packages (in packages.R) and load project-specific functions in R folder ----
suppressPackageStartupMessages(source("packages.R"))
for (f in list.files(here::here("R"), full.names = TRUE)) source (f)


# Read and process supporting data ----
all_countries <- misc_get_country_list(.format = "tibble")
all_countries_years <- misc_process_country_year()
all_connect_countries_years <- misc_process_connect_country_year()


# BLI bird migration ----

## Download BLI bird migration ----
bli_bird_migration_download <- bli_download_bird_migration(here::here("data-raw"))

## Process BLI bird migration ----
connect_static_bli_bird_migration <- bli_process_bird_migration(
  filenames = bli_bird_migration_download, all_countries = all_countries
)


# IUCN wildlife migration ----

## Download IUCN wildlife migration ----
iucn_wildlife_migration_download <- iucn_download_wildlife(
  token = Sys.getenv("IUCN_REDLIST_KEY"), directory = "data-raw"
)

## Process IUCN wildlife migration ----
connect_static_iucn_wildlife_migration <- iucn_process_wildlife_migration(
  path_to_rds = iucn_wildlife_migration_download, all_countries = all_countries
)


# Country shared borders from CIA World Factbook ----

## Process country shared borders data from CIA World Factbook ----
connect_static_shared_borders <- cia_process_country_borders(all_countries = all_countries)


# Country distances ----
connect_static_country_distance <- get_country_distance()





