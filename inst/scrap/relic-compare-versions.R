#remotes::install_github("ecohealthalliance/relic")
library(relic)
library(targets)

# compare old and new
old <- tar_read_version(connect_livestock_outbreaks, 
                        ref = "3051ba4", 
                        repo = "ecohealthalliance/repel2", 
                        store = "_targets_s3") 
new <- tar_read(connect_livestock_outbreaks)


##### ABW comparison
# ABW was not in the original version
connect_livestock_outbreaks_abw = new |> filter(country_iso3c == "ABW")

# all of these diseases are reported as endemic - which is likely incorrect
connect_livestock_outbreaks_abw |> distinct(disease, prediction_window, endemic) 

# let's look back at the data - it should only be a few places where a disease is reported - so this is an error in the connect functio
tar_load(repel_nowcast_predictions)
repel_nowcast_predictions |> 
  filter(country_iso3c == "ABW") |> 
  filter(disease_status == "present")





tar_load(country_livestock_six_month_disease_status)
abw_pre = country_livestock_six_month_disease_status|> filter(country_iso3c == "ABW")

abw_pre |> 
  distinct(disease)
  #@filter(disease_status == "present")
