---
title: Crop Data Assessment
author: Renee Klann, Emma Mendelsohn and Noam Ross, EcoHealth Alliance
date: "2024-02-14"
output: 
  rmarkdown::html_document:
    keep_md: true
---



This memorandum summarizes EcoHealth Alliance (EHA)'s findings on the availability of data required to construct the Crop Accidental Frequency model (CAFM).
These findings constitute part of Subtask 3.2.1.1 of FASRAC Phase II Frequency Model for Accidental Introduction EHA Scope of Work.

The model upon which the CAFM is to be based - REPEL - is trained on on historical data on the distribution and movement of livestock diseases, combined with information on potential disease vectors, including human travel and migration patterns, livestock and wildlife movements, and economic trade.
For the CAFM, we require similar data on crop diseases and pests.
The primary challenge in data acquisition is information on plant disease distribution and emergence, largely event-based surveillance reports.
Required vector data will largely mirror data already acquired for REPEL.

We conducted a search for sources of event-based plant disease reports, with our minimum criteria being that the source reports plant disease emergence or outbreak events that include the disease, country, host, and year of outbreak (finer resolution temporal data is useful but not strictly necessary for the model).
We identified four relevant sources of data: the [European and Mediterranean Plant Protection Organization (EPPO) Reporting Service](https://gd.eppo.int/reporting/), [International Plant Protection Convention (IPPC) official pest reports](https://www.ippc.int/en/countries/all/pestreport/), [North American Plant Protection Organization (NAPPO) official pest reports](https://www.pestalerts.org/nappo/), and [PestLens](https://pestlens.info/).
We also initially examined the [CABI Distribution Maps of Plant Diseases](https://www.cabidigitallibrary.org/journal/dmpd), but found that that their data frequently lacked year of outbreak and were generally incomplete derivatives of the other sources.

These sources provide data in structured and unstructured formats (i.e., free text).
EPPO, IPPC, and NAPPO make their data available in ways that can be automated.
For these we have acquired all raw data from their systems.
PestLens has access controls that limit automated scraping.
For PestLens, we acquired a sample to determine whether full data *could* be acquired and communication with Battelle and DHS about acquiring direct access to PestLens for raw data.

For EPPO, IPPC, and NAPPO we performed an initial assessment of data coverage based on the available structured data (generally event indexes and standard-structured report titles).
These include the event type, country and disease in event reports, as well as date of reporting, but not original outbreak dates or hosts.
This gives us sufficient information to determine coverage of diseases and geography, and date of reporting is a reasonable approximation of date of outbreak for the purpose of determining temporal coverage.
To train the CAFM, unstructured data will need to be processed to extract outbreak date and host information, by manual or natural language processing methods.
We are currently evaluating the use of local-instance large language models (LLMs) to automate this process.

Our assessment shows that we expect to have sufficient data to train the CAFM from these four sources.
Combined, the data sources have broad geographic and disease coverage, and consistent number of annual reports going back to approximately 2005.
Below, we describe the structure and coverage of each source.

## Overall data coverage (EPPO, IPPC, and NAPPO aggregated)

We have scraped and ingested data from EPPO, IPPC, and NAPPO, producing a total of 11,657 reports.
(PestLens has an additional 2,838, but as we do not have granular data yet it is not included in the following results.)
There are an average of 184 new records per six months.
EPPO has the greatest temporal coverage, and is the only source with records published in the 20th century.
Since the majority of records are from EPPO, the aggregated data reflects EPPO's geographic bias: Europe has the greatest number of records, followed by the Americas.

Within EPPO, 49% of reports were of new reports of pests in a geography, the key data type of training (other sources will require extraction of unstructured data to determine this).
Assuming a similar percentage across sources we estimate approximately 7,000 primary event records.
A conservative assumption of 33% record overlap brings us to a likely 4,680 records.

Given this coverage we believe we have sufficient data to train the CAFM.
REPEL was trained off of World Organization for Animal Health WAHIS data, which contained 4,943 primary event records over 30% of which were for Avian Influenza.
Our combined crop reports are modeatly more evenly distributed across diseases.

There are 1,130 reports specific to project priority diseases.
*Ralstonia solanacearum* is the most frequently reported priority disease, followed by Plum pox virus and Tomato yellow leaf curl virus.
Five priority diseases have no records in these sources: *Clavibacter nebraskensis*, *Coniothyrium glycines*, Groundnut rosette virus, *Peronosclerospora maydis*, and *Thecaphora frezii*.
Three priority diseases, *Puccinia graminis f. sp. tritici*, Cotton leaf curl virus, and *Magnaporthe oryzae pathotype Triticum*, have very low numbers of records and also few records are found from their country of origin.
We anticipate the CAFM may have considerable uncertainties in making predictions for these diseases.
The model structure can make predictions off few records, but requires some information of the history of the behavior of diseases emerging from the same geographies.
A manual search for records may be required (if PestLens data does not yield additional relevant reports).



#### Aggregated data number of records per year

![](crop-data-eval_files/figure-html/aggregated-yearly-1.png)<!-- -->

#### Aggregated data number of records per continent

EPPO records from 2023 and prior to 1993 are unstructured, so the continent appears as NA below.
We will extract the country from the free text.

![](crop-data-eval_files/figure-html/aggregated-continent-1.png)<!-- -->



#### Aggregated data records per project priority disease

![](crop-data-eval_files/figure-html/aggregated-priority-1.png)<!-- -->

## Data sources

### EPPO

The EPPO Reporting Service is a monthly newsletter on events of phytosanitary concern.
The EPPO Secretariat compiles official pest reports from its member countries as well as information from the scientific literature.
All articles from 1974 to the present are available in the EPPO Global Database, and the cumulative index contains information from articles dating back to 1967.
EPPO is the largest data source we identified, with 7,601 total articles.
Each article is associated with a keyword indicating the type of report (e.g., new outbreak, absence).
Based on these keywords, we were able to remove 2,631 articles as not being relevant to disease reporting (e.g., taxonomic revisions, conference announcements, and additions to the EPPO Alert List).

From the 4,970 remaining articles, some of which contain information about multiple pests and/or countries, there are 10,202 unique pest records.
The number of records per year increased substantially in the 1990s, and since 1994 it has ranged from 226 to 406.
EPPO reports on pest outbreaks worldwide, but almost half of the records are from Europe.
EPPO contains 999 records of project priority pests, with *Ralstonia solanacearum* being the most frequently reported, followed by Plum pox virus and Tomato yellow leaf curl virus.



#### EPPO Number of records per year

![](crop-data-eval_files/figure-html/eppo-yearly-1.png)<!-- -->

#### EPPO Number of records per continent

![](crop-data-eval_files/figure-html/eppo-continent-1.png)<!-- -->



#### EPPO Number of records per project priority disease

![](crop-data-eval_files/figure-html/eppo-priority-1.png)<!-- -->

#### EPPO Number of first reports from countries in which priority pests have been reported

For rare or sparsely reported diseases or pests, the primary factor in predicting their movement is not the number of reported outbreaks, but the number of records of any outbreak originating in the same location, so that the model can learn the relevant travel vectors for pests from this source.
We examined the number of relevant records of diseases and pests originating in the same source countries as the priority diseases below (for EPPO, which we can determine without additional raw data extraction).
The three diseases with the lowest numbers of relevant records are *Magnaporthe oryzae pathotype Triticum* (only reported in Zambia), Cotton leaf curl virus (only reported in Sudan), and *Puccinia graminis f. sp. tritici* (only reported in Iraq and Uganda).
These countries have very limited reporting generally, so predictions of pest behavior in these regions will be a large source of uncertainty in the CAFM.

![](crop-data-eval_files/figure-html/eppo-priority-country-analysis-1.png)<!-- -->

### IPPC

The International Plant Protection Convention (IPPC) is a treaty signed by over 180 countries, aiming to prevent the introduction and spread of plant pests.
Contracting parties to the Convention are obligated to report on pest outbreaks through the IPPC website.
IPPC reports span from 2005 to the present, with 18-64 reports per year.
There are 969 total reports.
After preliminary cleaning to remove reports that overlap with NAPPO, there are 644 reports.
IPPC has the most even geographic coverage of the sources, with 89-154 reports per continent.
There are 39 reports of project priority diseases.
*Synchytrium endobioticum*, Plum pox virus, and *Ralstonia solanacearum* are the mostly frequently reported priority diseases, with 5 or more reports each.





#### IPPC Number of records per project priority disease

![](crop-data-eval_files/figure-html/ippc-priority-1.png)<!-- -->

### NAPPO

The North American Plant Protection Organization (NAPPO) is composed of the national plant protection organizations of Canada, the United States, and Mexico.
It was established in 1976 as a regional organization of the International Plant Protection Convention.
Official pest reports, provided by the member countries, are available through NAPPO's Phytosanitary Alert System.
There are 811 total reports, spanning from 2002 to the present.
The majority of reports are from the United States.
We extracted pest names from the report titles, and manually corrected some names.
There are 92 reports of project priority diseases, with *Candidatus Liberibacter asiaticus*, *Globodera rostochiensis*, and *Globodera pallida* being the most frequently reported.



#### NAPPO Number of records per country

![](crop-data-eval_files/figure-html/nappo-country-1.png)<!-- -->



#### NAPPO Number of records per project priority disease

![](crop-data-eval_files/figure-html/nappo-priority-1.png)<!-- -->

### PestLens

PestLens is an early-warning system developed for USDA's Animal and Plant Health Inspection Service Plant Protection and Quarantine (APHIS-PPQ) program.
A team of analysts collects information on exotic plant pests from online sources and contributed by system users, and produces summaries which are disseminated through a weekly e-mail notification.
PestLens articles are also available through a searchable online archive.
The archive contains 2,851 articles, dating from 2007 to 2023.
The priority pests *Candidatus Liberibacter asiaticus* and *Candidatus Phytoplasma solani* are the third and fourth most frequently reported pests overall.
PestLens articles are associated with event categories, analogous to the keywords used by EPPO, as shown in the graph below. 
About 1,200 articles are reports of new locations.

![Source: https://pestlens.info/summaryReports.cfm](pestlens-event-category.png)

Unlike the previous three sources, the PestLens website is not readily amenable to scraping or other forms of data ingest.
We are in conversation with Battelle/DHS to contact PestLens directly to request access to the raw data in bulk.

## Pest name standardization

In the aggregated data from EPPO, IPPC, and NAPPO, there are 1,750 unique pest names.
222 of those names have 10 or more records each, and 899 names have only one record each.
Some are typos or synonyms, but most appear to be unique pests.
We used the R package {pestr}, which retrieves data from EPPO Data Services, to standardize the pest names.
10,119 records were successfully assigned preferred names and EPPO codes.
There are 1,404 unique preferred names.
699 records, with 256 unique pest names, were not standardized with pestr.
Not all plant pests are in the EPPO Global Database, which prevented some names from being standardized.

In addition to preferred names and EPPO codes, pestr produces a list of host species for each pest.
pestr provides limited information on pest taxonomy, so we will likely need to scrape taxonomic data from the EPPO Global Database website.



### Most frequently reported pests
This table includes all pests (i.e., not limited to priority diseases)

<table class=" lightable-paper" style='font-family: "Arial Narrow", arial, helvetica, sans-serif; width: auto !important; margin-left: auto; margin-right: auto;'>
 <thead>
  <tr>
   <th style="text-align:left;"> preferred_name </th>
   <th style="text-align:right;"> n </th>
   <th style="text-align:right;"> percent </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Ralstonia solanacearum </td>
   <td style="text-align:right;"> 245 </td>
   <td style="text-align:right;"> 0.0224133 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Diabrotica virgifera virgifera </td>
   <td style="text-align:right;"> 193 </td>
   <td style="text-align:right;"> 0.0176562 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Agrilus planipennis </td>
   <td style="text-align:right;"> 158 </td>
   <td style="text-align:right;"> 0.0144543 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Bactrocera dorsalis </td>
   <td style="text-align:right;"> 156 </td>
   <td style="text-align:right;"> 0.0142713 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Phytophthora ramorum </td>
   <td style="text-align:right;"> 155 </td>
   <td style="text-align:right;"> 0.0141799 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Erwinia amylovora </td>
   <td style="text-align:right;"> 150 </td>
   <td style="text-align:right;"> 0.0137224 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Anoplophora glabripennis </td>
   <td style="text-align:right;"> 149 </td>
   <td style="text-align:right;"> 0.0136310 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Bemisia tabaci </td>
   <td style="text-align:right;"> 143 </td>
   <td style="text-align:right;"> 0.0130821 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Plum pox virus </td>
   <td style="text-align:right;"> 139 </td>
   <td style="text-align:right;"> 0.0127161 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Tomato spotted wilt virus </td>
   <td style="text-align:right;"> 126 </td>
   <td style="text-align:right;"> 0.0115269 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Tomato yellow leaf curl virus </td>
   <td style="text-align:right;"> 123 </td>
   <td style="text-align:right;"> 0.0112524 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Pepino mosaic virus </td>
   <td style="text-align:right;"> 117 </td>
   <td style="text-align:right;"> 0.0107035 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Globodera rostochiensis </td>
   <td style="text-align:right;"> 113 </td>
   <td style="text-align:right;"> 0.0103376 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Spodoptera frugiperda </td>
   <td style="text-align:right;"> 113 </td>
   <td style="text-align:right;"> 0.0103376 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Ceratitis capitata </td>
   <td style="text-align:right;"> 111 </td>
   <td style="text-align:right;"> 0.0101546 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Anastrepha ludens </td>
   <td style="text-align:right;"> 106 </td>
   <td style="text-align:right;"> 0.0096972 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 'Candidatus Liberibacter asiaticus' </td>
   <td style="text-align:right;"> 102 </td>
   <td style="text-align:right;"> 0.0093313 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Tuta absoluta </td>
   <td style="text-align:right;"> 97 </td>
   <td style="text-align:right;"> 0.0088738 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Xylella fastidiosa </td>
   <td style="text-align:right;"> 91 </td>
   <td style="text-align:right;"> 0.0083249 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Clavibacter sepedonicus </td>
   <td style="text-align:right;"> 89 </td>
   <td style="text-align:right;"> 0.0081420 </td>
  </tr>
</tbody>
</table>

### Discrepencies in priority disease names

We also identified some discrepancies between the list of priority diseases and the disease names used in the sources.

-   Cotton leaf curl virus: Multiple species cause cotton leaf curl disease (Cotton leaf curl Alabad virus, Cotton leaf curl Bangalore virus, Cotton leaf curl Gezira virus, Cotton leaf curl Kokhran virus, and Cotton leaf curl Multan virus).
    We are currently treating records of any of these species as priority disease records.

-   *Magnaporthe oryzae* and *Magnaporthe oryzae* pathotype *Triticum*: IPPC does not distinguish between *Magnaporthe oryzae* and *Magnaporthe oryzae* pathotype *Triticum*, so we will have to extract the host from the free text to determine whether reports refer to rice blast or wheat blast.

-   *Ralstonia solanacearum* race 3 biovar 2: EPPO only reports *Ralstonia solanacearum* at the species level, and IPPC reports it by race but not by biovar.
    We can try to extract the race and/or biovar from the free text.

-   *Xylella fastidiosa* subspecies *fastidiosa*, *multiplex*, and *pauca*: EPPO, IPPC, and NAPPO don't report *Xylella fastidiosa* by subspecies.
    We can try to extract the subspecies from the free text.

The names used by EPPO, IPPC, and NAPPO for these diseases are shown in the table below.

<table class=" lightable-paper" style='font-family: "Arial Narrow", arial, helvetica, sans-serif; margin-left: auto; margin-right: auto;'>
 <thead>
  <tr>
   <th style="text-align:left;"> common_name </th>
   <th style="text-align:left;"> scientific_name </th>
   <th style="text-align:left;"> EPPO_code </th>
   <th style="text-align:left;"> EPPO_name </th>
   <th style="text-align:left;"> IPPC_name </th>
   <th style="text-align:left;"> NAPPO_name </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> leaf curl disease of cotton </td>
   <td style="text-align:left;"> Cotton leaf curl Gezira virus </td>
   <td style="text-align:left;"> CLCUGV </td>
   <td style="text-align:left;"> Cotton leaf curl Gezira virus </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> leaf curl disease of cotton </td>
   <td style="text-align:left;"> Cotton leaf curl virus </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> Cotton leaf curl virus </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> rice blast </td>
   <td style="text-align:left;"> Magnaporthe oryzae </td>
   <td style="text-align:left;"> PYRIOR </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> Magnaporthe oryzae </td>
   <td style="text-align:left;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> wheat blast </td>
   <td style="text-align:left;"> Magnaporthe oryzae pathotype Triticum </td>
   <td style="text-align:left;"> PYRIOR </td>
   <td style="text-align:left;"> Magnaporthe oryzae pathotype triticum </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> brown rot of potato, bacterial wilt of tomato, moko disease of banana </td>
   <td style="text-align:left;"> Ralstonia solanacearum </td>
   <td style="text-align:left;"> RALSSL </td>
   <td style="text-align:left;"> Ralstonia solanacearum </td>
   <td style="text-align:left;"> Ralstonia solanacearum (RALSSO) </td>
   <td style="text-align:left;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> brown rot of potato, bacterial wilt of tomato </td>
   <td style="text-align:left;"> Ralstonia solanacearum race 3 </td>
   <td style="text-align:left;"> PSDMS3 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> Ralstonia solanacearum race 3 </td>
   <td style="text-align:left;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> brown rot of potato, bacterial wilt of tomato </td>
   <td style="text-align:left;"> Ralstonia solanacearum race 3 biovar 2 </td>
   <td style="text-align:left;"> PSDMS3 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> Ralstonia solanacearum race 3 biovar 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Pierce's disease of grapevine, almond leaf scorch, citrus variegated chlorosis </td>
   <td style="text-align:left;"> Xylella fastidiosa </td>
   <td style="text-align:left;"> XYLEFA </td>
   <td style="text-align:left;"> Xylella fastidiosa </td>
   <td style="text-align:left;"> Xylella fastidiosa </td>
   <td style="text-align:left;"> Xylella fastidiosa </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Pierce's disease of grapevine </td>
   <td style="text-align:left;"> Xylella fastidiosa subsp. fastidiosa </td>
   <td style="text-align:left;"> XYLEFF </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> almond leaf scorch </td>
   <td style="text-align:left;"> Xylella fastidiosa subsp. multiplex </td>
   <td style="text-align:left;"> XYLEFM </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citrus variegated chlorosis </td>
   <td style="text-align:left;"> Xylella fastidiosa subsp. pauca </td>
   <td style="text-align:left;"> XYLEFP </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
  </tr>
</tbody>
</table>

<details>

<summary>Session info</summary>

-   Built at: 2024-02-14 11:56:44.185043
-   Last git commit hash: 8f11dfab4066ac55fdff783cdd3e6a0bbe0ccdda

</details>
