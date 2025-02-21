#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param repel_calibration
#' @return
#' @export
plot_calibration <- function(repel_calibration, forecast_range = FALSE) {
  
  max_val <- max(c(repel_calibration$predicted_grp_mean, repel_calibration$outbreak_start_actual_prob))
  max_val <- round(max_val + 0.005, digits = 3)
  
  validation_plot <- ggplot2::ggplot(
    repel_calibration,
    ggplot2::aes(y = predicted_grp_mean, x  = outbreak_start_actual_prob)
  ) +
    ggplot2::geom_abline(color = "gray50") +
    ggplot2::geom_errorbar(aes(xmin = outbreak_start_actual_low, xmax = outbreak_start_actual_upper)) +
    ggplot2::geom_point(pch = 21,fill = "white")
  
  if (forecast_range) {
    validation_plot <- validation_plot +
      ggplot2::geom_segment(
        mapping = aes(
          x = outbreak_start_actual_prob,
          y = predicted_grp_min,
          xend = outbreak_start_actual_prob,
          yend = predicted_grp_max
        ),
        colour = "gray70", linetype = 2
      ) +
      ggplot2::scale_x_sqrt(limits = c(0, 1)) +
      ggplot2::scale_y_sqrt(limits = c(0, 1))
  } else {
    validation_plot <- validation_plot +
      ggplot2::scale_x_sqrt(limits = c(0, max_val)) +
      ggplot2::scale_y_sqrt(limits = c(0, max_val))
  }
    
  validation_plot <- validation_plot +
    ggplot2::labs(y = "Forecasted outbreak probability", x = "Observed outbreak rate", color = "",
         caption = str_wrap("Axes are square root transformed.", 120 )) +
    ggplot2::theme_minimal() +
    ggplot2::theme(text = element_text(size = 16),
          plot.title.position = "plot",
          plot.caption = element_text(hjust = 0))
  
  rm(list=setdiff(ls(), "validation_plot"))
  
  validation_plot
}
