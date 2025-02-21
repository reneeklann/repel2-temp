misc_download_repel1_extract <- function(file, directory) {

  if(!file.exists(file.path(directory, file))){
    aws.s3::save_object(
      object = file,
      bucket = "s3://repel1-extracts/", 
      region = "us-east-1",
      file = file.path(directory, file)
    )
  }
  
  return(file.path(directory, file))

}
