# This is the script to deposit all objects and raw data onto github

# Create version on Github
# Run once
# piggyback::pb_release_create(repo = "ecohealthalliance/repel2",
#                              tag = "targets-objects-backup",
#                              name = "Backup of targets objects for full pipeline",
#                              body = "All targets objects associated with git commit #fd78783. This differs from the data cache release (https://github.com/ecohealthalliance/repel2/tree/data-cache), which includes only model and supporting objects that are used within the pipeline workflow.")

# Env variable for tmp directory to save relic objects
dir.create("tmp")
Sys.setenv(RELIC_CACHE_DIR="~/repel2/tmp/")

# Git commit 
gh_commit <- "fd78783"

# All objects to cache
targets::tar_prune(cloud = FALSE)
aws_objs <- targets::tar_meta() |> 
  dplyr::filter(type != "function", repository == "aws") |> 
  dplyr::pull(name)

# For each object, download from AWS using relic into tmp directory, transfer to GitHub
purrr::walk(aws_objs, function(obj){
  
  relic::tar_read_raw_version(name = obj, ref = gh_commit)
  
  f_list <- list.files("tmp", recursive = TRUE)
  f_name <- paste0("tmp/", f_list[stringr::str_detect(f_list, "_targets/objects")])
  piggyback::pb_upload(f_name, repo = "ecohealthalliance/repel2", tag = "targets-objects-backup")
  
  unlink("tmp", recursive = TRUE)
  
})

# Now get all the raw data uploaded

# Create version on Github
# Run once
# piggyback::pb_release_create(repo = "ecohealthalliance/repel2",
#                              tag = "raw-data-backup",
#                              name = "Backup of data-raw directory",
#                              body = "All raw data. This differs from the data cache release (https://github.com/ecohealthalliance/repel2/tree/data-cache), which includes only model and supporting objects that are used within the pipeline workflow.")


raw_data_dirs <- rev(list.files("data-raw", recursive = FALSE, full.names = FALSE)[-1])
raw_data_zips <- paste0(raw_data_dirs, ".zip")

wd <- here::here()

purrr::walk2(raw_data_dirs, raw_data_zips, function(dir, zipp){
  setwd("data-raw")
  zip(zipfile = dir, files = list.files(dir, full.names = TRUE))
  setwd(wd)
  piggyback::pb_upload(paste0("data-raw/", zipp), repo = "ecohealthalliance/repel2", tag = "raw-data-backup")
  unlink(paste0("data-raw/", zipp))
})

# Separately handle the crop comtrade
wd <- here::here()
setwd("data-raw")
crop_comtrade_objs <- list.files("comtrade-crop",  full.names = TRUE)
crop_comtrade_objs <- crop_comtrade_objs[stringr::str_starts(basename(crop_comtrade_objs), "1993_2004|2005_2010|2011_2016|2017_2022")]
zip(zipfile = "comtrade-crop", files = crop_comtrade_objs)
piggyback::pb_upload("comtrade-crop.zip", repo = "ecohealthalliance/repel2", tag = "raw-data-backup")
unlink("comtrade-crop.zip")
setwd(wd)
