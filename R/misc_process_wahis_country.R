#'
#' Process country variable in WAHIS datasets
#' 
#' @param country A character vector of country values from a WAHIS dataset
#' @param fix Logical. Should fixes be applied to countries with known issues
#'   with conversion to iso3c coding. Default is TRUE in which known issues or
#'   specific country cases are dealt with to arrive at a iso3c code. If a
#'   specific issue or case is not recognised, then NA will be returned for
#'   the iso3c code of that country. If fix = FALSE, then attempts at
#'   fixing issues or specific country cases are not performed.
#' @param warn Logical. Should a warning be printed/shown if a country name
#'   has not been matched to an appropriate iso3c code? Default is FALSE.
#'   Setting to TRUE may be useful for debugging and for adding new algorithm
#'   to handle specific country cases.
#'   
#' @return A data.frame with number of rows equal to length of country and
#'   a column for country name and country iso3c code.
#' 
#' @examples
#' process_wahis_country("colombia")
#' 
#'   
#' @export
#' 

process_wahis_country <- function(country, fix = TRUE, warn = FALSE) {
  
  ## Get iso3c ----
  country_iso3c <- countrycode::countrycode(
    sourcevar = country, origin = "country.name", destination = "iso3c",
    warn = warn                            
  )

  ## Apply processing algorithm for known country cases/issues ----
  if (fix) {
    ### Mutates for country to quiet down some warnings for country matching ----
    ### for iso3 code. This fixes all but 1 (Ceuta and Melilla)
    country <- dplyr::case_when(
      country == "central african (rep.)" ~ "central african republic",
      country == "dominican (rep.)" ~ "dominican republic",
      country == "guadaloupe" ~ "guadeloupe",
      .default = country
    )
    
    ### Get iso3c ----
    country_iso3c <- countrycode::countrycode(
      sourcevar = country, origin = "country.name", destination = "iso3c",
      warn = warn                            
    ) 
    
    ### Manual fixes 
    country_iso3c[which(country == "ceuta")] <- "CEU"
    country_iso3c[which(country == "melilla")] <- "MEL"
    country_iso3c[which(country =="serbia and montenegro")] <- "SCG"
    
    if(any(is.na(country_iso3c))) warning("NAs found in country codes will be dropped")
  }

  ## Return results ----
  country_iso3c
}


