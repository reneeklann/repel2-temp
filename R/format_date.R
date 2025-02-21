format_date <- function(d){
  
  if(grepl("\\b\\d{4}-\\d{2}-\\d{2}\\b", d)) { 
    d <- lubridate::floor_date(as.Date(d), unit = "month")
  } else if(grepl("\\b\\d{4}-\\d{2}", d)){
    d <- lubridate::ym(d)
  } else {
    stop("Please check format of date")
  }
  return(d)
}
