repel_split_data <- function(augmented_data) {
  augmented_data |>
    dplyr::group_by(country_iso3c, disease) |>
    dplyr::mutate(
      validation_set = dplyr::row_number() %in% 
        sample(n(), ceiling(0.2 * n()), replace = FALSE)
    )  |>
    dplyr::ungroup()
}

repel_split_nowcast <- function(augmented_data) {
  
  augmented_data |>
    dplyr::group_by(country_iso3c, disease) |>
    dplyr::mutate(
      validation_set = dplyr::row_number() %in%
        sample(n(), ceiling(0.2 * n()), replace = FALSE)
    )  |>
    dplyr::ungroup()
}


repel_validation <- function(repel_data_split) {
  repel_data_split |>
    dplyr::filter(validation_set) |>
    dplyr::select(-validation_set)
}

repel_training <- function(repel_data_split) {
  repel_data_split |>
    dplyr::filter(!validation_set) |>
    dplyr::select(-validation_set)
}

repel_filter_outbreak_starts <- function(repel_training_data) {
  repel_training_data |>
    tidyr::drop_na() |>
    dplyr::filter(!endemic) |>
    dplyr::filter(!outbreak_ongoing)
}

repel_filter_outbreak_starts_crop <- function(repel_training_data) {
  repel_training_data |>
    tidyr::drop_na() |>
    dplyr::filter(!outbreak_ongoing)
}
