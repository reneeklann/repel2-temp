source(here::here("_targets.R"))
purrr::walk(data_downloads_targets_livestock, targets::tar_invalidate)
purrr::walk(data_downloads_targets_both, targets::tar_invalidate)
message("invalidated livestock pipeline")
