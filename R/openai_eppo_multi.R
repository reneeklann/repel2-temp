#' Get sample of EPPO reports
#'
#' This function
#'
#' @return raw data file
#' 
#' @import rvest dplyr
#' 
#' @examples
#' # Download the table
#' download_nappo_table(directory = "data-raw")
#' 
#' @export
get_eppo_multi_reports_sample <- function(crop_data_manual, crop_report_index) {
  
  crop_data_manual <- read.csv(crop_data_manual)
  
  eppo_multi_reports <- crop_report_index |>
    dplyr::filter(source == "EPPO") |>
    dplyr::filter(year_published >= 1993) |>
    dplyr::filter(multiple_reports == TRUE) |>
    dplyr::filter(url %in% crop_data_manual$url) |>
    dplyr::mutate(specific_context = paste("disease:", pest, "^", 
                                           "country:", country, "#", 
                                           "keywords:", keyword1, keyword2, "@", 
                                           title, text)) |>
    dplyr::mutate(specific_context = stringr::str_remove(string = specific_context, 
                                                         pattern = "EPPO\\sReporting\\sService\\sno\\.\\s\\d{2}\\s-\\s\\d{4}\\sNum\\.\\sarticle\\:\\s\\d{4}/\\d{2,3}"))
  eppo_multi_reports
}


#' Get EPPO reports
#'
#' This function
#'
#' @return raw data file
#' 
#' @import dplyr
#' 
#' @examples
#' # Download the table
#' download_nappo_table(directory = "data-raw")
#' 
#' @export
get_eppo_multi_reports <- function(crop_data_manual, crop_report_index) {
  
  crop_data_manual <- read.csv(crop_data_manual)
  
  eppo_multi_reports <- crop_report_index |>
    dplyr::filter(source == "EPPO") |>
    dplyr::filter(year_published >= 1993) |>
    dplyr::filter(multiple_reports == TRUE) |>
    dplyr::filter(!url %in% crop_data_manual$url) |>
    dplyr::mutate(specific_context = paste("disease:", pest, "^", 
                                           "country:", country, "#", 
                                           "keywords:", keyword1, keyword2, "@", 
                                           title, text)) |>
    dplyr::mutate(specific_context = stringr::str_remove(string = specific_context, 
                                                         pattern = "EPPO\\sReporting\\sService\\sno\\.\\s\\d{2}\\s-\\s\\d{4}\\sNum\\.\\sarticle\\:\\s\\d{4}/\\d{2,3}"))
  
  eppo_multi_reports
}
    

#' Preprocess EPPO multi reports for OpenAI data extraction
#'
#' This function...
#'
#' @return raw data file
#' 
#' @import dplyr
#' 
#' @examples
#' 
#' @export
preprocess_eppo_multi_reports <- function(eppo_multi_reports) {
  
  eppo_multi_reports_specific_context <- eppo_multi_reports$specific_context
  
  subset_paragraphs <- purrr::map_chr(eppo_multi_reports_specific_context, function(eppo_report){
    
    # eppo_report <- eppo_multi_reports_sample[1]
    
    # get country and country codes
    country <- eppo_report |>
      stringr::str_extract(pattern = "country\\:\\s.*\\#") |>
      stringr::str_remove(pattern = "country\\:\\s") |>
      stringr::str_remove(pattern = "\\s\\#")
    
    country_name <- countrycode::countrycode(
      sourcevar = country,
      origin = "country.name",
      destination = "country.name"
    )
    country_name <- if(is.na(country_name)){country} else{country_name}
    
    country_iso2c <- countrycode::countrycode(
      sourcevar = country,
      origin = "country.name",
      destination = "iso2c"
    )
    country_iso2c <- if(is.na(country_iso2c)){country} else{country_iso2c}
    
    country_iso3c <- countrycode::countrycode(
      sourcevar = country,
      origin = "country.name",
      destination = "iso3c"
    )
    country_iso3c <- if(is.na(country_iso3c)){country} else{country_iso3c}
    
    country_french <- countrycode::countrycode(
      sourcevar = country,
      origin = "country.name",
      destination = "country.name.fr"
    )
    country_french <- if(is.na(country_french)){country} else{country_french}
    
    country_german <- countrycode::countrycode(
      sourcevar = country,
      origin = "country.name",
      destination = "country.name.de"
    )
    country_german <- if(is.na(country_german)){country} else{country_german}
    
    country_italian <- countrycode::countrycode(
      sourcevar = country,
      origin = "country.name",
      destination = "country.name.it"
    )
    country_italian <- if(is.na(country_italian)){country} else{country_italian}
    
    # unfortunately no way to get short Spanish name, only UN Spanish name
    
    country_all <- c(country, country_name, country_iso2c, country_iso3c, country_french, country_german, country_italian)
    country_all <- stringr::str_c(stringr::str_flatten(country_all, "|"))
    
    # get disease name
    disease_full <- eppo_report |>
      stringr::str_extract(pattern = "disease\\:\\s.*\\^") |>
      stringr::str_remove(pattern = "disease\\:\\s") |>
      stringr::str_remove(pattern = "\\s\\^")
    
    # if we only subset paragraphs with the full disease name, we'll miss some relevant paragraphs
    # there's no clean way to get just the specific epithet from the EPPO database
    
    # split disease name on white space, and if it's a vector of 2+ return the second word
    disease_split <- stringr::str_split(disease_full, " ") |> unlist()
    get_disease_abbrev <- function(disease_split){
      if(length(disease_split) >= 2) {disease_abbrev <- disease_split[2]}
      if(length(disease_split) == 1) {disease_abbrev <- disease_split}
      disease_abbrev
      }
    disease_abbrev <- get_disease_abbrev(disease_split)

    # split report by paragraph
    report_split <- stringr::str_split(eppo_report, "\n") |> unlist()

    # subset paragraphs that contain disease / country
    par_country <- stringr::str_subset(report_split, country_all)
    par_disease_full <- stringr::str_subset(report_split, disease_full)
    par_disease_abbrev <- stringr::str_subset(report_split, disease_abbrev)
    # fuzzy matching for disease name
    par_disease_fuzzy <- agrep(pattern = disease_full, report_split, max.distance = 0.3, ignore.case = TRUE, value = TRUE)
    
    # test reports of diseases that require fuzzy matching
    # https://gd.eppo.int/reporting/article-102 Potato purple-top wilt agent in USA -- works as low as 0.26
    # https://gd.eppo.int/reporting/article-6966 common oak ringspot-associated virus in Germany, Norway, Sweden -- works as low as 0.12
    # https://gd.eppo.int/reporting/article-4700 Cucurbit aphid-borne yellows virus -- exact match ignoring case
    # https://gd.eppo.int/reporting/article-4050 Grapevine leafroll-associated virus 1 -- works as low as 0.17
    # https://gd.eppo.int/reporting/article-2076 Citrus sudden death agent -- works as low as 0.17
    # https://gd.eppo.int/reporting/article-1090 Date palm brittle leaf agent -- works as low as 0.4
    
    # get any paragraphs with the country and disease name
    # if the disease name and country are not both present in any paragraphs, return paragraphs with only the disease name
    # if the disease name is not present in any paragraphs, return paragraphs with only the country
    # if neither the disease name nor the country is present in any paragraphs, return the whole report
    get_relevant_paragraphs <- function(par_country, par_disease_full, par_disease_abbrev, par_disease_fuzzy, eppo_report){
      par_disease <- c(par_disease_full, par_disease_abbrev, par_disease_fuzzy) |> unique()
      par_disease_country <- intersect(par_disease, par_country)
      if(length(par_disease_country) == 1){par_disease_country <- par_disease}
      if(length(par_disease_country) == 1){par_disease_country <- par_country}
      if(length(par_disease_country) == 1){par_disease_country <- eppo_report}
      par_disease_country
    }
    eppo_report <- get_relevant_paragraphs(par_country, par_disease_full, par_disease_abbrev, par_disease_fuzzy, eppo_report)

    eppo_report <- stringr::str_flatten(eppo_report)
    
    # remove citations of previous EPPO reports
    eppo_report <- eppo_report |>
      stringr::str_remove_all("EPPO\\sRS\\s(19|20)\\d{2}/\\d{3}") |>
      stringr::str_remove_all("(19|20)\\d{2}/\\d{3}")
    
    return(eppo_report)
    })
  
  eppo_multi_reports <- eppo_multi_reports |>
    dplyr::mutate(specific_context = subset_paragraphs)
  
  eppo_multi_reports
}


#' Construct a tibble of parameters that openAI will return and specify constraints such as type and enumeration
#'
#' @return A tibble outlining the parameters that openAI should use in its reply. Will be further processed by format_function_call_df
#' @export
#'
#' @examples
#' function_call_params <- get_function_call_params()
get_function_call_params_eppo_multi <- function(eppo_report) {

  disease <- eppo_report |>
    stringr::str_extract(pattern = "disease\\:\\s.*\\^") |>
    stringr::str_remove(pattern = "disease\\:\\s") |>
    stringr::str_remove(pattern = "\\s\\^")

  country <- eppo_report |>
    stringr::str_extract(pattern = "country\\:\\s.*\\#") |>
    stringr::str_remove(pattern = "country\\:\\s") |>
    stringr::str_remove(pattern = "\\s\\#")
  
  keywords <- eppo_report |>
    stringr::str_extract(pattern = "keywords\\:\\s.*\\@") |>
    stringr::str_remove(pattern = "keywords\\:\\s") |>
    stringr::str_remove(pattern = "\\s\\@")
  
  disease_hint <- function(disease){
    if(stringr::str_detect(disease, "Ralstonia solanacearum") == TRUE)return("Extract the race and biovar of Ralstonia solanacearum.")
    if(stringr::str_detect(disease, "Xylella fastidiosa") == TRUE)return("Extract the subspecies of Xylella fastidiosa.")
  }
  
  year_month_hint <- function(keywords){
    if(stringr::str_detect(keywords, "Detailed record") == TRUE)return(" was most recently detected in ")
    if(stringr::str_detect(keywords, "New record") == TRUE)return(" was first detected in ")
    if(stringr::str_detect(keywords, "New pest") == TRUE)return(" was first detected in ")
    if(stringr::str_detect(keywords, "Absence") == TRUE)return(" was declared absent from ")
    if(stringr::str_detect(keywords, "Denied record") == TRUE)return(" was declared absent from ")
    if(stringr::str_detect(keywords, "Eradication") == TRUE)return(" was eradicated from ")
  }
  
  year_hint <- function(keywords){
    if(stringr::str_detect(keywords, "New record") == TRUE)return("If multiple years are mentioned, extract the earliest year.")
    if(stringr::str_detect(keywords, "Detailed record") == TRUE)return("If multiple years are mentioned, extract the most recent year.")
  }
    
  presence_hint <- function(keywords){
    if(stringr::str_detect(keywords, "Detailed record") == TRUE)return("The answer is likely 'present'.")
    if(stringr::str_detect(keywords, "New record") == TRUE)return("The answer is likely 'present'.")
    if(stringr::str_detect(keywords, "New pest") == TRUE)return("The answer is likely 'present'.")
    if(stringr::str_detect(keywords, "Absence") == TRUE)return("The answer is likely 'absent'.")
    if(stringr::str_detect(keywords, "Denied record") == TRUE)return("The answer is likely 'absent'.")
  }
  # "Eradication" doesn't necessarily mean the disease is absent from the country
  
  # event_type_hint <- function(keywords){
  #   if(stringr::str_detect(keywords, "New record") == TRUE)return("Based on the keywords, the answer is likely 'new outbreak'.")
  #   if(stringr::str_detect(keywords, "New pest") == TRUE)return("Based on the keywords, the answer is likely 'new outbreak'.")
  #   if(stringr::str_detect(keywords, "Detailed record") == TRUE)return("Based on the keywords, the answer is likely 'ongoing outbreak'.")
  #   if(stringr::str_detect(keywords, "Eradication") == TRUE)return("Based on the keywords, the answer is likely 'eradication'.")
  #   if(stringr::str_detect(keywords, "Absence NA") == TRUE)return("Based on the keywords, the answer is likely 'absence'.")
  #   if(stringr::str_detect(keywords, "Denied record") == TRUE)return("Based on the keywords, the answer is likely 'absence'.")
  # }

  # Modify any of these items with paste() or glue() to give its description context.
  function_call_df <- tibble::tribble(~parameter_name, ~description, ~type, ~enum,
                                      "disease", paste("The species name of the disease or pest, including subspecies, race, biovar, and/or pathotype.", disease_hint(disease)), "string", NA,
                                      "year", paste0("The year ", disease, year_month_hint(keywords), country, ". If only one year is mentioned, extract that year. ", year_hint(keywords), " The year may be within parentheses."), c("string", "null"), NA,
                                      "month", paste0("The month ", disease, year_month_hint(keywords), country), c("string", "null"), c("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December", "NA"),
                                      "host", paste0("The species name of the plant affected by ", disease, ". If the species name is not mentioned, extract the common name. If neither the species name nor the common name is mentioned, return 'NA'. Do not extract '", disease, "'."), c("string", "null"), NA,
                                      "presence", paste0("Is ", disease, " present or absent from ", country, "? ", presence_hint(keywords)), "string", c("present", "absent", "NA")
                                      # "event_type", paste("The type of event described in the report: new outbreak, ongoing outbreak, eradication, or absence.", event_type_hint(keywords)), c("string", "null"), c("new outbreak", "ongoing outbreak", "eradication", "absence", "NA")
  )

  function_call_df <- function_call_df |>
    dplyr::rowwise() |> dplyr::mutate(parameter = get_function_call_parameter_eppo_multi(parameter_name, description, type, enum))

  function_call_df
}


#' Arrange parameter details in JSON schema format
#'
#' @param parameter_name The name of the parameter openAI should return
#' @param description A description of the parameter. OpenAI will use this description to construct it's response
#' @param type What type or types are allowed in OpenAI's response. i.e. c("string", "null") constrains openAI to returning a character string or NULL.
#' @param enum A list of the return values that OpenAI should adhere to when choosing a response.
#'
#' @return A formatted and named parameter list
#' @export
#'
#' @examples
#' function_call_parameter <- get_function_call_parameter("disease", "The outbreak event disease name")
get_function_call_parameter_eppo_multi <- function(parameter_name,
                                                   description,
                                                   type = c("string", "null"),
                                                   enum = NULL) {

  parameter <- purrr::compact(list("description" = description,
                                   "type" = type,
                                   "enum" = enum))

  list(parameter[!is.na(parameter)]) |> setNames(parameter_name)
}


#'  Context aware openai function call
#'
#' @param country Passed to get_function_call_params if parameter descriptions need to include context
#' @param disease Passed to get_function_call_params if parameter descriptions need to include context
#' @param function_name The name of the imaginary function openAI will be formatting it's response for. Should be descriptive of the desired task it will perform.
#' @param function_description # A description of the what the function would accomplish
#'
#' @return Returns a list containing a formatted function call as an R list, as a compact JSON, a pretty JSON, and a tibble of the parameters used in constructing the call.
#' @export
#'
#' @examples
#' function_call <- get_openai_function_call()
get_openai_function_call_eppo_multi <- function(eppo_report,
                                                function_name = "extract_outbreak_data",
                                                function_description = "Extract information about a plant disease or pest outbreak from a provided report"
                                                ) {

  function_call_df <- get_function_call_params_eppo_multi(eppo_report)

  function_call <- list(
    list("name" = function_name,
         "description" = function_description,
         "parameters" =
           list(
             "type" = "object",
             "properties" = function_call_df$parameter)))

  list(function_call = function_call,
       JSON_compact = jsonlite::toJSON(function_call),
       JSON_pretty = jsonlite::toJSON(function_call, pretty = T),
       parameters = function_call_df)
}


#' Initiate a conversation with openAI using the provided model and system, common, and specific context.
#' Note: to use these functions you need to provide an openai key in the .env file as in: OPENAI_API_KEY=
#'
#' @param specific_context This is the text specific to each query you would like OpenAI to consider
#' @param common_context This is the text OpenAI should consider in every query
#' @param hint An optional hint to get OpenAI on the right track.
#' @param model The identity of the model you would like to submit the context to.
#' @param system_context Text explaining to the model what role you would like it to play. In example, "Respond as if you an 18th century naturalist."
#'
#' @return A tibble containing the responses from openAI for each query
#' @export
#'
#' @examples
#' specific_context <- "Chronic wasting disease (CWD) is a fatal, prion disease of cervids that was first detected in Alberta in 2005"
#' common_context <- "Please use the extract_outbreak_data function to extract outbreak details from the given abstract and return only the results"
#' chat_results <- openai_chat(specific_context, common_context)
extract_data_eppo_multi <- function(eppo_multi_reports, 
                                    model = "gpt-4-1106-preview", 
                                    # model = "gpt-4-1106-preview", 
                                    system_context = "You act as a function to extract information about a plant disease or pest outbreak from a provided report", 
                                    common_context = "Use the extract_outbreak_data function to extract information from the provided report", 
                                    pipeline = c("full", "assessment"), 
                                    directory = extracted_crop_data_directory, 
                                    overwrite = FALSE
                                    ){
  
  overwrite <- as.logical(overwrite)
  pipeline <- match.arg(pipeline)
  
  if(pipeline == "full"){
    file_name <- paste0("eppo_multi_", janitor::make_clean_names(unique(eppo_multi_reports$preferred_name)), ".gz.parquet")
  }
  if(pipeline == "assessment"){
    file_name <- paste0("eppo_multi_assessment_", unique(eppo_multi_reports$tar_group), ".gz.parquet")
  }
  
  existing_files <- list.files(file.path(directory))
  
  if(file_name %in% existing_files && !overwrite) {
    message("File already exists, skipping extraction")
    return(file.path(directory, file_name))
  }
  
  urls <- eppo_multi_reports$url
  eppo_unique_ids <- eppo_multi_reports$eppo_unique_id
  eppo_multi_reports <- eppo_multi_reports$specific_context

  openai_chat <- purrr::pmap_dfr(list(eppo_multi_reports, urls, eppo_unique_ids), function(eppo_report, url, eppo_unique_id){

    # eppo_report <- eppo_multi_reports[1]
    
    specific_context <- eppo_report

    messages <-
      list(
        list(
          "role" = "system",
          "content" = system_context
        ),
        list(
          "role" = "user",
          "content" = common_context
        ),
        list(
          "role" = "user",
          "content" = specific_context
        )
      )

    function_call = get_openai_function_call_eppo_multi(eppo_report)

    outbreak_details <- openai::create_chat_completion(
      model = model,
      messages = messages,
      functions = function_call$function_call
    ) |> dplyr::bind_cols()
    
    outbreak_details <- outbreak_details |>
      dplyr::mutate(url = url, eppo_unique_id = eppo_unique_id)

    outbreak_details
  })
  
  message(glue::glue("Saving {file_name}"))
  arrow::write_parquet(openai_chat, file.path(directory, file_name), compression = "gzip", compression_level = 5)
  
  return(file.path(directory, file_name))
}
