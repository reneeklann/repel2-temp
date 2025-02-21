#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title

#' @return
#' @export
generate_confusion_matrix <- function(repel_validation_predict) {

  repel_validation_predict <- repel_validation_predict |>
    dplyr::mutate(
      predicted_fct = factor(predicted > 0.5),
      outbreak_start_fct = factor(outbreak_start)
    )
  # repel_validation_predict$predicted_fct <- factor(repel_validation_predict$predicted > 0.5)
  # repel_validation_predict$outbreak_start_fct <- factor(repel_validation_predict$outbreak_start)
  
  cm <- yardstick::conf_mat(
    repel_validation_predict, 
    truth = "outbreak_start_fct", 
    estimate = "predicted_fct"
  ) 
  
  # p <- cm |> 
  #   autoplot(type = "heatmap") +
  #   labs(y = "Predicted Outbreak Event", x = "Observed Outbreak Event") +
  #   theme(text = element_text(size = 15))

  return(cm)
}
