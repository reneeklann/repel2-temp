#'
#' Process lag periods for WAHIS datasets
#' 
#' @param wahis_data A WAHIS dataset with fields for year and semester_code
#' 
#' @return A tibble with number of rows the same as the length of year and 
#'   semester and columns for *year*, *semester_code*, *leg_semester_code*,
#'   *lag_year*, *lag_year_and_half*, *lag_six_code*, *lag_twelve_code*, 
#'   *lag_eighteen_code*
#'   
#' @examples 
#' process_wahis_status_lags(wahis_status)
#'
#' @export
#'
process_wahis_status_lags <- function(wahis_status, 
                                      lag = c("lag_six_code", 
                                              "lag_twelve_code", 
                                              "lag_eighteen_code")) {
  ## Get lag ----
  lag <- match.arg(lag)
  
  wahis_status <- wahis_status |>
    dplyr::mutate(semester_year = paste(semester_code, year, "-"))
  
  ## Get lag periods data.frame ----
  lag_periods <- wahis_status |>
    dplyr::mutate(
      ### Keep lag_semester_code, lag_year, and lag_year_and_half for now ----
      ### for testing/checking purposes and then to remove after code review
      lag_semester_code = ifelse(semester_code == 1, 2, 1),
      lag_year = ifelse(semester_code == 1, year - 1, year),
      lag_year_and_half = year - semester_code,
      lag_six_code = paste(lag_semester_code, lag_year, sep = "-"),
      lag_twelve_code = paste(semester_code, year - 1, sep = "-"),
      lag_eighteen_code = paste(lag_semester_code, lag_year_and_half, sep = "-")
    ) |>
    dplyr::select(
      country_iso3c, continent, year, semester, semester_code, disease, 
      disease_population, taxa, lag_six_code:lag_eighteen_code
    )
  
  Map(
    f = wahis_find_disease_status,
    wahis_status = list(wahis_status),
    country_iso3c = as.list(lag_periods$country_iso3c),
    continent = as.list(lag_periods$continent),
    disease = as.list(lag_periods$disease),
    disease_population = as.list(lag_periods$disease_population),
    lag_period = as.list(lag_periods[[lag]]),
    taxa = as.list(lag_periods$taxa)
  ) |>
    unlist()
}




wahis_find_disease_status <- function(wahis_status, 
                                      country_iso3c, continent, 
                                      disease, disease_population, taxa,
                                      lag_period) {
  values <- c(
    country_iso3c, continent, disease, disease_population, taxa, lag_period
  )
  
  ## Get status information for given details ----
  disease_status <- wahis_status |>
    dtplyr::lazy_dt() |>
    dplyr::filter(
      country_iso3c == values[[1]],
      continent == values[[2]],
      disease == values[[3]],
      disease_population == values[[4]],
      taxa == values[[5]],
      semester_year == values[[6]]
    ) |>
    dplyr::pull(disease_status)
  
  ## Get status based on output ----
  if (length(disease_status) == 0) {
    disease_status <- NA_character_
  } else {
    disease_status <- unique(wahis_status_sub$disease_status)
  }
  
  ## Return disease_status ----
  disease_status
}



wahis_get_cases <- function(wahis_status, 
                            country_iso3c, continent, 
                            disease, disease_population, taxa,
                            lag_period) {
  values <- c(
    country_iso3c, continent, disease, disease_population, taxa, lag_period
  )
  
  ## Get cases information for given details ----
  cases <- wahis_status |>
    dtplyr::lazy_dt() |>
    dplyr::filter(
      country_iso3c == values[[1]],
      continent == values[[2]],
      disease == values[[3]],
      disease_population == values[[4]],
      taxa == values[[5]],
      semester_year == values[[6]]
    ) |>
    dplyr::pull(cases)
  
  ## Get status based on output ----
  if (length(cases) == 0) {
    cases <- NA_integer_
  } else {
    cases <- unique(cases$cases)
  }
  
  ## Return disease_status ----
  cases
}