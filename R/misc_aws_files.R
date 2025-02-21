# create_file_aws_url <- function(bucket, region, store, filename) {
#   paste0(
#     "https://",
#     paste(bucket, region, "amazonaws.com", sep = "."), "/",
#     paste(store, "objects", filename, sep = "/"), ".qs"
#   )
# }


create_file_aws_url <- function(bucket, region, filename) {
  paste0(
    "https://",
    paste(bucket, "s3", region, "amazonaws.com", sep = "."), 
    "/_targets/", filename, ".qs"
  )
}


get_file_aws <- function(bucket, filename) {
  data_file <- tempfile()
  
  s3 <- paws::s3()
  
  s3$get_object(
    Bucket = bucket, 
    Key = paste("_targets", filename, sep = "/")
  )$Body |>
    writeBin(con = data_file)
  
  qs::qread(data_file)
}