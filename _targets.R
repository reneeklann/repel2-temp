################################################################################
#
# Project build script
#
################################################################################ 

# Load packages (in packages.R) and load project-specific functions in R folder
suppressPackageStartupMessages(source("packages.R"))
for (f in list.files(here::here("R"), full.names = TRUE)) source (f)

# Pipeline settings --------------------------------------------------------
tar_cue_setting = Sys.getenv("TAR_CUE_SETTING", unset = "thorough") # CAUTION changing this to "never" means targets can miss changes to the code. Use only for developing.

# Livestock model settings ------------------------------------------------------------
livestock_model_time_scale = Sys.getenv("LIVESTOCK_MODEL_TIME_SCALE", unset = "yearly")
livestock_model_max_training_date = Sys.getenv("LIVESTOCK_MODEL_MAX_TRAINING_DATE", unset = "2022-09")
livestock_model_last_data_update =  Sys.getenv("LIVESTOCK_MODEL_LAST_DATA_UPDATE", unset = livestock_model_max_training_date)
livestock_model_overwrite_comtrade = as.logical(Sys.getenv("OVERWRITE_COMTRADE_LIVESTOCK_DOWNLOADED", unset = FALSE))
livestock_model_use_cache =  as.logical(Sys.getenv("LIVESTOCK_MODEL_USE_CACHE", unset = FALSE))

# Crop model settings ----------------------------------------------------------
crop_model_time_scale = Sys.getenv("CROP_MODEL_TIME_SCALE", unset = "yearly")
crop_model_max_training_date = Sys.getenv("CROP_MODEL_MAX_TRAINING_DATE", unset = "2022-09")
crop_model_last_data_update =  Sys.getenv("CROP_MODEL_LAST_DATA_UPDATE", unset = crop_model_max_training_date)
crop_model_overwrite_comtrade = as.logical(Sys.getenv("OVERWRITE_COMTRADE_CROP_DOWNLOADED", unset = FALSE))
crop_model_use_cache =  as.logical(Sys.getenv("CROP_MODEL_USE_CACHE", unset = FALSE))


# Set build options ------------------------------------------------------------
source("_targets_settings.R")

# Common targets ------------------------------------------------------------

## Source data download targets common to both model pipelines
### rerun for prediction updates: source("inst/invalidate_livestock_pipeline.R")
source("tar_plans/_targets_data_downloads_both.R")

## Source data processing targets common to both model pipelines
source("tar_plans/_targets_data_processing_both.R")

# Livestock targets ------------------------------------------------------------

## Source livestock data download targets ----
### rerun for prediction updates: source("inst/invalidate_livestock_pipeline.R")
source("tar_plans/_targets_data_downloads_livestock.R")

## Source livestock data processing targets ----
### rerun for prediction updates: source("inst/invalidate_livestock_pipeline.R")
source("tar_plans/_targets_data_processing_livestock.R")

## Source livestock data augmentation targets ----
if(livestock_model_use_cache){
  source("tar_plans/_targets_data_augment_livestock_cached.R")
} else {
  source("tar_plans/_targets_data_augment_livestock.R")
}

## Source livestock modelling targets ----
if(livestock_model_use_cache){
  source("tar_plans/_targets_model_livestock_cached.R")
} else {
  source("tar_plans/_targets_model_livestock.R")
}

## Source livestock validation targets ----
if(livestock_model_use_cache){
  source("tar_plans/_targets_validation_livestock_cached.R")
} else {
  source("tar_plans/_targets_validation_livestock.R")
}

## Source livestock prediction targets ----
### to run prediction updates: source("inst/invalidate_livestock_pipeline.R") # TODO this also can be accomplished with tar_change
source("tar_plans/_targets_prediction_livestock.R")

## NOWCAST ----
### Not run - model performance is better without nowcast
### source("tar_plans/_targets_nowcast.R")

# Crop targets ------------------------------------------------------------

## Source crop data download targets ----
#source("tar_plans/_targets_data_downloads_crop.R")

## Source crop data processing targets ----
#source("tar_plans/_targets_data_processing_crop.R")

## Source crop data extraction targets ----
#source("tar_plans/_targets_data_extraction_crop.R")

## Source Comtrade crop data download targets ----
source("tar_plans/_targets_data_downloads_comtrade_crop.R")

## Source Comtrade and FAO crop data processing targets ----
source("tar_plans/_targets_data_processing_comtrade_fao_crop.R")

## Source crop data augmentation targets ----
if(crop_model_use_cache){
  source("tar_plans/_targets_data_augment_crop_cached.R")
} else{
  source("tar_plans/_targets_data_augment_crop.R")
}

## Source crop modelling targets ----
if(crop_model_use_cache){
  source("tar_plans/_targets_model_crop_cached.R")
} else {
  source("tar_plans/_targets_model_crop.R")
}

## Source crop validation targets ----
if(crop_model_use_cache){
  source("tar_plans/_targets_validation_crop_cached.R")
} else {
  source("tar_plans/_targets_validation_crop.R")
}

## Source crop prediction targets ----
### to run prediction updates: source("inst/invalidate_crop_pipeline.R") # TODO this also can be accomplished with tar_change
source("tar_plans/_targets_prediction_crop.R")

# Documentation targets ------------------------------------------------------------

## Source documentation targets ----
source("tar_plans/_targets_documentation.R")

# Set seed ----
set.seed(2222)

# List targets (see R/utils.R) ----
all_targets()

