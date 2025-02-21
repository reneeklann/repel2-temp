tar_option_set(
  error = Sys.getenv("TARGETS_ERROR", unset = "stop"), # allow branches to error without stopping the pipeline
  workspace_on_error = TRUE, # allows interactive session for failed branches
  format = "qs",              # Use qs instead of rds for fast serialization
  resources = tar_resources(
    qs = tar_resources_qs(preset = "fast")
  ),
  # Settings to limit memory usage,
  # See https://books.ropensci.org/targets/performance.html#memory
  memory = "transient",  # Discard targets after loading to clear memory
  garbage_collection = TRUE, # Clean up memory before building next target
  repository_meta = "local" # IMPORTANT in targets versions 1.3.x - use local meta file
)

# Set up a process controller if multiple cores are requested
if (Sys.getenv("NPROC", unset = "1") != "1") {
  tar_option_set(
    controller = crew::crew_controller_local(
      name = "local",
      workers = as.integer(Sys.getenv("NPROC", unset = "1"))
    )
  )
}

# Settings for SLRUM on Sycorax

if(as.logical(Sys.getenv("USE_SLURM", unset = FALSE))){
  
  Sys.setenv("PATH"=paste0(Sys.getenv("PATH"), ":/usr/local/bin"))
  tar_option_set(
    controller = crew.cluster::crew_controller_slurm(
      workers = 2, # Reflecting Prospero and Sycorax
      host = Sys.info()["nodename"],
      slurm_cpus_per_task = 50, # 100 threads,
      slurm_time_minutes = 10080,
      slurm_partition = "gpu", # Use the 'all' partition for widest compatibility
      slurm_log_output = "slurm_log.txt",
      slurm_log_error = "slurm_error.txt",
      verbose = TRUE,
      script_lines = c(
        "#SBATCH --account=eco",
        "#SBATCH --ntasks=2", # Align with the number of workers/nodes
        "#SBATCH --nodes=2" # Explicitly request  2 nodes
      )
    )
  )  
}


# Use shared S3 cache for targets if available.
# See .Rprofile for switching cache targetsstore based on this
# Also controls the location of updated parqet data sets
if(nzchar(Sys.getenv("AWS_BUCKET_ID")) && !Sys.getenv("TAR_PROJECT") %in% c("sandbox", "main")) {
  tar_option_set(
    repository = "aws",
    format = "qs",
    resources = tar_resources(
      aws = tar_resources_aws(
        prefix = "_targets",
        bucket = Sys.getenv("AWS_BUCKET_ID"),
        region = Sys.getenv("AWS_REGION")
      ),
      qs = tar_resources_qs(preset = "fast")
    ),
    storage = "worker",
    retrieval = "worker"
  )
}
