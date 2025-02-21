library(tidyverse)
tar_load(wahis_epi_events_downloaded)
 dhs_diseases <- c("african swine fever", 
                 "anthrax",
                 "classical swine fever",
                 "foot-and-mouth disease",
                 "highly pathogenic avian influenza",
                 "newcastle disease",
                 "rift valley fever")

dat <- arrow::read_parquet(wahis_epi_events_downloaded) 

dat |> 
  filter(standardized_disease_name %in% dhs_diseases) |> 
  group_by(standardized_disease_name) |> 
  count() |> 
  ggplot(aes(x = reorder(standardized_disease_name, n), y = n)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  labs(x = "DHS Priority Disease", y = "Number of WAHIS Outbreak Reports") +
  theme_minimal() +
  theme(
    axis.text.x = element_text(size = 14, color = "black"),
    axis.text.y = element_text(size = 14, color = "black"),
    axis.title.x = element_text(size = 16, color = "black"),
    axis.title.y = element_text(size = 16, color = "black")
  )

ggsave("inst/wahis_report_bar_chart.png", width = 8, height = 4)
