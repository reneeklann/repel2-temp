#' Process Crop Outbreak Data from NAPPO
#'
#' This function retrieves a structured table of crop disease outbreaks from NAPPO
#'
#' @return processed outbreak table from NAPPO data source
#'
#' @import dplyr
#' @import lubridate
#' @importFrom countrycode countrycode
#'
#' @examples
#'
#' @export
process_nappo_table <- function(nappo_table_downloaded, nappo_free_text_scraped, 
                                priority_crop_disease_lookup) {
  
  nappo_reports <- arrow::read_parquet(nappo_table_downloaded)
  nappo_free_text_scraped <- arrow::read_parquet(nappo_free_text_scraped)
  
  # Rename variables
  nappo_reports <- nappo_reports |>
    dplyr::rename(
      country = Country,
      title = Title,
      date_published = `Posted Date`
    )
  
  # Convert date_published into date and add variable year_published
  nappo_reports <- nappo_reports |>
    dplyr::mutate(date_published = lubridate::parse_date_time(date_published, orders = c('mdyHM', 'mdyH'))) |>
    dplyr::mutate(date_published = lubridate::floor_date(date_published, unit = "day")) |>
    dplyr::mutate(year_published = lubridate::year(date_published)) |>
    dplyr::relocate(year_published, .after = title)
  
  # Add country code and continent fields
  country_code <- countrycode::countrycode(
    sourcevar = nappo_reports$country,
    origin = "iso2c",
    destination = "iso3c"
  )
  continent <- countrycode::countrycode(
    sourcevar = nappo_reports$country,
    origin = "iso2c",
    destination = "continent"
  )
  
  nappo_reports <- cbind(nappo_reports, country_code, continent)
  nappo_reports <- nappo_reports |>
    dplyr::relocate(country_code, .after = country) |>
    dplyr::relocate(continent, .after = country_code)
  
  # Add source column
  nappo_reports <- nappo_reports |>
    dplyr::mutate(source = "NAPPO")
  
  # Fix pest names
  LIBEAS <- c("Candidatus Liberibacter asiaticus", "Candidatus&nbsp;Liberibacter asiaticus", 
              "Citrus Greening", "citrus greening")
  LIBEAS <- stringr::str_c(stringr::str_flatten(LIBEAS, "|"))
  LIBEAS <- stringr::str_detect(nappo_free_text_scraped$report_title, LIBEAS)
  nappo_free_text_scraped <- nappo_free_text_scraped |> 
    dplyr::mutate(pest = ifelse(LIBEAS == TRUE, "Candidatus Liberibacter asiaticus", pest))
  
  PHYPSO <- "Bois noir phytoplasma"
  PHYPSO <- stringr::str_detect(nappo_free_text_scraped$report_title, PHYPSO)
  nappo_free_text_scraped <- nappo_free_text_scraped |> 
    dplyr::mutate(pest = ifelse(PHYPSO == TRUE, "Candidatus Phytoplasma solani", pest))
  
  HETDRO <- c("Globodera rostochiensis", "Golden Nematode")
  HETDRO <- stringr::str_c(stringr::str_flatten(HETDRO, "|"))
  HETDRO <- stringr::str_detect(nappo_free_text_scraped$report_title, HETDRO)
  nappo_free_text_scraped <- nappo_free_text_scraped |> 
    dplyr::mutate(pest = ifelse(HETDRO == TRUE, "Globodera rostochiensis", pest))
  
  PPV000 <- c("Plum Pox Virus", "Plum pox virus")
  PPV000 <- stringr::str_c(stringr::str_flatten(PPV000, "|"))
  PPV000 <- stringr::str_detect(nappo_free_text_scraped$report_title, PPV000)
  nappo_free_text_scraped <- nappo_free_text_scraped |> 
    dplyr::mutate(pest = ifelse(PPV000 == TRUE, "Plum pox virus", pest))
  
  PSDMS3 <- c("Ralstonia solanacearum race 3 biovar 2", "Ralstonia solanacearum Race 3 Biovar 2", 
              "Ralstonia solanacearum, Race 3 Biovar 2", "Ralstonia solanacearum, Race 3 \\(Biovar2\\)")
  PSDMS3 <- stringr::str_c(stringr::str_flatten(PSDMS3, "|"))
  PSDMS3 <- stringr::str_detect(nappo_free_text_scraped$report_title, PSDMS3)
  nappo_free_text_scraped <- nappo_free_text_scraped |> 
    dplyr::mutate(pest = ifelse(PSDMS3 == TRUE, "Ralstonia solanacearum race 3 biovar 2", pest))
  
  SYNCEN <- c("Synchytrium endobioticum", "Potato Wart")
  SYNCEN <- stringr::str_c(stringr::str_flatten(SYNCEN, "|"))
  SYNCEN <- stringr::str_detect(nappo_free_text_scraped$report_title, SYNCEN)
  nappo_free_text_scraped <- nappo_free_text_scraped |>
    dplyr::mutate(pest = ifelse(SYNCEN == TRUE, "Synchytrium endobioticum", pest))
  
  AGRLPL <- c("Emerald Ash Borer", "Emerald ash borer", "emerald ash borer")
  AGRLPL <- stringr::str_c(stringr::str_flatten(AGRLPL, "|"))
  AGRLPL <- stringr::str_detect(nappo_free_text_scraped$report_title, AGRLPL)
  nappo_free_text_scraped <- nappo_free_text_scraped |> 
    dplyr::mutate(pest = ifelse(AGRLPL == TRUE, "Agrilus planipennis", pest))
  
  ANOLGL <- c("Anoplophora glabripennis", "Asian Long-horned Beetle", "Asian Longhorned Beetle")
  ANOLGL <- stringr::str_c(stringr::str_flatten(ANOLGL, "|"))
  ANOLGL <- stringr::str_detect(nappo_free_text_scraped$report_title, ANOLGL)
  nappo_free_text_scraped <- nappo_free_text_scraped |> 
    dplyr::mutate(pest = ifelse(ANOLGL == TRUE, "Anoplophora glabripennis", pest))
  
  CONTNA <- c("Contarinia nasturtii", "Swede Midge")
  CONTNA <- stringr::str_c(stringr::str_flatten(CONTNA, "|"))
  CONTNA <- stringr::str_detect(nappo_free_text_scraped$report_title, CONTNA)
  nappo_free_text_scraped <- nappo_free_text_scraped |> 
    dplyr::mutate(pest = ifelse(CONTNA == TRUE, "Contarinia nasturtii", pest))
  
  ACHAFU <- "Lissachatina fulica"
  ACHAFU <- stringr::str_detect(nappo_free_text_scraped$report_title, ACHAFU)
  nappo_free_text_scraped <- nappo_free_text_scraped |>
    dplyr::mutate(pest = ifelse(ACHAFU == TRUE, "Lissachatina fulica", pest))
  
  PUCCHN <- c("Puccinia horiana", "Chrysanthemum White Rust")
  PUCCHN <- stringr::str_c(stringr::str_flatten(PUCCHN, "|"))
  PUCCHN <- stringr::str_detect(nappo_free_text_scraped$report_title, PUCCHN)
  nappo_free_text_scraped <- nappo_free_text_scraped |> 
    dplyr::mutate(pest = ifelse(PUCCHN == TRUE, "Puccinia horiana", pest)) 
  
  BLASPI <- c("Tomicus piniperda", "Pine Shoot Beetle")
  BLASPI <- stringr::str_c(stringr::str_flatten(BLASPI, "|"))
  BLASPI <- stringr::str_detect(nappo_free_text_scraped$report_title, BLASPI)
  nappo_free_text_scraped <- nappo_free_text_scraped |> 
    dplyr::mutate(pest = ifelse(BLASPI == TRUE, "Tomicus piniperda", pest))
  
  # Join to free text by report url
  nappo_reports <- nappo_reports |>
    dplyr::full_join(nappo_free_text_scraped, by = dplyr::join_by(url == url)) |>
    dplyr::select(-report_title)
  
  nappo_reports <- nappo_reports |>
    dplyr::mutate(pest = ifelse(is.na(pest), "", pest))
  
  # Read priority crop disease lookup table and join to NAPPO reports table
  priority_crop_disease_lookup <- readxl::read_xlsx(priority_crop_disease_lookup)
  nappo_reports <- nappo_reports |> 
    dplyr::left_join(priority_crop_disease_lookup, 
                     by = dplyr::join_by(pest == nappo_name), 
                     relationship = "many-to-one")
  
  return(nappo_reports)
}
