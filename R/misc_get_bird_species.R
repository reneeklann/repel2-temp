#' Get List of Bird Species from Catalogue of Life
#'
#' This function retrieves a list of bird species from the Catalogue of Life 
#' using the `taxadb` package.
#'
#' @return A character vector containing the list of bird species from the
#'   Catalogue of Life
#'
#' @import taxadb dplyr
#' @importFrom dplyr pull
#' @importFrom dplyr suppressMessages
#' @importFrom taxadb td_create
#' @importFrom taxadb filter_rank
#'
#' @examples
#' # Get the list of bird species
#' bird_species <- misc_get_bird_species()
#' # Print the list
#' print(bird_species)
#'
#' @export

misc_get_bird_species <- function() {
  suppressMessages(taxadb::td_create(provider = "col"))
  aves <- suppressMessages(
    taxadb::filter_rank(name = "Aves", rank = "class")
  ) |>
    dplyr::pull(scientificName)
  
  aves
}

