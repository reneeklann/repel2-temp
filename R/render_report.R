#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param path
#' @return
#' @author Emma Mendelsohn
#' @export
render_report <- function(path, ...) {

  rmarkdown::render(
    input = path,
    quiet = FALSE,
    knit_root_dir = here::here()
  )
  
  # Return path to html file
  path

}
