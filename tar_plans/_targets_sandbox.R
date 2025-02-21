################################################################################
#
# Build script for out-of-main-pipeline projects
#
################################################################################ 

# Re-record current dependencies for CAPSULE users
if(Sys.getenv("USE_CAPSULE") %in% c("1", "TRUE", "true"))
  capsule::capshot(c("packages.R",
                     list.files(pattern = "_targets.*\\.(r|R)$", full.names = TRUE),
                     list.files("R", pattern = "\\.(R|r)$", full.names = TRUE)))

# Load packages (in packages.R) and load project-specific functions in R folder
suppressPackageStartupMessages(source("packages.R"))
for (f in list.files(here::here("R"), full.names = TRUE)) source (f)

# Set build options ------------------------------------------------------------
source("_targets_settings.R")


# List targets (see R/utils.R)
all_targets()

