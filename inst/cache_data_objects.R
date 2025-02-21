# This is the script to deposit data and model objects on GitHub

# Create versions on Github for repel2 and repel2-battelle
# Run once
# piggyback::pb_release_create(repo = "ecohealthalliance/repel2", 
#                              tag = "data-cache", 
#                              name = "Data Cache",
#                              body = "Cached model object and associated data objects. Livestock objects are associated with git commit #df5e129. This represents the final version for the REPEL2 SOW.")
# 
# 
# piggyback::pb_release_create(repo = "ecohealthalliance/repel2-battelle", 
#                              tag = "data-cache", 
#                              name = "Data Cache",
#                              body = "Cached model object and associated data objects. Livestock objects are associated with git commit #df5e129. This represents the final version for the REPEL2 SOW.")


# Env variable for tmp directory to save relic objects
dir.create("tmp")
Sys.setenv(RELIC_CACHE_DIR="~/repel2/tmp/")

# Git commit of the livestock data cache version
livestock_gh_commit <- "df5e129"

# Livestock objects to cache
livestock_objects <- c(
  "augmented_livestock_data_disaggregated",
  "augmented_livestock_data_aggregated",
  #"repel_model_updates_report",
  "repel_data_split",
  "repel_validation_data",
  "repel_training_data",
  "repel_training_data_select",
  "repel_predictor_variables",
  "repel_scaling_values",
  "repel_model",
  "repel_validation_data_scaled",
  "repel_validation_predict",
  "repel_confusion_matrix",
  "repel_performance",
  "repel_calibration",
  "repel_calibration_plot",
  "repel_calibration_table",
  "repel_calibration_n_within_range"
)

# For each object, download from AWS using relic into tmp directory, transfer to GitHub
purrr::walk(livestock_objects, function(obj){
  
  relic::tar_read_raw_version(name = obj, ref = livestock_gh_commit)
  
  f_list <- list.files("tmp", recursive = TRUE)
  f_name <- paste0("tmp/", f_list[stringr::str_detect(f_list, "_targets/objects")])
  piggyback::pb_upload(f_name, repo = "ecohealthalliance/repel2")
  piggyback::pb_upload(f_name, repo = "ecohealthalliance/repel2-battelle")
  
  unlink("tmp", recursive = TRUE)
  
})

# Git commit of the crop data cache version
crop_gh_commit <- "69544c0"

# crop objects to cache
crop_objects <- c(
  "extracted_data_processed",
  "connect_crop_outbreaks",
  "augmented_crop_data_disaggregated",
  "augmented_crop_data_aggregated",
  "repel_data_split_crop",
  "repel_validation_data_crop",
  "repel_training_data_crop",
  "repel_training_data_select_crop",
  "repel_predictor_variables_crop",
  "repel_scaling_values_crop",
  "repel_model_crop",
  "repel_validation_data_scaled_crop",
  "repel_validation_predict_crop",
  "repel_confusion_matrix_crop",
  "repel_performance_crop",
  "repel_calibration_crop",
  "repel_calibration_plot_crop",
  "repel_calibration_table_crop",
  "repel_calibration_n_within_range_crop"
  
)

# For each object, download from AWS using relic into tmp directory, transfer to GitHub
purrr::walk(crop_objects, function(obj){
  
  relic::tar_read_raw_version(name = obj, ref = crop_gh_commit)
  
  f_list <- list.files("tmp", recursive = TRUE)
  f_name <- paste0("tmp/", f_list[stringr::str_detect(f_list, "_targets/objects")])
  piggyback::pb_upload(f_name, repo = "ecohealthalliance/repel2")
  piggyback::pb_upload(f_name, repo = "ecohealthalliance/repel2-battelle")
  
  unlink("tmp", recursive = TRUE)
  
})
