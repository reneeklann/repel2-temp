# CAUTION this removes files from the project AWS bucket
library(purrr)
aws_contents <- aws.s3::get_bucket(bucket = Sys.getenv('AWS_DATA_BUCKET_ID'),
                                   prefix = "data-raw/comtrade-livestock", 
                                   max = Inf)
aws_to_delete <- aws_contents[!map_lgl(aws_contents, ~stringr::str_starts(.$LastModified, "2024-02-01"))]
walk(aws_to_delete, aws.s3::delete_object)
