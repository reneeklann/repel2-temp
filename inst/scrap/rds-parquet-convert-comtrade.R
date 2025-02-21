rds_files <- list.files("data-raw/un-comtrade-rds", full.names = TRUE)
for(fi in rds_files){
  x <- read_rds(fi)
  
  file_name <- tools::file_path_sans_ext(basename(fi))
  if(ncol(x) ==1){
    file_name <- paste0(file_name, "_empty.gz.parquet")
  }else{
    file_name <- paste0(file_name, ".gz.parquet")
  }
  
  arrow::write_parquet(x, paste0("data-raw/un-comtrade-parquet/", file_name))
}
