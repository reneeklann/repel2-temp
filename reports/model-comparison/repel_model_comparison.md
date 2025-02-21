---
title: Comparison of Phase I and II models datasets - updated
author: Ernest Guevarra, Emma Mendelsohn and Noam Ross, EcoHealth Alliance
date: "2023-11-29"
output: 
  rmarkdown::html_document:
    toc: true
    keep_md: true
---



# Summary

This report is part of the REPEL model importation task (Task 1) of FASRAC Phase II Frequency Model for Accidental Introduction.
To reproduce the Phase I REPEL model, we have imported and refactored the original pipeline for data ingestion, transformation, augmentation, and model training.
Here, we compare the current Phase II dataset and model against Phase I to confirm we are able to produce comparable model results given changes in tooling and upstream data sources.
This step establishes a baseline before we recalibrate the model from a monthly to a yearly timescale and implement other improvements.

# Data Comparison

For the purposes of matching the Phase I model, we have filtered the current dataset to the date range used in the Phase I model, from January 2005 to May 2022.
Below, we summarize the key differences found from data generated between the Phase I and II pipelines, causes and implications.

We compare two datasets:

1)  **Aggregated dataset**. Each row in this dataset represents a unique combination of month, country, and disease. All possible combinations are represented. For the bilateral variables (number of migratory wildlife from outbreaks, number of shared borders with outbreaks, value of imported agricultural goods from outbreaks, number of livestock heads from outbreaks), the values represent the *total* imports from countries with outbreaks. For example, if estimating the probability of an African Swine Fever (ASF) outbreak in the United States in January 2022, the relevant features are the total values of migratory wildlife, shared borders, trade dollars, and livestock heads summed across all countries with current ASF outbreaks. These aggregated data are used for training the model.
2)  **Disaggregated dataset**. In this dataset, bilateral variables are disaggregated by origin country. Each row is the unique combination of month, country, disease, *and* origin country. In the example of estimating ASF outbreak probability in the US, this dataset provides the number of migratory wildlife, shared borders, trade dollars, and livestock heads coming separately from *each* country with a current ASF outbreak. This dataset is not used for training, but is used for model interpretation to estimate the contribution to risk from each source country.

Our comparison approach consists of checks for data structure and quantitative values.
We confirmed that the expected fields from each data source are present and that the count of records is sufficiently similar.
We expect a small difference in record count will be due to non-standard names being introduced in updated records though we do not expect these corrections to have much bearing on the model results.

We quantified the difference in the variables between Phase I and II.
For logical (TRUE/FALSE) variables, we calculated the percent of matching records.
For the outcome variable `outbreak_status`, which indicates whether or not an outbreak has started within a country in a given month, we found less than a 0.5% difference from Phase I. The other logical variables have a similarly low difference in values, all within 2%.

For the continuous variables, we evaluated the median percent change in Phase II relative to Phase I. We found the changes were less less than 1% for all variables except three: We found larger differences in three variables: taxa population, veterinarian population, and COMTRADE agricultural trade dollars.

Overall, this comparison confirms that the Phase I and II datasets are sufficiently similar to continue to model replication.
While there are some expected differences in the data, these do not have a large impact on model results (see below).



## Data Structure Comparison

### Variable Check

Both the Phase I and Phase II datasets have the following variables:

<table class=" lightable-paper" style='font-family: "Arial Narrow", arial, helvetica, sans-serif; width: auto !important; '>
 <thead>
  <tr>
   <th style="text-align:left;"> Dataset Variables </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> country_iso3c </td>
  </tr>
  <tr>
   <td style="text-align:left;"> continent </td>
  </tr>
  <tr>
   <td style="text-align:left;"> disease_present_anywhere </td>
  </tr>
  <tr>
   <td style="text-align:left;"> disease </td>
  </tr>
  <tr>
   <td style="text-align:left;"> month </td>
  </tr>
  <tr>
   <td style="text-align:left;"> log_gdp_dollars </td>
  </tr>
  <tr>
   <td style="text-align:left;"> log_human_population </td>
  </tr>
  <tr>
   <td style="text-align:left;"> log_target_taxa_population </td>
  </tr>
  <tr>
   <td style="text-align:left;"> log_veterinarians </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outbreak_start </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outbreak_subsequent_month </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outbreak_ongoing </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outbreak_start_while_ongoing_or_endemic </td>
  </tr>
  <tr>
   <td style="text-align:left;"> endemic </td>
  </tr>
  <tr>
   <td style="text-align:left;"> disease_country_combo_unreported </td>
  </tr>
  <tr>
   <td style="text-align:left;"> n_migratory_wildlife_from_outbreaks </td>
  </tr>
  <tr>
   <td style="text-align:left;"> shared_borders_from_outbreaks </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ots_trade_dollars_from_outbreaks </td>
  </tr>
  <tr>
   <td style="text-align:left;"> fao_livestock_heads_from_outbreaks </td>
  </tr>
</tbody>
</table>



In addition to the above variables, the Phase I dataset had the following variables not in the Phase II dataset: `id`, `db_network_etag`, and `predicted_outbreak_probability`.
The first two are identifier variables that are specific to the way the previous dataset was stored.
`predicted_outbreak_probability` is the model prediction output which is not yet included with the Phase II dataset.

The disaggregated datasets from Phase I and II have the same fields as the aggregated datasets, with the addition of a field for `country_origin`.





### Records Check

There are more records in the Phase II dataset than Phase I due to the following reasons:

1)  In Phase I we had 58 unique diseases and in Phase II we have 78 unique diseases.
This includes 27 diseases in the Phase II dataset that are not in Phase I and 7 diseases that are in the Phase I and not in Phase II. Some are legitimate changes or new records that have been added to WAHIS (e.g., SARS-CoV-2), while others are due to non-standard names introduced in data updates that will be addressed in our next task.

2)  In Phase I we had 170 unique countries and in Phase II we have 178 unique countries represented.
Fiji, Guadeloupe, Greenland, Guyana, Jamaica, Samoa, Cuenta, and Melilla were added to the database.

3)  In Phase I some countries were missing data for months that were unreported in 2021 and 2022.
These have been backfilled.

Total records

<table class=" lightable-paper" style='font-family: "Arial Narrow", arial, helvetica, sans-serif; width: auto !important; '>
 <thead>
  <tr>
   <th style="text-align:left;"> Dataset </th>
   <th style="text-align:right;"> Number of records - Phase I </th>
   <th style="text-align:right;"> Number of records - Phase II </th>
   <th style="text-align:right;"> Difference </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> aggregated </td>
   <td style="text-align:right;"> 20562064 </td>
   <td style="text-align:right;"> 2901756 </td>
   <td style="text-align:right;"> -17660308 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> disaggregated </td>
   <td style="text-align:right;"> 20562064 </td>
   <td style="text-align:right;"> 22365926 </td>
   <td style="text-align:right;"> 1803862 </td>
  </tr>
</tbody>
</table>

<details>

<summary>Records by country - aggregated data (click to expand)</summary>

<table class="table" style="width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:left;"> Country code </th>
   <th style="text-align:left;"> Country name </th>
   <th style="text-align:right;"> Number of records - Phase I </th>
   <th style="text-align:right;"> Number of records - Phase II </th>
   <th style="text-align:right;"> Difference </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> AFG </td>
   <td style="text-align:left;"> Afghanistan </td>
   <td style="text-align:right;"> 121140 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -104838 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> AGO </td>
   <td style="text-align:left;"> Angola </td>
   <td style="text-align:right;"> 120918 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -104616 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ALB </td>
   <td style="text-align:left;"> Albania </td>
   <td style="text-align:right;"> 121515 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105213 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ARE </td>
   <td style="text-align:left;"> United Arab Emirates </td>
   <td style="text-align:right;"> 122024 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105722 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ARG </td>
   <td style="text-align:left;"> Argentina </td>
   <td style="text-align:right;"> 121254 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -104952 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ARM </td>
   <td style="text-align:left;"> Armenia </td>
   <td style="text-align:right;"> 122886 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -106584 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> AUS </td>
   <td style="text-align:left;"> Australia </td>
   <td style="text-align:right;"> 121446 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105144 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> AUT </td>
   <td style="text-align:left;"> Austria </td>
   <td style="text-align:right;"> 121964 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105662 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> AZE </td>
   <td style="text-align:left;"> Azerbaijan </td>
   <td style="text-align:right;"> 123334 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -107032 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> BDI </td>
   <td style="text-align:left;"> Burundi </td>
   <td style="text-align:right;"> 120991 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -104689 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> BEL </td>
   <td style="text-align:left;"> Belgium </td>
   <td style="text-align:right;"> 121895 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105593 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> BEN </td>
   <td style="text-align:left;"> Benin </td>
   <td style="text-align:right;"> 121300 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -104998 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> BFA </td>
   <td style="text-align:left;"> Burkina Faso </td>
   <td style="text-align:right;"> 121046 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -104744 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> BGD </td>
   <td style="text-align:left;"> Bangladesh </td>
   <td style="text-align:right;"> 121458 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105156 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> BGR </td>
   <td style="text-align:left;"> Bulgaria </td>
   <td style="text-align:right;"> 121725 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105423 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> BHR </td>
   <td style="text-align:left;"> Bahrain </td>
   <td style="text-align:right;"> 121879 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105577 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> BIH </td>
   <td style="text-align:left;"> Bosnia &amp; Herzegovina </td>
   <td style="text-align:right;"> 121643 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105341 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> BLR </td>
   <td style="text-align:left;"> Belarus </td>
   <td style="text-align:right;"> 121886 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105584 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> BLZ </td>
   <td style="text-align:left;"> Belize </td>
   <td style="text-align:right;"> 121752 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105450 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> BOL </td>
   <td style="text-align:left;"> Bolivia </td>
   <td style="text-align:right;"> 121382 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105080 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> BRA </td>
   <td style="text-align:left;"> Brazil </td>
   <td style="text-align:right;"> 121112 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -104810 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> BTN </td>
   <td style="text-align:left;"> Bhutan </td>
   <td style="text-align:right;"> 121793 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105491 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> BWA </td>
   <td style="text-align:left;"> Botswana </td>
   <td style="text-align:right;"> 121100 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -104798 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CAF </td>
   <td style="text-align:left;"> Central African Republic </td>
   <td style="text-align:right;"> 121208 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -104906 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CAN </td>
   <td style="text-align:left;"> Canada </td>
   <td style="text-align:right;"> 122087 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105785 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CHE </td>
   <td style="text-align:left;"> Switzerland </td>
   <td style="text-align:right;"> 121797 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105495 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CHL </td>
   <td style="text-align:left;"> Chile </td>
   <td style="text-align:right;"> 121483 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105181 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CHN </td>
   <td style="text-align:left;"> China </td>
   <td style="text-align:right;"> 120851 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -104549 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CIV </td>
   <td style="text-align:left;"> Côte d’Ivoire </td>
   <td style="text-align:right;"> 121128 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -104826 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CMR </td>
   <td style="text-align:left;"> Cameroon </td>
   <td style="text-align:right;"> 121085 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -104783 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> COD </td>
   <td style="text-align:left;"> Congo - Kinshasa </td>
   <td style="text-align:right;"> 123109 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -106807 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> COG </td>
   <td style="text-align:left;"> Congo - Brazzaville </td>
   <td style="text-align:right;"> 121650 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105348 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> COL </td>
   <td style="text-align:left;"> Colombia </td>
   <td style="text-align:right;"> 121184 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -104882 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> COM </td>
   <td style="text-align:left;"> Comoros </td>
   <td style="text-align:right;"> 121915 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105613 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CPV </td>
   <td style="text-align:left;"> Cape Verde </td>
   <td style="text-align:right;"> 121996 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105694 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CRI </td>
   <td style="text-align:left;"> Costa Rica </td>
   <td style="text-align:right;"> 121340 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105038 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CUB </td>
   <td style="text-align:left;"> Cuba </td>
   <td style="text-align:right;"> 122155 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105853 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CYP </td>
   <td style="text-align:left;"> Cyprus </td>
   <td style="text-align:right;"> 121521 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105219 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CZE </td>
   <td style="text-align:left;"> Czechia </td>
   <td style="text-align:right;"> 121992 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105690 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> DEU </td>
   <td style="text-align:left;"> Germany </td>
   <td style="text-align:right;"> 121803 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105501 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> DJI </td>
   <td style="text-align:left;"> Djibouti </td>
   <td style="text-align:right;"> 121936 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105634 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> DNK </td>
   <td style="text-align:left;"> Denmark </td>
   <td style="text-align:right;"> 122214 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105912 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> DOM </td>
   <td style="text-align:left;"> Dominican Republic </td>
   <td style="text-align:right;"> 121910 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105608 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> DZA </td>
   <td style="text-align:left;"> Algeria </td>
   <td style="text-align:right;"> 121700 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105398 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ECU </td>
   <td style="text-align:left;"> Ecuador </td>
   <td style="text-align:right;"> 121611 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105309 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> EGY </td>
   <td style="text-align:left;"> Egypt </td>
   <td style="text-align:right;"> 121619 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105317 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ESP </td>
   <td style="text-align:left;"> Spain </td>
   <td style="text-align:right;"> 123956 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -107654 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> EST </td>
   <td style="text-align:left;"> Estonia </td>
   <td style="text-align:right;"> 121977 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105675 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ETH </td>
   <td style="text-align:left;"> Ethiopia </td>
   <td style="text-align:right;"> 120697 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -104395 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> FIN </td>
   <td style="text-align:left;"> Finland </td>
   <td style="text-align:right;"> 121679 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105377 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> FRA </td>
   <td style="text-align:left;"> France </td>
   <td style="text-align:right;"> 121887 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105585 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> FRO </td>
   <td style="text-align:left;"> Faroe Islands </td>
   <td style="text-align:right;"> 2974 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> 13328 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> GAB </td>
   <td style="text-align:left;"> Gabon </td>
   <td style="text-align:right;"> 121660 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105358 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> GBR </td>
   <td style="text-align:left;"> United Kingdom </td>
   <td style="text-align:right;"> 121350 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105048 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> GEO </td>
   <td style="text-align:left;"> Georgia </td>
   <td style="text-align:right;"> 121689 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105387 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> GHA </td>
   <td style="text-align:left;"> Ghana </td>
   <td style="text-align:right;"> 121085 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -104783 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> GIN </td>
   <td style="text-align:left;"> Guinea </td>
   <td style="text-align:right;"> 121314 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105012 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> GMB </td>
   <td style="text-align:left;"> Gambia </td>
   <td style="text-align:right;"> 121690 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105388 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> GNB </td>
   <td style="text-align:left;"> Guinea-Bissau </td>
   <td style="text-align:right;"> 121491 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105189 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> GRC </td>
   <td style="text-align:left;"> Greece </td>
   <td style="text-align:right;"> 121023 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -104721 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> GTM </td>
   <td style="text-align:left;"> Guatemala </td>
   <td style="text-align:right;"> 121533 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105231 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> GUF </td>
   <td style="text-align:left;"> French Guiana </td>
   <td style="text-align:right;"> 122148 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105846 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> HKG </td>
   <td style="text-align:left;"> Hong Kong SAR China </td>
   <td style="text-align:right;"> 122276 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105974 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> HND </td>
   <td style="text-align:left;"> Honduras </td>
   <td style="text-align:right;"> 121890 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105588 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> HRV </td>
   <td style="text-align:left;"> Croatia </td>
   <td style="text-align:right;"> 121808 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105506 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> HTI </td>
   <td style="text-align:left;"> Haiti </td>
   <td style="text-align:right;"> 121710 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105408 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> HUN </td>
   <td style="text-align:left;"> Hungary </td>
   <td style="text-align:right;"> 121567 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105265 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> IDN </td>
   <td style="text-align:left;"> Indonesia </td>
   <td style="text-align:right;"> 121560 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105258 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> IND </td>
   <td style="text-align:left;"> India </td>
   <td style="text-align:right;"> 120781 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -104479 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> IRL </td>
   <td style="text-align:left;"> Ireland </td>
   <td style="text-align:right;"> 121843 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105541 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> IRN </td>
   <td style="text-align:left;"> Iran </td>
   <td style="text-align:right;"> 120767 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -104465 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> IRQ </td>
   <td style="text-align:left;"> Iraq </td>
   <td style="text-align:right;"> 122281 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105979 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ISL </td>
   <td style="text-align:left;"> Iceland </td>
   <td style="text-align:right;"> 122027 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105725 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ISR </td>
   <td style="text-align:left;"> Israel </td>
   <td style="text-align:right;"> 120932 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -104630 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ITA </td>
   <td style="text-align:left;"> Italy </td>
   <td style="text-align:right;"> 121139 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -104837 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> JOR </td>
   <td style="text-align:left;"> Jordan </td>
   <td style="text-align:right;"> 121478 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105176 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> JPN </td>
   <td style="text-align:left;"> Japan </td>
   <td style="text-align:right;"> 121743 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105441 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> KAZ </td>
   <td style="text-align:left;"> Kazakhstan </td>
   <td style="text-align:right;"> 122736 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -106434 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> KEN </td>
   <td style="text-align:left;"> Kenya </td>
   <td style="text-align:right;"> 120687 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -104385 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> KGZ </td>
   <td style="text-align:left;"> Kyrgyzstan </td>
   <td style="text-align:right;"> 121497 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105195 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> KHM </td>
   <td style="text-align:left;"> Cambodia </td>
   <td style="text-align:right;"> 122010 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105708 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> KOR </td>
   <td style="text-align:left;"> South Korea </td>
   <td style="text-align:right;"> 121618 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105316 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> KWT </td>
   <td style="text-align:left;"> Kuwait </td>
   <td style="text-align:right;"> 121946 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105644 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> LAO </td>
   <td style="text-align:left;"> Laos </td>
   <td style="text-align:right;"> 121812 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105510 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> LBN </td>
   <td style="text-align:left;"> Lebanon </td>
   <td style="text-align:right;"> 121840 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105538 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> LBR </td>
   <td style="text-align:left;"> Liberia </td>
   <td style="text-align:right;"> 121950 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105648 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> LBY </td>
   <td style="text-align:left;"> Libya </td>
   <td style="text-align:right;"> 121334 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105032 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> LIE </td>
   <td style="text-align:left;"> Liechtenstein </td>
   <td style="text-align:right;"> 121897 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105595 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> LKA </td>
   <td style="text-align:left;"> Sri Lanka </td>
   <td style="text-align:right;"> 121938 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105636 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> LSO </td>
   <td style="text-align:left;"> Lesotho </td>
   <td style="text-align:right;"> 121500 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105198 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> LTU </td>
   <td style="text-align:left;"> Lithuania </td>
   <td style="text-align:right;"> 121988 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105686 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> LUX </td>
   <td style="text-align:left;"> Luxembourg </td>
   <td style="text-align:right;"> 121997 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105695 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> LVA </td>
   <td style="text-align:left;"> Latvia </td>
   <td style="text-align:right;"> 122208 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105906 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> MAR </td>
   <td style="text-align:left;"> Morocco </td>
   <td style="text-align:right;"> 122379 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -106077 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> MDA </td>
   <td style="text-align:left;"> Moldova </td>
   <td style="text-align:right;"> 121812 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105510 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> MDG </td>
   <td style="text-align:left;"> Madagascar </td>
   <td style="text-align:right;"> 121484 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105182 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> MDV </td>
   <td style="text-align:left;"> Maldives </td>
   <td style="text-align:right;"> 122147 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105845 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> MEX </td>
   <td style="text-align:left;"> Mexico </td>
   <td style="text-align:right;"> 121407 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105105 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> MKD </td>
   <td style="text-align:left;"> North Macedonia </td>
   <td style="text-align:right;"> 121378 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105076 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> MLI </td>
   <td style="text-align:left;"> Mali </td>
   <td style="text-align:right;"> 121289 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -104987 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> MLT </td>
   <td style="text-align:left;"> Malta </td>
   <td style="text-align:right;"> 121900 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105598 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> MMR </td>
   <td style="text-align:left;"> Myanmar (Burma) </td>
   <td style="text-align:right;"> 121384 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105082 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> MNE </td>
   <td style="text-align:left;"> Montenegro </td>
   <td style="text-align:right;"> 121448 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105146 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> MNG </td>
   <td style="text-align:left;"> Mongolia </td>
   <td style="text-align:right;"> 121645 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105343 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> MOZ </td>
   <td style="text-align:left;"> Mozambique </td>
   <td style="text-align:right;"> 121139 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -104837 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> MRT </td>
   <td style="text-align:left;"> Mauritania </td>
   <td style="text-align:right;"> 121651 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105349 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> MUS </td>
   <td style="text-align:left;"> Mauritius </td>
   <td style="text-align:right;"> 121998 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105696 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> MWI </td>
   <td style="text-align:left;"> Malawi </td>
   <td style="text-align:right;"> 121544 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105242 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> MYS </td>
   <td style="text-align:left;"> Malaysia </td>
   <td style="text-align:right;"> 122295 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105993 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> MYT </td>
   <td style="text-align:left;"> Mayotte </td>
   <td style="text-align:right;"> 122136 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105834 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NAM </td>
   <td style="text-align:left;"> Namibia </td>
   <td style="text-align:right;"> 120685 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -104383 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NCL </td>
   <td style="text-align:left;"> New Caledonia </td>
   <td style="text-align:right;"> 122133 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105831 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NER </td>
   <td style="text-align:left;"> Niger </td>
   <td style="text-align:right;"> 121288 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -104986 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGA </td>
   <td style="text-align:left;"> Nigeria </td>
   <td style="text-align:right;"> 121517 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105215 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NIC </td>
   <td style="text-align:left;"> Nicaragua </td>
   <td style="text-align:right;"> 121540 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105238 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NLD </td>
   <td style="text-align:left;"> Netherlands </td>
   <td style="text-align:right;"> 121717 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105415 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NOR </td>
   <td style="text-align:left;"> Norway </td>
   <td style="text-align:right;"> 121631 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105329 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NPL </td>
   <td style="text-align:left;"> Nepal </td>
   <td style="text-align:right;"> 121616 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105314 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NZL </td>
   <td style="text-align:left;"> New Zealand </td>
   <td style="text-align:right;"> 121829 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105527 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> OMN </td>
   <td style="text-align:left;"> Oman </td>
   <td style="text-align:right;"> 121292 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -104990 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PAK </td>
   <td style="text-align:left;"> Pakistan </td>
   <td style="text-align:right;"> 121218 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -104916 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PAN </td>
   <td style="text-align:left;"> Panama </td>
   <td style="text-align:right;"> 121835 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105533 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PER </td>
   <td style="text-align:left;"> Peru </td>
   <td style="text-align:right;"> 121522 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105220 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PHL </td>
   <td style="text-align:left;"> Philippines </td>
   <td style="text-align:right;"> 121480 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105178 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PNG </td>
   <td style="text-align:left;"> Papua New Guinea </td>
   <td style="text-align:right;"> 122018 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105716 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> POL </td>
   <td style="text-align:left;"> Poland </td>
   <td style="text-align:right;"> 121841 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105539 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PRK </td>
   <td style="text-align:left;"> North Korea </td>
   <td style="text-align:right;"> 122138 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105836 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PRT </td>
   <td style="text-align:left;"> Portugal </td>
   <td style="text-align:right;"> 121731 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105429 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PRY </td>
   <td style="text-align:left;"> Paraguay </td>
   <td style="text-align:right;"> 121582 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105280 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PSE </td>
   <td style="text-align:left;"> Palestinian Territories </td>
   <td style="text-align:right;"> 121507 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105205 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PYF </td>
   <td style="text-align:left;"> French Polynesia </td>
   <td style="text-align:right;"> 122152 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105850 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> QAT </td>
   <td style="text-align:left;"> Qatar </td>
   <td style="text-align:right;"> 121711 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105409 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> REU </td>
   <td style="text-align:left;"> Réunion </td>
   <td style="text-align:right;"> 122153 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105851 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ROU </td>
   <td style="text-align:left;"> Romania </td>
   <td style="text-align:right;"> 121428 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105126 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> RUS </td>
   <td style="text-align:left;"> Russia </td>
   <td style="text-align:right;"> 120791 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -104489 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> RWA </td>
   <td style="text-align:left;"> Rwanda </td>
   <td style="text-align:right;"> 121396 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105094 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SAU </td>
   <td style="text-align:left;"> Saudi Arabia </td>
   <td style="text-align:right;"> 121353 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105051 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SDN </td>
   <td style="text-align:left;"> Sudan </td>
   <td style="text-align:right;"> 121122 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -104820 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SEN </td>
   <td style="text-align:left;"> Senegal </td>
   <td style="text-align:right;"> 121201 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -104899 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SGP </td>
   <td style="text-align:left;"> Singapore </td>
   <td style="text-align:right;"> 122186 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105884 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SHN </td>
   <td style="text-align:left;"> St. Helena </td>
   <td style="text-align:right;"> 122150 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105848 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SLE </td>
   <td style="text-align:left;"> Sierra Leone </td>
   <td style="text-align:right;"> 123029 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -106727 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SLV </td>
   <td style="text-align:left;"> El Salvador </td>
   <td style="text-align:right;"> 121266 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -104964 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SRB </td>
   <td style="text-align:left;"> Serbia </td>
   <td style="text-align:right;"> 121835 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105533 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SSD </td>
   <td style="text-align:left;"> South Sudan </td>
   <td style="text-align:right;"> 121777 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105475 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SUR </td>
   <td style="text-align:left;"> Suriname </td>
   <td style="text-align:right;"> 121812 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105510 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SVK </td>
   <td style="text-align:left;"> Slovakia </td>
   <td style="text-align:right;"> 121630 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105328 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SVN </td>
   <td style="text-align:left;"> Slovenia </td>
   <td style="text-align:right;"> 121831 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105529 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SWE </td>
   <td style="text-align:left;"> Sweden </td>
   <td style="text-align:right;"> 121760 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105458 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SWZ </td>
   <td style="text-align:left;"> Eswatini </td>
   <td style="text-align:right;"> 121522 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105220 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SYR </td>
   <td style="text-align:left;"> Syria </td>
   <td style="text-align:right;"> 121704 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105402 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> TCD </td>
   <td style="text-align:left;"> Chad </td>
   <td style="text-align:right;"> 121342 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105040 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> TGO </td>
   <td style="text-align:left;"> Togo </td>
   <td style="text-align:right;"> 121180 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -104878 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> THA </td>
   <td style="text-align:left;"> Thailand </td>
   <td style="text-align:right;"> 121709 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105407 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> TJK </td>
   <td style="text-align:left;"> Tajikistan </td>
   <td style="text-align:right;"> 121513 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105211 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> TKM </td>
   <td style="text-align:left;"> Turkmenistan </td>
   <td style="text-align:right;"> 121692 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105390 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> TLS </td>
   <td style="text-align:left;"> Timor-Leste </td>
   <td style="text-align:right;"> 121956 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105654 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> TUN </td>
   <td style="text-align:left;"> Tunisia </td>
   <td style="text-align:right;"> 121428 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105126 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> TUR </td>
   <td style="text-align:left;"> Turkey </td>
   <td style="text-align:right;"> 121387 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105085 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> TWN </td>
   <td style="text-align:left;"> Taiwan </td>
   <td style="text-align:right;"> 122173 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105871 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> TZA </td>
   <td style="text-align:left;"> Tanzania </td>
   <td style="text-align:right;"> 121076 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -104774 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> UGA </td>
   <td style="text-align:left;"> Uganda </td>
   <td style="text-align:right;"> 121103 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -104801 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> UKR </td>
   <td style="text-align:left;"> Ukraine </td>
   <td style="text-align:right;"> 122753 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -106451 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> URY </td>
   <td style="text-align:left;"> Uruguay </td>
   <td style="text-align:right;"> 121400 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105098 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> USA </td>
   <td style="text-align:left;"> United States </td>
   <td style="text-align:right;"> 121361 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -105059 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VEN </td>
   <td style="text-align:left;"> Venezuela </td>
   <td style="text-align:right;"> 121248 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -104946 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VNM </td>
   <td style="text-align:left;"> Vietnam </td>
   <td style="text-align:right;"> 120838 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -104536 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ZAF </td>
   <td style="text-align:left;"> South Africa </td>
   <td style="text-align:right;"> 120809 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -104507 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ZMB </td>
   <td style="text-align:left;"> Zambia </td>
   <td style="text-align:right;"> 121294 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -104992 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ZWE </td>
   <td style="text-align:left;"> Zimbabwe </td>
   <td style="text-align:right;"> 121187 </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> -104885 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CEU </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> FJI </td>
   <td style="text-align:left;"> Fiji </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> GLP </td>
   <td style="text-align:left;"> Guadeloupe </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> GRL </td>
   <td style="text-align:left;"> Greenland </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> GUY </td>
   <td style="text-align:left;"> Guyana </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> JAM </td>
   <td style="text-align:left;"> Jamaica </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> MEL </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> WSM </td>
   <td style="text-align:left;"> Samoa </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 16302 </td>
   <td style="text-align:right;"> NA </td>
  </tr>
</tbody>
</table>

</details>

<details>

<summary>Records by year - aggregated data (click to expand)</summary>

<table class="table" style="width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:left;"> Year </th>
   <th style="text-align:right;"> Number of records - Phase I </th>
   <th style="text-align:right;"> Number of records - Phase II </th>
   <th style="text-align:right;"> Difference </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 2005 </td>
   <td style="text-align:right;"> 815199 </td>
   <td style="text-align:right;"> 166608 </td>
   <td style="text-align:right;"> -648591 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2006 </td>
   <td style="text-align:right;"> 918875 </td>
   <td style="text-align:right;"> 166608 </td>
   <td style="text-align:right;"> -752267 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2007 </td>
   <td style="text-align:right;"> 1009510 </td>
   <td style="text-align:right;"> 166608 </td>
   <td style="text-align:right;"> -842902 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2008 </td>
   <td style="text-align:right;"> 1067158 </td>
   <td style="text-align:right;"> 166608 </td>
   <td style="text-align:right;"> -900550 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2009 </td>
   <td style="text-align:right;"> 1094175 </td>
   <td style="text-align:right;"> 166608 </td>
   <td style="text-align:right;"> -927567 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2010 </td>
   <td style="text-align:right;"> 1129063 </td>
   <td style="text-align:right;"> 166608 </td>
   <td style="text-align:right;"> -962455 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2011 </td>
   <td style="text-align:right;"> 1162264 </td>
   <td style="text-align:right;"> 166608 </td>
   <td style="text-align:right;"> -995656 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2012 </td>
   <td style="text-align:right;"> 1164244 </td>
   <td style="text-align:right;"> 166608 </td>
   <td style="text-align:right;"> -997636 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2013 </td>
   <td style="text-align:right;"> 1180903 </td>
   <td style="text-align:right;"> 166608 </td>
   <td style="text-align:right;"> -1014295 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2014 </td>
   <td style="text-align:right;"> 1212651 </td>
   <td style="text-align:right;"> 166608 </td>
   <td style="text-align:right;"> -1046043 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2015 </td>
   <td style="text-align:right;"> 1264996 </td>
   <td style="text-align:right;"> 166608 </td>
   <td style="text-align:right;"> -1098388 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2016 </td>
   <td style="text-align:right;"> 1277753 </td>
   <td style="text-align:right;"> 166608 </td>
   <td style="text-align:right;"> -1111145 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2017 </td>
   <td style="text-align:right;"> 1310517 </td>
   <td style="text-align:right;"> 166608 </td>
   <td style="text-align:right;"> -1143909 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2018 </td>
   <td style="text-align:right;"> 1322432 </td>
   <td style="text-align:right;"> 166608 </td>
   <td style="text-align:right;"> -1155824 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2019 </td>
   <td style="text-align:right;"> 1341323 </td>
   <td style="text-align:right;"> 166608 </td>
   <td style="text-align:right;"> -1174715 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2020 </td>
   <td style="text-align:right;"> 1323452 </td>
   <td style="text-align:right;"> 166608 </td>
   <td style="text-align:right;"> -1156844 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2021 </td>
   <td style="text-align:right;"> 1960431 </td>
   <td style="text-align:right;"> 166608 </td>
   <td style="text-align:right;"> -1793823 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2022 </td>
   <td style="text-align:right;"> 7118 </td>
   <td style="text-align:right;"> 69420 </td>
   <td style="text-align:right;"> 62302 </td>
  </tr>
</tbody>
</table>

</details>

<details>

<summary>Records by disease - aggregated data (click to expand)</summary>

<table class="table" style="width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:left;"> Disease </th>
   <th style="text-align:right;"> Number of records - Phase I </th>
   <th style="text-align:right;"> Number of records - Phase II </th>
   <th style="text-align:right;"> Difference </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> african horse sickness </td>
   <td style="text-align:right;"> 41840 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> -4638 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> african swine fever </td>
   <td style="text-align:right;"> 250181 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> -212979 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> anthrax </td>
   <td style="text-align:right;"> 3211839 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> -3174637 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> aujeszkys disease </td>
   <td style="text-align:right;"> 35650 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> 1552 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> avian chlamydiosis </td>
   <td style="text-align:right;"> 34303 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> 2899 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> avian infectious bronchitis </td>
   <td style="text-align:right;"> 33969 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> 3233 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> avian infectious laryngotracheitis </td>
   <td style="text-align:right;"> 34303 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> 2899 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> bovine anaplasmosis </td>
   <td style="text-align:right;"> 33969 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> bovine babesiosis </td>
   <td style="text-align:right;"> 35309 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> bovine leukosis </td>
   <td style="text-align:right;"> 33969 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> bovine spongiform encephalopathy </td>
   <td style="text-align:right;"> 41532 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> -4330 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> bovine viral diarrhea </td>
   <td style="text-align:right;"> 33969 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> brucella abortus </td>
   <td style="text-align:right;"> 36474 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> 728 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> brucella melitensis </td>
   <td style="text-align:right;"> 34815 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> caprine arthritis and encephalitis </td>
   <td style="text-align:right;"> 35488 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> 1714 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> classical swine fever </td>
   <td style="text-align:right;"> 87591 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> -50389 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contagious agalactia </td>
   <td style="text-align:right;"> 33969 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> 3233 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> dourine </td>
   <td style="text-align:right;"> 531723 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> -494521 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> equine encephalitis </td>
   <td style="text-align:right;"> 34637 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> 2565 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> equine herpes virus </td>
   <td style="text-align:right;"> 33969 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> 3233 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> equine infectious anaemia </td>
   <td style="text-align:right;"> 73853 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> -36651 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> equine influenza </td>
   <td style="text-align:right;"> 46696 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> -9494 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> equine piroplasmosis </td>
   <td style="text-align:right;"> 35814 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> 1388 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> equine viral rhinopneumonitis </td>
   <td style="text-align:right;"> 34303 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> 2899 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> foot-and-mouth disease </td>
   <td style="text-align:right;"> 313351 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> -276149 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> fowl typhoid </td>
   <td style="text-align:right;"> 34637 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> 2565 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> glanders </td>
   <td style="text-align:right;"> 464441 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> -427239 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> heartwater </td>
   <td style="text-align:right;"> 978267 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> -941065 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> hemorrhagic septicemia </td>
   <td style="text-align:right;"> 34637 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> 2565 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> highly pathogenic avian influenza </td>
   <td style="text-align:right;"> 484896 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> -447694 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> infectious bovine rhinotracheitis </td>
   <td style="text-align:right;"> 33980 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> 3222 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> infectious bursal disease </td>
   <td style="text-align:right;"> 34971 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> 2231 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> leishmaniasis </td>
   <td style="text-align:right;"> 1518913 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> -1481711 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> low pathogenic avian influenza </td>
   <td style="text-align:right;"> 130414 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> -93212 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lumpy skin disease </td>
   <td style="text-align:right;"> 103998 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> -66796 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> maedi visna </td>
   <td style="text-align:right;"> 34470 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> 2732 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> mycobacterium tuberculosis </td>
   <td style="text-align:right;"> 37988 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> -786 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> mycoplasma infection </td>
   <td style="text-align:right;"> 34977 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> 2225 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> newcastle disease </td>
   <td style="text-align:right;"> 131511 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> -94309 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ovine bluetongue disease </td>
   <td style="text-align:right;"> 225979 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> -188777 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ovine pox disease </td>
   <td style="text-align:right;"> 62262 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> -25060 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> parasitic gastroenteritis </td>
   <td style="text-align:right;"> 34136 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> paratuberculosis </td>
   <td style="text-align:right;"> 2427771 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> -2390569 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> peste des petits ruminants </td>
   <td style="text-align:right;"> 82472 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> -45270 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> pleuropneumonia </td>
   <td style="text-align:right;"> 1377771 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> porcine reproductive and respiratory syndrome </td>
   <td style="text-align:right;"> 52052 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> -14850 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> poxvirus </td>
   <td style="text-align:right;"> 299055 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> -261853 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> primary screwworm, new world screwworm </td>
   <td style="text-align:right;"> 33969 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> 3233 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> pullorum disease </td>
   <td style="text-align:right;"> 33969 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> 3233 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> q fever </td>
   <td style="text-align:right;"> 35641 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> 1561 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> rabies </td>
   <td style="text-align:right;"> 3996151 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> -3958949 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> rift valley fever </td>
   <td style="text-align:right;"> 59172 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> -21970 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> scrapie </td>
   <td style="text-align:right;"> 743640 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> -706438 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> taylorella equigenitalis </td>
   <td style="text-align:right;"> 49191 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> -11989 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> trypanosomiasis </td>
   <td style="text-align:right;"> 1687899 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> -1650697 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> venezuelan equine encephalitis </td>
   <td style="text-align:right;"> 36641 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> 561 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vesicular stomatitis </td>
   <td style="text-align:right;"> 34804 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> 2398 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> west nile encephalitis </td>
   <td style="text-align:right;"> 77873 </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> -40671 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> aethina tumida </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> american fool brood </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> brucella suis </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> brucellosis </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> chlamydia abortus </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> coronavirus </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> crimean congo haemorrhagic fever </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> echinococcosis </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> epizootic hemorrhagic disease </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> epizootic ulcerative syndrome </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> equine arteritis </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> infectious haematopoietic necrosis </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> infectious pancreatic necrosis </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> infectious salmon anaemia </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> influenza a </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> koi herpesvirus disease </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> mycoplasma gallisepticum </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> myxoma virus </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> necrotising hepatopancreatitis </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> paenibacillus larvae </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> porcine epidemic diarrhea </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sars-cov-2 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> schmallenberg virus </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> trichinellosis </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> tularemia </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> varroosis </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> viral hemorrhagic septicemia </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 37202 </td>
   <td style="text-align:right;"> NA </td>
  </tr>
</tbody>
</table>

</details>

## Quantitative Comparison

We performed the quantitative data comparison on the country and diseases that both datasets have in common, resulting in a total of 170 countries and 51 diseases being compared.

### Logical Variables

We calculated the percent of matching records for the logical (TRUE/FALSE) variables.
The outcome variable `outbreak_status`, which indicates whether or not an outbreak has started within a country, has less than a 0.5% difference from Phase I. The other logical variables have a similarly low difference in values, all with a 2% or less difference.



<table class=" lightable-paper" style='font-family: "Arial Narrow", arial, helvetica, sans-serif; width: auto !important; '>
 <thead>
  <tr>
   <th style="text-align:left;"> Logical Variable </th>
   <th style="text-align:left;"> Difference (% of total records) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> disease_country_combo_unreported </td>
   <td style="text-align:left;"> 1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> endemic </td>
   <td style="text-align:left;"> 14% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outbreak_ongoing </td>
   <td style="text-align:left;"> 0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outbreak_start_while_ongoing_or_endemic </td>
   <td style="text-align:left;"> 0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outbreak_start </td>
   <td style="text-align:left;"> 0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outbreak_subsequent_month </td>
   <td style="text-align:left;"> 0% </td>
  </tr>
</tbody>
</table>

### Continuous Variables

For the continuous variables, we compared the median percentage change from Phase I to II.
We found the changes were small for most of the variables (livestock trade, GDP, human population, migratory wildlife, and shared borders).
We found higher percentage changes for taxa population, veterinarian population, and COMTRADE agricultural trade dollars.
Changes in taxa data may be due to several causes - expansion of the known host range of some diseases means a greater host taxa population.
In some cases country reported livestock populations have been corrected and updated in the source (FAO).
For veterinarian count, we are aware has updated back-dated records.
We do not expect any of these changes to have large impacts on model performance.

<table class=" lightable-paper" style='font-family: "Arial Narrow", arial, helvetica, sans-serif; width: auto !important; '>
 <thead>
  <tr>
   <th style="text-align:left;"> Continuous Variable </th>
   <th style="text-align:left;"> Median Relative Difference (% change) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> fao_livestock_heads_from_outbreaks </td>
   <td style="text-align:left;"> Inf </td>
  </tr>
  <tr>
   <td style="text-align:left;"> log_gdp_dollars </td>
   <td style="text-align:left;"> 0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> log_human_population </td>
   <td style="text-align:left;"> 0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> log_target_taxa_population </td>
   <td style="text-align:left;"> 2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> log_veterinarians </td>
   <td style="text-align:left;"> -2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> n_migratory_wildlife_from_outbreaks </td>
   <td style="text-align:left;"> 6 568% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ots_trade_dollars_from_outbreaks </td>
   <td style="text-align:left;"> 271 890% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> shared_borders_from_outbreaks </td>
   <td style="text-align:left;"> Inf </td>
  </tr>
</tbody>
</table>

# Model Comparison

We fit the Phase II model using the same linear mixed effects approach as in Phase I. We assessed model performance using accuracy metrics and calibration curves, derived from the model's performance on hold-out validation data.
To compare performance independent of data, we evaluated both Phase I and Phase II models on the validation data from Phase II only.

## Model Summaries

Here we present printed model summaries to ensure comparability in the model objects.
Because the datasets for the two models differ, we cannot directly compare metrics such as deviance or AIC.
However, we observe that all reported values including residuals and variances are on the same expected scales.

<details>

<summary>Phase I Model Summary (click to expand)</summary>


```
## Generalized linear mixed model fit by maximum likelihood (Adaptive
##   Gauss-Hermite Quadrature, nAGQ = 0) [glmerMod]
##  Family: binomial  ( logit )
## Formula: 
## outbreak_start ~ (0 + continent | disease) + (0 + shared_borders_from_outbreaks |  
##     disease) + (0 + ots_trade_dollars_from_outbreaks | disease) +  
##     (0 + fao_livestock_heads_from_outbreaks | disease) + (0 +  
##     n_migratory_wildlife_from_outbreaks | disease) + (0 + log_gdp_dollars |  
##     disease) + (0 + log_human_population | disease) + (0 + log_target_taxa_population |  
##     disease) + (0 + log_veterinarians | disease)
##    Data: augmented_data_compressed
## Weights: wgts
## Control: glmerControl(calc.derivs = TRUE)
## 
##      AIC      BIC   logLik deviance df.resid 
##  18346.1  18606.7  -9149.0  18298.1   384328 
## 
## Scaled residuals: 
##    Min     1Q Median     3Q    Max 
##  -6.26  -0.06  -0.03  -0.02 918.39 
## 
## Random effects:
##  Groups    Name                                Variance  Std.Dev. Corr       
##  disease   continentAfrica                     5.6911682 2.38562             
##            continentAmericas                   3.3500077 1.83030  -0.04      
##            continentAsia                       4.2268658 2.05593   0.84  0.25
##            continentEurope                     4.1356430 2.03363   0.18  0.63
##            continentOceania                    0.9810750 0.99049   0.55  0.31
##  disease.1 shared_borders_from_outbreaks       0.0983553 0.31362             
##  disease.2 ots_trade_dollars_from_outbreaks    0.0096375 0.09817             
##  disease.3 fao_livestock_heads_from_outbreaks  0.0005926 0.02434             
##  disease.4 n_migratory_wildlife_from_outbreaks 0.5865768 0.76588             
##  disease.5 log_gdp_dollars                     1.3348996 1.15538             
##  disease.6 log_human_population                0.6441507 0.80259             
##  disease.7 log_target_taxa_population          1.3666570 1.16904             
##  disease.8 log_veterinarians                   0.0436349 0.20889             
##             
##             
##             
##             
##   0.58      
##   0.74  0.87
##             
##             
##             
##             
##             
##             
##             
##             
## Number of obs: 384352, groups:  disease, 58
## 
## Fixed effects:
##             Estimate Std. Error z value Pr(>|z|)    
## (Intercept)   -8.850      0.202  -43.82   <2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

</details>

<details>

<summary>Phase II Model Summary (click to expand)</summary>


```
## Generalized linear mixed model fit by maximum likelihood (Adaptive
##   Gauss-Hermite Quadrature, nAGQ = 0) [glmerMod]
##  Family: binomial  ( logit )
## Formula: 
## outbreak_start ~ (0 + continent | disease) + (0 + shared_borders_from_outbreaks |  
##     disease) + (0 + comtrade_dollars_from_outbreaks | disease) +  
##     (0 + fao_livestock_heads_from_outbreaks | disease) + (0 +  
##     n_migratory_wildlife_from_outbreaks | disease) + (0 + log_gdp_dollars |  
##     disease) + (0 + log_human_population | disease) + (0 + log_target_taxa_population |  
##     disease) + (0 + log_veterinarians | disease)
##    Data: augmented_data_compressed
## Weights: wgts
## Control: lme4::glmerControl(calc.derivs = TRUE)
## 
##      AIC      BIC   logLik deviance df.resid 
##  23483.7  23745.9 -11717.9  23435.7   410569 
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -10.672  -0.064  -0.031  -0.014 130.067 
## 
## Random effects:
##  Groups    Name                                Variance  Std.Dev. Corr       
##  disease   continentAfrica                     6.7239182 2.59305             
##            continentAmericas                   3.7619169 1.93957  -0.14      
##            continentAsia                       5.1470591 2.26871   0.79  0.31
##            continentEurope                     5.0074981 2.23774   0.29  0.62
##            continentOceania                    1.0870065 1.04260   0.41  0.66
##  disease.1 shared_borders_from_outbreaks       0.0958493 0.30960             
##  disease.2 comtrade_dollars_from_outbreaks     0.0181661 0.13478             
##  disease.3 fao_livestock_heads_from_outbreaks  0.0002478 0.01574             
##  disease.4 n_migratory_wildlife_from_outbreaks 1.2429234 1.11486             
##  disease.5 log_gdp_dollars                     1.9728098 1.40457             
##  disease.6 log_human_population                1.0659533 1.03245             
##  disease.7 log_target_taxa_population          0.5288750 0.72724             
##  disease.8 log_veterinarians                   0.1261803 0.35522             
##             
##             
##             
##             
##   0.55      
##   0.65  0.98
##             
##             
##             
##             
##             
##             
##             
##             
## Number of obs: 410593, groups:  disease, 51
## 
## Fixed effects:
##             Estimate Std. Error z value Pr(>|z|)    
## (Intercept)  -8.9136     0.2155  -41.36   <2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## optimizer (bobyqa) convergence code: 1 (bobyqa -- maximum number of function evaluations exceeded)
```

</details>



## Model Performance

We generated predictions from both models on the Phase II hold-out validation dataset.
For the Phase I model to be able to make predictions on the Phase II validation data, we removed the diseases and countries that were not represented in that model.

### Confusion Matrix

We present confusion matrices for both models to compare the models' ability to correctly predict new outbreaks.
Model predictions are in the form of probabilities from 0-1.
We assumed that a prediction of \>= 0.5 indicates that the model predicted an outbreak event.

While confusion matrices and their summary statistics are standard metrics for binary models, they are limited for evaluating this model, which predicts rare events that generally have a probability well below 0.5.
Metrics which weight negative events reflect the large number of zeroes in the dataset.
Metrics focusing only on rare outbreak events (Kappa, Negative Predictive Value, Matthews correlation coefficient) reflect performance in very small number of cases where monthly import risk is above 50%.
For these rare events, both models correctly predict a similar number of outbreak events (7 in Phase I and 13 in Phase II).
Calibration curves (next section) provide a better measure of rare events.

<img src="repel_model_comparison_files/figure-html/unnamed-chunk-16-1.png" width="50%" /><img src="repel_model_comparison_files/figure-html/unnamed-chunk-16-2.png" width="50%" />

<table class=" lightable-paper" style='font-family: "Arial Narrow", arial, helvetica, sans-serif; width: auto !important; '>
 <thead>
  <tr>
   <th style="text-align:left;"> Metric </th>
   <th style="text-align:left;"> Estimator </th>
   <th style="text-align:right;"> Phase I </th>
   <th style="text-align:right;"> Phase II </th>
   <th style="text-align:left;"> Relative Difference (% change) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> accuracy </td>
   <td style="text-align:left;"> binary </td>
   <td style="text-align:right;"> 0.9983547 </td>
   <td style="text-align:right;"> 0.9980891 </td>
   <td style="text-align:left;"> 0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> kap </td>
   <td style="text-align:left;"> binary </td>
   <td style="text-align:right;"> 0.0222110 </td>
   <td style="text-align:right;"> 0.0348552 </td>
   <td style="text-align:left;"> 56% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sens </td>
   <td style="text-align:left;"> binary </td>
   <td style="text-align:right;"> 0.9998263 </td>
   <td style="text-align:right;"> 0.9995440 </td>
   <td style="text-align:left;"> 0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> spec </td>
   <td style="text-align:left;"> binary </td>
   <td style="text-align:right;"> 0.0127273 </td>
   <td style="text-align:right;"> 0.0236364 </td>
   <td style="text-align:left;"> 86% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ppv </td>
   <td style="text-align:left;"> binary </td>
   <td style="text-align:right;"> 0.9985279 </td>
   <td style="text-align:right;"> 0.9985438 </td>
   <td style="text-align:left;"> 0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> npv </td>
   <td style="text-align:left;"> binary </td>
   <td style="text-align:right;"> 0.0985915 </td>
   <td style="text-align:right;"> 0.0718232 </td>
   <td style="text-align:left;"> -28% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> mcc </td>
   <td style="text-align:left;"> binary </td>
   <td style="text-align:right;"> 0.0349170 </td>
   <td style="text-align:right;"> 0.0403872 </td>
   <td style="text-align:left;"> 16% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> j_index </td>
   <td style="text-align:left;"> binary </td>
   <td style="text-align:right;"> 0.0125535 </td>
   <td style="text-align:right;"> 0.0231803 </td>
   <td style="text-align:left;"> 84% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> bal_accuracy </td>
   <td style="text-align:left;"> binary </td>
   <td style="text-align:right;"> 0.5062768 </td>
   <td style="text-align:right;"> 0.5115902 </td>
   <td style="text-align:left;"> 2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> detection_prevalence </td>
   <td style="text-align:left;"> binary </td>
   <td style="text-align:right;"> 0.9998076 </td>
   <td style="text-align:right;"> 0.9995094 </td>
   <td style="text-align:left;"> 0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> precision </td>
   <td style="text-align:left;"> binary </td>
   <td style="text-align:right;"> 0.9985279 </td>
   <td style="text-align:right;"> 0.9985438 </td>
   <td style="text-align:left;"> 0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> recall </td>
   <td style="text-align:left;"> binary </td>
   <td style="text-align:right;"> 0.9998263 </td>
   <td style="text-align:right;"> 0.9995440 </td>
   <td style="text-align:left;"> 0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> f_meas </td>
   <td style="text-align:left;"> binary </td>
   <td style="text-align:right;"> 0.9991767 </td>
   <td style="text-align:right;"> 0.9990436 </td>
   <td style="text-align:left;"> 0% </td>
  </tr>
</tbody>
</table>

### Calibration Curves

We assessed model predictions as probabilities against observed outbreak rates in the validation set.
We grouped predictions into 30 quantile-based bins, grouping across models for comparability.
We compared the average prediction of each bin to observed outbreak rates within the bin (represented as binomial probabilities and 95% confidence intervals).
Each prediction represents the expectation of an outbreak of a given disease in a country in a given month.
This assessment evaluates the reliability of predictions for rare events: given a predicted probability of a rare outbreak, how well is that probability borne out as a fraction of times that outbreaks actually occurred in the validation data?


![](repel_model_comparison_files/figure-html/unnamed-chunk-18-1.png)<!-- -->

Each bin represents approximately 9,000-15,000 predictions, with a median of 12,000.
Across the range of predictions, the average predicted probability matches the observed fraction of events (by falling within binomial confidence intervals) in 22/30 bins for Phase I and 22/30 bins for Phase II.

<table class=" lightable-paper" style='font-family: "Arial Narrow", arial, helvetica, sans-serif; width: auto !important; '>
<caption>values are per 10,000 potential events</caption>
 <thead>
  <tr>
   <th style="text-align:right;"> Mean Prediction </th>
   <th style="text-align:left;"> Observed Outbreak Rate (mean and 95%CI) - Phase I </th>
   <th style="text-align:left;"> Mean Prediction within 95%CI - Phase I </th>
   <th style="text-align:left;"> Observed Outbreak Rate (mean and 95%CI) - Phase II </th>
   <th style="text-align:left;"> Mean Prediction within 95%CI - Phase II </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 0.023 </td>
   <td style="text-align:left;"> 2.1 (0.57-7.6) </td>
   <td style="text-align:left;"> no </td>
   <td style="text-align:left;"> 0 (0-2.6) </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.080 </td>
   <td style="text-align:left;"> 0 (0.00000000000000027-3.3) </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> 0 (0-3) </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.130 </td>
   <td style="text-align:left;"> 0 (0-3) </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> 0.86 (0.15-4.9) </td>
   <td style="text-align:left;"> no </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.180 </td>
   <td style="text-align:left;"> 0.94 (0.17-5.3) </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> 0.72 (0.13-4.1) </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.220 </td>
   <td style="text-align:left;"> 0 (0-3.5) </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> 1.5 (0.4-5.3) </td>
   <td style="text-align:left;"> no </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.260 </td>
   <td style="text-align:left;"> 0.81 (0.14-4.6) </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> 1.6 (0.45-6) </td>
   <td style="text-align:left;"> no </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.310 </td>
   <td style="text-align:left;"> 2.3 (0.79-6.8) </td>
   <td style="text-align:left;"> no </td>
   <td style="text-align:left;"> 0.86 (0.15-4.9) </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.360 </td>
   <td style="text-align:left;"> 1.5 (0.42-5.5) </td>
   <td style="text-align:left;"> no </td>
   <td style="text-align:left;"> 0.87 (0.15-4.9) </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.410 </td>
   <td style="text-align:left;"> 0.76 (0.13-4.3) </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> 0.87 (0.15-4.9) </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.480 </td>
   <td style="text-align:left;"> 1.6 (0.43-5.7) </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> 0 (0-3.3) </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.570 </td>
   <td style="text-align:left;"> 0 (0-2.7) </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> 3.8 (1.5-9.7) </td>
   <td style="text-align:left;"> no </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.690 </td>
   <td style="text-align:left;"> 2.2 (0.73-6.3) </td>
   <td style="text-align:left;"> no </td>
   <td style="text-align:left;"> 0.94 (0.17-5.3) </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.830 </td>
   <td style="text-align:left;"> 0.78 (0.14-4.4) </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> 0.85 (0.15-4.8) </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.980 </td>
   <td style="text-align:left;"> 0.74 (0.13-4.2) </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> 0.9 (0.16-5.1) </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 1.100 </td>
   <td style="text-align:left;"> 3.4 (1.3-8.8) </td>
   <td style="text-align:left;"> no </td>
   <td style="text-align:left;"> 1.5 (0.42-5.6) </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 1.300 </td>
   <td style="text-align:left;"> 2.7 (0.91-7.9) </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> 2.2 (0.76-6.6) </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 1.600 </td>
   <td style="text-align:left;"> 3.5 (1.4-9.1) </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> 0.75 (0.13-4.3) </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2.000 </td>
   <td style="text-align:left;"> 0.78 (0.14-4.4) </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> 3.4 (1.3-8.7) </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2.400 </td>
   <td style="text-align:left;"> 1.5 (0.42-5.6) </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> 3.5 (1.3-8.9) </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 3.100 </td>
   <td style="text-align:left;"> 3.1 (1.2-7.9) </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> 3.5 (1.3-8.9) </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 3.900 </td>
   <td style="text-align:left;"> 4.6 (2.1-10) </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> 3.4 (1.3-8.8) </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 5.100 </td>
   <td style="text-align:left;"> 4.4 (2-9.7) </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> 5.4 (2.5-12) </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 6.800 </td>
   <td style="text-align:left;"> 7.6 (4.1-14) </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> 8.8 (4.8-16) </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 9.000 </td>
   <td style="text-align:left;"> 10 (5.9-17) </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> 10 (5.8-18) </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 12.000 </td>
   <td style="text-align:left;"> 12 (7-19) </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> 12 (7.2-20) </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 17.000 </td>
   <td style="text-align:left;"> 22 (15-32) </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> 9.1 (5.2-16) </td>
   <td style="text-align:left;"> no </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 23.000 </td>
   <td style="text-align:left;"> 24 (17-35) </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> 19 (13-29) </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 34.000 </td>
   <td style="text-align:left;"> 46 (36-61) </td>
   <td style="text-align:left;"> no </td>
   <td style="text-align:left;"> 23 (16-33) </td>
   <td style="text-align:left;"> no </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 59.000 </td>
   <td style="text-align:left;"> 78 (63-96) </td>
   <td style="text-align:left;"> no </td>
   <td style="text-align:left;"> 44 (34-57) </td>
   <td style="text-align:left;"> no </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 360.000 </td>
   <td style="text-align:left;"> 280 (250-320) </td>
   <td style="text-align:left;"> no </td>
   <td style="text-align:left;"> 230 (210-250) </td>
   <td style="text-align:left;"> no </td>
  </tr>
</tbody>
</table>

<details>

<summary>Session info</summary>

-   Built at: 2023-11-29 10:59:49.209716
-   Last git commit hash: d21227c1c069ad110f37b2b1016444f75bb31ec9

</details>
