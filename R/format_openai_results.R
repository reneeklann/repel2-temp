#' Convert the JSON formatted openAI responses into a tibble
#'
#' @param 
#'
#' @return A tibble
#' @export
#'
#' @examples
#' specific_context <- "Chronic wasting disease (CWD) is a fatal, prion disease of cervids that was first detected in Alberta in 2005"
#' common_context <- "Please use the extract_outbreak_data function to extract outbreak details from the given abstract and return only the results"
#' chat_results <- openai_chat(specific_context, common_context)
#' formatted_chat_results <- format_openai_results(chat_results)
format_openai_results <- function(extracted_data_files) {
  
  # extracted_data_files <- eppo_multi_data_extracted
  
  extracted_data <- arrow::open_dataset(extracted_data_files) |> 
    dplyr::collect()
  
  # format_JSON <- function(json) {
  #   json |> jsonlite::fromJSON() |> map(~.x |> compact())
  # }
  
  format_JSON <- function(json) {
    tryCatch({
      json |> jsonlite::fromJSON() |> map(~.x |> compact())
    }, error=function(cond) {
      return(NA)
    })
  }
  
  format_tb <- function(arguments) {
    if(all(is.na(arguments)))return(tibble::tibble(disease = "NA"))
    # fix missing
    if(!"disease" %in% names(arguments)) {arguments$disease <- "NA"}
    if(!"year" %in% names(arguments)) {arguments$year <- "NA"}
    if(!"month" %in% names(arguments)) {arguments$month <- "NA"}
    if(!"host" %in% names(arguments)) {arguments$host <- "NA"}
    if(!"presence" %in% names(arguments)) {arguments$presence <- "NA"}
    # if(!"event_type" %in% names(arguments)) {arguments$event_type <- "NA"}
    # fix nulls
    if(is.null(arguments$disease)) {arguments$disease <- "NA"}
    if(is.null(arguments$year)) {arguments$year <- "NA"}
    if(is.null(arguments$month)) {arguments$month <- "NA"}
    if(is.null(arguments$host)) {arguments$host <- "NA"}
    if(is.null(arguments$presence)) {arguments$presence <- "NA"}
    # if(is.null(arguments$event_type)) {arguments$event_type <- "NA"}
    
    arguments |> tibble::as_tibble() |> dplyr::mutate(across(everything(), as.character))
  }
  
  extracted_data |> dplyr::mutate(response = purrr::map_dfr(message.function_call.arguments, ~format_JSON(.x) |> format_tb()))
  
}
