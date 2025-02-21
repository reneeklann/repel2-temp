# This script is to save local copies of Phase I REPEL data and models, and then transfer them to a public AWS bucket
# this bucket is then accessed by targets for model and data comparisons

# Kirby database extracts ----
conn <- repeldata::repel_remote_conn()

augment_predict_by_origin <- dplyr::tbl(conn, "network_lme_augment_predict_by_origin") |>
  dplyr::collect()

readr::write_csv(augment_predict_by_origin, here::here("repel1-extracts", "network_lme_augment_predict_by_origin.csv.gz"))

augment_predict <- dplyr::tbl(conn, "network_lme_augment_predict") |>
  dplyr::collect() 

readr::write_csv(augment_predict, here::here("repel1-extracts", "network_lme_augment_predict.csv.gz"))

nowcast_boost_augment_predict <- dplyr::tbl(conn, "nowcast_boost_augment_predict") |> 
  collect()

readr::write_csv(nowcast_boost_augment_predict, here::here("repel1-extracts", "nowcast_boost_augment_predict.csv.gz"))

# Load previous model and scaling values ----
lme_mod_network <- aws.s3::s3readRDS(
  bucket = "repeldb/models", object = "lme_mod_network.rds"
)

readr::write_rds(lme_mod_network, here::here("repel1-extracts", "lme_mod_network.rds"))

network_scaling_values <- aws.s3::s3readRDS(
  bucket = "repeldb/models", object = "network_scaling_values.rds"
)

readr::write_rds(network_scaling_values, here::here("repel1-extracts", "network_scaling_values.rds"))

# Upload to public bucket  ----

containerTemplateUtils::aws_s3_upload(path = here::here("repel1-extracts"), bucket = "repel1-extracts", key = "")

