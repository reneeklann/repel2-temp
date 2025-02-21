
get_eppo_report_urls <- function() {

  # get URLs for reporting pages grouped by year-month
  parent_url <- "https://gd.eppo.int/reporting/"
  parent_html <- rvest::read_html(parent_url)
  report_page_urls <- parent_html |>  rvest::html_nodes("a") |> rvest::html_attr("href")
  report_page_urls <- paste0(parent_url, basename(report_page_urls[grepl("reporting/Rse", report_page_urls)]))
  
  # get URLs for articles
  article_urls <- purrr::map(report_page_urls, function(report_page_url){
    report_page_html <- rvest::read_html(report_page_url)
    report_page_links <-  report_page_html |>  rvest::html_nodes("a") |> rvest::html_attr("href")
    report_page_links <-  paste0(parent_url, basename(report_page_links[grepl("reporting/article", report_page_links)]))
    return(report_page_links)
  }) |> purrr::reduce(c)
  
  return(article_urls)

}
