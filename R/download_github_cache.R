
download_github_cache <- function(object_name, 
                                  repo = "ecohealthalliance/repel2-battelle", 
                                  tag = "data-cache",
                                  dest = tempdir() ) {
  
  piggyback::pb_download(object_name,
                         repo = repo,
                         tag = tag,
                         dest = dest)

  qs::qread(paste0(dest, "/", object_name))
  
}
