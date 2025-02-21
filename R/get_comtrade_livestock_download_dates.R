#' Get the download date range for COMTRADE data
#'
#' This function calculates the download date range for COMTRADE data, 
#' splitting the years into 12-year periods.
#'
#' @param start_date The starting year for the download range (default is 2000).
#' @param end_date The ending year for the download range (default is the 
#'   current year).
#'
#' @return A list containing the start and end years for each 12-year period.
#'
#' @examples
#' # Get the download date range for COMTRADE data from 2000 to the current year
#' get_comtrade_download_dates()
#'
#' # Get the download date range for COMTRADE data from 1995 to 2020
#' get_comtrade_download_dates(1995, 2020)
#'
#' @export
#'
get_comtrade_livestock_download_dates <- function(start_date = 2000,
                                                  end_date = format(Sys.Date(), "%Y")) {
  
  ## Add a lag if Sys.Date() is in the first half of end_date ----
  ## to account for lag in Comtrade reporting at fist half of current year
  end_date <- ifelse(
    Sys.Date() < as.Date(paste0(end_date, "-06-30")), 
    as.integer(end_date) - 1,
    end_date
  )
  
  ## Years starting from 2012 ----
  years <- 2012:end_date
  
  ## Split the dates to 6 year periods starting at year 2012 ----
  start_points <- seq(from = 1, to = length(years), by = 6)
  
  if (length(years) < 6) {
    end_points <- length(years)
  } else {
    end_points <- seq(from = 6, to = length(years), by = 6)
    
    if (length(end_points) < length(start_points)) { 
      end_points <- c(end_points, length(years)) 
    }
  }
  
  list(
    c(2000, years[start_points]),
    c(2011, years[end_points])
  )
}
