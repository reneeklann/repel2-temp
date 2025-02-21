#' Get sample of IPPC reports and preprocess for openai extraction
#'
#' This function creates a vector of free text reports from IPPC
#'
#' @return vector of free text reports
#' 
#' @import dplyr stringr
#' 
#' @examples
#' get_ippc_reports()
#' 
#' @export
get_ippc_reports_sample <- function(crop_data_manual, crop_report_index) {
  
  crop_data_manual <- read.csv(crop_data_manual)
  
  ippc_reports <- crop_report_index |>
    dplyr::filter(source == "IPPC") |>
    dplyr::filter(url %in% crop_data_manual$url) |>
    dplyr::mutate(specific_context = paste("country:", country, "^", 
                                           "pest status:", pest_status, "#", 
                                           title, text)) |>
    dplyr::mutate(specific_context = stringr::str_remove_all(string = specific_context, 
                                                             pattern = "Publication\\sDate\\s.*\\sReport\\sNumber"))
  
  ippc_reports
}


#' Get IPPC reports and preprocess for openai extraction
#'
#' This function creates a vector of free text reports from IPPC
#'
#' @return vector of free text reports
#' 
#' @import dplyr stringr
#' 
#' @examples
#' get_ippc_reports()
#' 
#' @export
get_ippc_reports <- function(crop_data_manual, crop_report_index) {
  
  crop_data_manual <- read.csv(crop_data_manual)
  
  ippc_reports <- crop_report_index |>
    dplyr::filter(source == "IPPC") |>
    dplyr::filter(!url %in% crop_data_manual$url) |>
    dplyr::mutate(specific_context = paste("country:", country, "^", 
                                           "pest status:", pest_status, "#", 
                                           title, text)) |>
    dplyr::mutate(specific_context = stringr::str_remove_all(string = specific_context, 
                                                             pattern = "Publication\\sDate\\s.*\\sReport\\sNumber"))
  
  ippc_reports
}


#' Construct a tibble of parameters that openAI will return and specify constraints such as type and enumeration
#'
#' @return A tibble outlining the parameters that openAI should use in its reply. Will be further processed by format_function_call_df
#' @export
#'
#' @examples
#' function_call_params <- get_function_call_params()
get_function_call_params_ippc <- function(ippc_report) {
  
  country <- ippc_report |>
    stringr::str_extract(pattern = "country\\:\\s.*\\s\\^") |>
    stringr::str_remove(pattern = "country\\:\\s") |>
    stringr::str_remove(pattern = "\\s\\^")
  
  pest_status <- ippc_report |>
    stringr::str_extract(pattern = "pest\\sstatus\\:\\s.*\\s\\#") |>
    stringr::str_remove(pattern = "pest\\sstatus\\:\\s") |>
    stringr::str_remove(pattern = "\\s\\#") |>
    stringr::str_extract(pattern = "Present|Absent")
  pest_status[is.na(pest_status)] <- "NA"
  
  year_month_hint <- function(pest_status){
    if(stringr::str_detect(pest_status, "Present") == TRUE)return("was detected.")
    if(stringr::str_detect(pest_status, "Absent") == TRUE)return("was eradicated or declared absent.")
    if(stringr::str_detect(pest_status, "NA") == TRUE)return("was detected, eradicated, or declared absent.")
  }
  
  presence_hint <- function(pest_status){
    if(stringr::str_detect(pest_status, "Present") == TRUE)return("The answer is likely present.")
    if(stringr::str_detect(pest_status, "Absent") == TRUE)return("The answer is likely absent.")
    if(stringr::str_detect(pest_status, "NA") == TRUE)return("")
  }
  
  # Modify any of these items with paste() or glue() to give its description context.
  function_call_df <- tibble::tribble(~parameter_name, ~description, ~type, ~enum,
                                      "disease", "The species name of the disease or pest, including subspecies, race, biovar, and/or pathotype. If the disease is Xylella fastidosa, include the subspecies. If the disease is Ralstonia solanacearum, include the race and biovar.", "string", NA,
                                      "year", paste("The year the disease or pest", year_month_hint(pest_status), "If the year is not mentioned, return 'NA'."), c("string", "null"), NA,
                                      "month", paste("The month the disease or pest", year_month_hint(pest_status), "If the month is not mentioned, return 'NA'."), c("string", "null"), c("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December", "NA"),
                                      "host", "The species name of the plant affected by the pest or disease. If the species name is not mentioned, extract the common name. If neither the species name nor the common name is mentioned, return 'NA'. Do not extract broad terms such as 'ornamental plants' or 'horticultural crops'.", c("string", "null"), NA,
                                      "presence", paste0("Is the disease or pest present or absent from ", country, "? This information often follows the phrases 'Pest Status' and 'ISPM 8'. ", presence_hint(pest_status)), c("string", "null"), c("present", "absent", "NA")
                                      # "event_type", "The type of event described in the report (new outbreak, ongoing outbreak, eradication, or absence)", c("string", "null"), c("new outbreak", "ongoing outbreak", "eradication", "absence", "NA")
  )
  
  function_call_df <- function_call_df |>
    dplyr::rowwise() |> dplyr::mutate(parameter = get_function_call_parameter_ippc(parameter_name, description, type, enum))
  
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
get_function_call_parameter_ippc <- function(parameter_name,
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
get_openai_function_call_ippc <- function(ippc_report,
                                          function_name = "extract_outbreak_data",
                                          function_description = "Extract information about a plant disease or pest outbreak from a provided report"
                                          ) {
  
  function_call_df <- get_function_call_params_ippc(ippc_report)
  
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
extract_data_ippc <- function(ippc_reports, 
                              # model = "gpt-3.5-turbo", 
                              model = "gpt-4-1106-preview", 
                              system_context = "You act as a function to extract information about a plant disease or pest outbreak from a provided report", 
                              common_context = "Use the extract_outbreak_data function to extract information from the provided report", 
                              pipeline = c("full", "assessment"), 
                              directory = extracted_crop_data_directory, 
                              overwrite = FALSE
                              ){
  
  overwrite <- as.logical(overwrite)
  pipeline <- match.arg(pipeline)
  
  if(pipeline == "full"){
    file_name <- paste0("ippc_", janitor::make_clean_names(unique(ippc_reports$preferred_name)), ".gz.parquet")
  }
  if(pipeline == "assessment"){
    file_name <- "ippc_assessment.gz.parquet"
  }
  
  existing_files <- list.files(file.path(directory))
  
  if(file_name %in% existing_files && !overwrite) {
    message("File already exists, skipping extraction")
    return(file.path(directory, file_name))
  }
  
  urls <- ippc_reports$url
  ippc_reports <- ippc_reports$specific_context
  
  openai_chat <- purrr::map2_dfr(ippc_reports, urls, function(ippc_report, url){
    
    # ippc_report <- ippc_reports[1]
    
    specific_context <- ippc_report
    
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
    
    function_call = get_openai_function_call_ippc(ippc_report)
    
    outbreak_details <- openai::create_chat_completion(
      model = model,
      messages = messages,
      functions = function_call$function_call
    ) |> dplyr::bind_cols()
    
    outbreak_details <- outbreak_details |>
      dplyr::mutate(url = url)
    
    outbreak_details
  })
  
  message(glue::glue("Saving {file_name}"))
  arrow::write_parquet(openai_chat, file.path(directory, file_name), compression = "gzip", compression_level = 5)
  
  return(file.path(directory, file_name))
}
