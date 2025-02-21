suppressPackageStartupMessages(source("packages.R"))

# Migration ---------------------------------------------------------------
location_codes <- readxl::read_excel("aggregates_correspondence_table_2020_1.xlsx", sheet = 1, skip = 10)

location_code_lookup <- location_codes |> 
  select(c(1, 3, 4)) |> 
  janitor::clean_names() |> 
  drop_na(iso3_alpha_code)

human_migration <- readxl::read_excel("undesa_pd_2020_ims_stock_by_sex_destination_and_origin.xlsx", sheet = 2, skip = 10) |> 
  janitor::clean_names() |> 
  filter(location_code_of_destination %in% location_code_lookup$location_code,
         location_code_of_origin %in% location_code_lookup$location_code) |> 
  select(destination = region_development_group_country_or_area_of_destination, origin = region_development_group_country_or_area_of_origin, starts_with("x"))

unique(human_migration$destination)
unique(human_migration$origin)

human_migration |> 
  mutate(region = countrycode::countrycode(sourcevar = destination, origin = "country.name", destination = "region" )) |> 
  group_by(region, destination) |> 
  count() |> 
  group_by(region) |> 
  summarize(avg = round(mean(n)), n = n()) |> 
  ungroup() |> 
  drop_na() |> 
  mutate(region = paste0(region, " (n=", n, ")")) |> 
  arrange(avg)  |> 
  mutate(region = fct_inorder(region)) |> 
  ggplot(aes(y = region, x = avg)) +
  geom_bar(stat = "identity", fill = "gray60") +
  # geom_text(aes(label = avg)) +
  labs(y = "Destination Region", x = "Avg Number of Origin Countries Reported") +
  #scale_fill_viridis_c() +
  theme_bw() +
  theme(legend.position = "none")


# Travel ------------------------------------------------------------------

# conn <- repeldata::repel_remote_conn()
connect_yearly_wto_tourism <- tbl(conn, "connect_yearly_wto_tourism") |> collect()

tourism <- connect_yearly_wto_tourism |> filter(!imputed_value) |> drop_na(n_tourists)

tourism |> 
  distinct(country_origin, country_destination) |> 
  mutate(region = countrycode::countrycode(sourcevar = country_destination, origin = "iso3c", destination = "region" )) |> 
  group_by(region, country_destination) |> 
  count() |> 
  group_by(region) |> 
  summarize(avg = round(mean(n)), n = n()) |> 
  ungroup() |> 
  drop_na() |> 
  mutate(region = paste0(region, " (n=", n, ")")) |> 
  arrange(avg)  |> 
  mutate(region = fct_inorder(region)) |> 
  ggplot(aes(y = region, x = avg)) +
  geom_bar(stat = "identity", fill = "gray60") +
  labs(y = "Destination Region", x = "Avg Number of Origin Countries Reported") +
  theme_bw() +
  theme(legend.position = "none")
