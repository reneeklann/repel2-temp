# Convenience script to change fields in comtrade data from camel to snake case

suppressPackageStartupMessages(source("packages.R"))
for (f in list.files(here::here("R"), full.names = TRUE)) source (f)

directory <- tar_read(comtrade_livestock_raw_directory) # can also enter comtrade_crop_raw_directory

# List the files in the directory (remove empty files and anything downloaded since end of 2023)
files <- list.files(directory, full.names = TRUE)
files <- files[!stringr::str_detect(files, "empty")]
files <- files[lubridate::as_date(file.info(files)$mtime) < "2024-01-01"]

# Extract the existing (pre-2024) field names (camel case)
field_names_camel <- arrow::open_dataset(files) |> 
  arrow::schema() |> 
  (\(x) x$names)()

# Convert these names to snake case
field_names_snake <- janitor::make_clean_names(field_names_camel)

# Check to confirm this matches field names from 2024 downloads
# check  <- arrow::read_parquet("data-raw/comtrade-livestock/2012_2023_960190.gz.parquet") # downloaded Jan 8th 2024
# all(names(check) == field_names_snake)

# Iterate through the files and rename the fields
for(file in files){
  arrow::open_dataset(file) |> 
    dplyr::rename(purrr::set_names(field_names_camel, field_names_snake)) |> 
    arrow::write_parquet(sink = file)
}
