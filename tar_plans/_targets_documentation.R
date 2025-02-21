# Targets for documentation ----

## Documentation ----
documentation_targets <- tar_plan(
  
  ### Readme
  tar_render(name = readme, path = "README.Rmd"),
  
  ### Crop data report
  tar_render(
    name = crop_data_report,
    path = "reports/crop-data-eval.Rmd",
    knit_root_dir = here::here()
  ),
  
  # ### Crop data ingest pipeline vignette ----
  # tar_render(
  #   name = crop_data_ingest_pipeline_vignette,
  #   path = "vignettes/crop_data_ingest_pipeline.Rmd",
  #   knit_root_dir = here::here()
  # ),
  
  ### Livestock model pipeline vignette ----
  # tar_render(
  #   name = livestock_model_pipeline_vignette, 
  #   path = "vignettes/livestock_model_pipeline.Rmd", 
  #   knit_root_dir = here::here()
  # ),
  
  ### Crop model pipeline vignette ----
  # tar_render(
  #   name = crop_model_pipeline_vignette, 
  #   path = "vignettes/crop_model_pipeline.Rmd", 
  #   knit_root_dir = here::here()
  # ),
  
  ### Veterinary model results ----
  tar_target(
    repel_model_updates_report_file, "reports/repel_model_updates.Rmd",
    format = "file", repository = "local"
  ),
  tar_target(
    repel_model_updates_report,
    render_report(
      path = repel_model_updates_report_file,
      dependencies = c(repel_model,
                       repel_confusion_matrix, 
                       repel_performance,
                       repel_calibration,
                       repel_calibration_plot,
                       repel_calibration_table,
                       repel_calibration_n_within_range,
                       repel_validation_predict
      )
    ),
    format = "file", repository = "local",
    cue = tar_cue(tar_cue_setting)
  ),
  
  ### Veterinary model Phase I v II comparison ----
  #### see `reports/repel_model_comparison.html`
  #### this report is run outside of the targets pipeline because it depends on
  #### versioning history specific to EHA's pipeline
  
  ### Crop model results ----
  tar_target(
    repel_crop_model_updates_report_file, "reports/repel_crop_model_updates.Rmd",
    format = "file", repository = "local"
  ),
  tar_target(
    repel_crop_model_updates_report,
    render_report(
      path = repel_crop_model_updates_report_file,
      dependencies = c(
        extracted_data,
        extracted_data_processed,
        repel_data_split_crop,
        # priority_diseases,
        repel_model_crop,
        repel_confusion_matrix_crop,
        repel_performance_crop,
        repel_calibration_crop,
        repel_calibration_plot_crop,
        repel_calibration_table_crop,
        repel_calibration_n_within_range_crop,
        repel_validation_predict_crop
      )
    ),
    format = "file", repository = "local"
  )
)

