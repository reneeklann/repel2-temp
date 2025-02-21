#  This uploads the data-raw directory to AWS
files <- list.files("data-raw", recursive = TRUE, full.names = TRUE)

purrr::walk(files, function(file){
  aws.s3::put_object(file = file, 
                     object = file,
                     bucket = glue::glue("s3://{Sys.getenv('AWS_DATA_BUCKET_ID')}/"), 
                     multipart = TRUE,
                     verbose = TRUE,
                     show_progress = TRUE)
})


# # This uploads the comtrade livestock directory to AWS in two parts (very lazy setup!)
# files <- list.files("data-raw/comtrade-livestock", recursive = TRUE, full.names = TRUE)
# files_2012 <- files[str_detect(files, "2012_")]
# files_2000 <- files[str_detect(files, "2000_")]
# sum(c(length(files_2012), length(files_2000))) == length(files)
# 
# objects_2012 <- str_replace(files_2012, "livestock/2012_", "livestock/2012/2012_")
# objects_2000 <- str_replace(files_2000, "livestock/2000_", "livestock/2000/2000_")
# 
# purrr::walk2(files_2012, objects_2012, function(file, object){
#   aws.s3::put_object(file = file,
#                      object = object,
#                      bucket = glue::glue("s3://{Sys.getenv('AWS_DATA_BUCKET_ID')}"),
#                      multipart = TRUE,
#                      verbose = TRUE,
#                      show_progress = TRUE)
# })
# purrr::walk2(files_2000, objects_2000, function(file, object){
#   aws.s3::put_object(file = file,
#                      object = object,
#                      bucket = glue::glue("s3://{Sys.getenv('AWS_DATA_BUCKET_ID')}"),
#                      multipart = TRUE,
#                      verbose = TRUE,
#                      show_progress = TRUE)
# })
# 
# 
# # This uploads the comtrade livestock directory to AWS in two parts (very lazy setup!)
# files <- list.files("data-raw/comtrade-livestock", recursive = TRUE, full.names = TRUE)
# files_2012 <- files[str_detect(files, "2012_")]
# files_2000 <- files[str_detect(files, "2000_")]
# sum(c(length(files_2012), length(files_2000))) == length(files)
# 
# 
# objects_2012 <- str_replace(files_2012, "livestock/2012_", "livestock/2012/2012_")
# objects_2000 <- str_replace(files_2000, "livestock/2000_", "livestock/2000/2000_")
# 
# purrr::walk2(files_2012, objects_2012, function(file, object){
#   aws.s3::put_object(file = file,
#                      object = object,
#                      bucket = glue::glue("s3://{Sys.getenv('AWS_DATA_BUCKET_ID')}"),
#                      multipart = TRUE,
#                      verbose = TRUE,
#                      show_progress = TRUE)
# })
# purrr::walk2(files_2000, objects_2000, function(file, object){
#   aws.s3::put_object(file = file,
#                      object = object,
#                      bucket = glue::glue("s3://{Sys.getenv('AWS_DATA_BUCKET_ID')}"),
#                      multipart = TRUE,
#                      verbose = TRUE,
#                      show_progress = TRUE)
# })
# 
# 
# # This uploads the comtrade crop directory to AWS
# files <- list.files("data-raw/comtrade-crop", recursive = TRUE, full.names = TRUE)
# files_2017 <- files[str_detect(files, "2017_")]
# files_2005 <- files[str_detect(files, "2005_")]
# files_1993 <- files[str_detect(files, "1993_")]
# sum(c(length(files_2017), length(files_2005), length(files_1993))) == length(files)
# 
# objects_2017 <- str_replace(files_2017, "crop/2017_", "crop/2017/2017_")
# objects_2005 <- str_replace(files_2005, "crop/2005_", "crop/2005/2005_")
# objects_1993 <- str_replace(files_1993, "crop/1993_", "crop/1993/1993_")
# 
# purrr::walk2(files_2017, objects_2017, function(file, object){
#   aws.s3::put_object(file = file,
#                      object = object,
#                      bucket = glue::glue("s3://{Sys.getenv('AWS_DATA_BUCKET_ID')}"),
#                      multipart = TRUE,
#                      verbose = TRUE,
#                      show_progress = TRUE)
# })
# purrr::walk2(files_2005, objects_2005, function(file, object){
#   aws.s3::put_object(file = file,
#                      object = object,
#                      bucket = glue::glue("s3://{Sys.getenv('AWS_DATA_BUCKET_ID')}"),
#                      multipart = TRUE,
#                      verbose = TRUE,
#                      show_progress = TRUE)
# })
# purrr::walk2(files_1993, objects_1993, function(file, object){
#   aws.s3::put_object(file = file,
#                      object = object,
#                      bucket = glue::glue("s3://{Sys.getenv('AWS_DATA_BUCKET_ID')}"),
#                      multipart = TRUE,
#                      verbose = TRUE,
#                      show_progress = TRUE)
# })
# 
# 
# # This uploads the comtrade crop directory to AWS
# files <- list.files("data-raw/comtrade-crop", recursive = TRUE, full.names = TRUE)
# files_2023 <- files[str_detect(files, "/2023_")]
# files_2017 <- files[str_detect(files, "/2017_")]
# files_2011 <- files[str_detect(files, "/2011_")]
# files_2005 <- files[str_detect(files, "/2005_")]
# files_1993 <- files[str_detect(files, "/1993_")]
# sum(c(length(files_2023), length(files_2017), length(files_2011), length(files_2005), length(files_1993))) == length(files)
# 
# objects_2023 <- str_replace(files_2023, "crop/2023_", "crop/2023/2023_")
# objects_2017 <- str_replace(files_2017, "crop/2017_", "crop/2017/2017_")
# objects_2011 <- str_replace(files_2011, "crop/2011_", "crop/2011/2011_")
# objects_2005 <- str_replace(files_2005, "crop/2005_", "crop/2005/2005_")
# objects_1993 <- str_replace(files_1993, "crop/1993_", "crop/1993/1993_")
# 
# 
# purrr::walk2(files_2023, objects_2023, function(file, object){
#   aws.s3::put_object(file = file,
#                      object = object,
#                      bucket = glue::glue("s3://{Sys.getenv('AWS_DATA_BUCKET_ID')}"),
#                      multipart = TRUE,
#                      verbose = TRUE,
#                      show_progress = TRUE)
# })
# purrr::walk2(files_2017, objects_2017, function(file, object){
#   aws.s3::put_object(file = file,
#                      object = object,
#                      bucket = glue::glue("s3://{Sys.getenv('AWS_DATA_BUCKET_ID')}"),
#                      multipart = TRUE,
#                      verbose = TRUE,
#                      show_progress = TRUE)
# })
# purrr::walk2(files_2011, objects_2011, function(file, object){
#   aws.s3::put_object(file = file,
#                      object = object,
#                      bucket = glue::glue("s3://{Sys.getenv('AWS_DATA_BUCKET_ID')}"),
#                      multipart = TRUE,
#                      verbose = TRUE,
#                      show_progress = TRUE)
# })
# purrr::walk2(files_2005, objects_2005, function(file, object){
#   aws.s3::put_object(file = file,
#                      object = object,
#                      bucket = glue::glue("s3://{Sys.getenv('AWS_DATA_BUCKET_ID')}"),
#                      multipart = TRUE,
#                      verbose = TRUE,
#                      show_progress = TRUE)
# })
# purrr::walk2(files_1993, objects_1993, function(file, object){
#   aws.s3::put_object(file = file,
#                      object = object,
#                      bucket = glue::glue("s3://{Sys.getenv('AWS_DATA_BUCKET_ID')}"),
#                      multipart = TRUE,
#                      verbose = TRUE,
#                      show_progress = TRUE)
# })
