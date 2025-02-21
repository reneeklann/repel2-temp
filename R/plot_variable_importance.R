#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param repel_variable_importance_priority_diseases_usa
#' @return
#' @author Emma Mendelsohn
#' @export
plot_variable_importance <- function(repel_variable_importance_priority_diseases_usa) {
  
  dat <- repel_variable_importance_priority_diseases_usa$variable_importance |> 
    filter(prediction_window == max(prediction_window)) |> 
    mutate(pos = overall_variable_importance  > 0)
  
  vp_plot <- ggplot(dat) +
    geom_hline(aes(yintercept = 0), color = "gray50") +
    geom_point(aes(x = disease, y = overall_variable_importance, color = pos), size = 2) +
    geom_segment(aes(x = disease, xend = disease, y = overall_variable_importance, yend = 0, color = pos)) +
    scale_color_manual(values = c("TRUE" = "#0072B2", "FALSE" = "#D55E00")) +
    labs(y = "Coefficient", x = "") +
    coord_flip() +
    facet_wrap(variable ~ ., scales = "free_x", nrow = 1)+
    theme_bw() +
    theme(legend.position = "none", 
          axis.text.y = element_text(size = 12, face = "bold"), 
          axis.text.x = element_text(size = 10), 
          plot.title = element_text(size = 14,  face = "bold"),
          plot.title.position = "plot") +
    NULL
  
  rm(list=setdiff(ls(), "vp_plot"))
  
  return(vp_plot)
  
}
