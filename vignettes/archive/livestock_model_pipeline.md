---
title: "REPEL Livestock Model Pipeline"
author: "EcoHealth Alliance"
date: "2024-05-31"
output: 
  rmarkdown::html_vignette:
    toc: true
    keep_md: true
vignette: >
  %\VignetteIndexEntry{REPEL Livestock Model Pipeline}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---



This vignette is an overview of the full pipeline for the livestock REPEL model, from data ingest and processing, model fitting, and predictions.

# Project setup

## Downloading the repository

The project GitHub repository is available at [https://github.com/ecohealthalliance/repel2-battelle](https://github.com/ecohealthalliance/repel2-battelle).

In the terminal, the repository can be cloned using HTTPS:

```         
git clone https://github.com/ecohealthalliance/repel2-battelle
```

or using SSH:

```         
git clone git@github.com:ecohealthalliance/repel2-battelle.git
```

You also have the option of downloading a zipped version of the repository from GitHub. Unzip the file into a preferred directory on your machine.

## Setting environment variables

Environment variables are used to store authentication keys for data sources and to specify model settings. 

Variables can be set manually before running the data ingest pipeline. For example, in R: 

```
Sys.setenv(VARIABLE_NAME = YOUR_VARIABLE_VALUE)
```
However, we suggest storing environmental variables in an `.env` file in the root directory of the repository. This way, environment variables will always be loaded prior to running the pipeline. 

### Authentication keys

Some of the data sources require authentication keys to access the data programmatically. The following keys should be saved as environment variables. 

```         
IUCN_REDLIST_KEY=YOUR_IUCN_REDLIST_KEY_HERE

COMTRADE_PRIMARY=YOUR_COMTRADE_PRIMARY_KEY_HERE
COMTRADE_SECONDARY=YOUR_COMTRADE_SECONDARY_KEY_HERE

DOLT_TOKEN=YOUR_DOLTHUB_TOKEN_HERE
```
Below we provide instructions for obtaining these keys.

#### The International Union for Conservation of Nature (IUCN) Red List of Threatened Species API token

The IUCN provides an API to programmatically access the IUCN Red List of Threatened Species.
The required API token can be generated by making a request at <https://apiv3.iucnredlist.org/api/v3/token> detailing reason for API use.
Request is sent to IUCN and approval along with the API token is provided to the email address used during registration.
This may take several days.

*Due to delays in obtaining IUCN tokens, the IUCN data file is now saved as part of this data repository. It is no longer necessary to obtain a token to be able to run the pipeline.*

#### United Nations Comtrade Database API token/key

The [UN Comtrade Database](https://comtradeplus.un.org/) can be accessed programmatically using its API.
The API token/key can be obtained as follows:

1.  Create a UN Comtrade Database account at this [link](https://unb2c.b2clogin.com/unb2c.onmicrosoft.com/b2c_1a_signup_signin_comtrade/oauth2/v2.0/authorize?client_id=85644091-2534-4703-a6e9-456533d03b2d&scope=openid%20https%3A%2F%2Funb2c.onmicrosoft.com%2Fcomtradeapibe%2Fcomtradeapifunction.write%20profile%20offline_access&redirect_uri=https%3A%2F%2Fcomtradeplus.un.org&client-request-id=3927c60f-62b4-49eb-838e-4a0eff479045&response_mode=fragment&response_type=code&x-client-SKU=msal.js.browser&x-client-VER=2.22.0&x-client-OS=&x-client-CPU=&client_info=1&code_challenge=VHldePVQmSWkhv_iK9_kBjUGPBLlGZA3S9vqiW74wwQ&code_challenge_method=S256&nonce=3905f277-db63-4746-93e7-264cb061b48a&state=eyJpZCI6IjAwNGMzYjU0LWRjMzMtNGNmOC1hOTg4LWUzYzJjNjc3NmU0OCIsIm1ldGEiOnsiaW50ZXJhY3Rpb25UeXBlIjoicmVkaXJlY3QifX0%3D)

2.  Sign in to the [UN Comtrade Database API portal](https://comtradedeveloper.un.org/signin?returnUrl=%2F) and then proceed to the **Products** tab (<https://comtradedeveloper.un.org/products>)

3.  From the **Products** page, select the **Free APIs** option (<https://comtradedeveloper.un.org/product#product=free>)

4.  In the text entry dialog box, enter `comtrade-v1` and then click the `Subscribe` button

After these steps, the page should now show you two subscription keys called primary and secondary which are the API tokens/keys needed for API access.

#### World Animal Health Information System (WAHIS) data via EcoHealth Alliance's DoltHub repository

EcoHealth Alliance routinely curates animal health information on animal disease events and outbreaks from WOAH's [WAHIS website](https://wahis.woah.org/#/home) using [DoltHub](https://www.dolthub.com).
The curated database is found [here](https://www.dolthub.com/repositories/ecohealthalliance/wahisdb) and is openly accessible.
Programmatically, access can be gained using a DoltHub API key.
A DoltHub API key can be created as follows:

1.  Create a DoltHub account

2.  Log in to your DoltHub account

3.  Create an API token in your [settings](https://www.dolthub.com/settings/tokens) on DoltHub

### Project settings

In addition to authentication keys, environment variables can be used to store project settings. For example, the user can set the following variables to use AWS for object storage:
```
AWS_REGION=YOUR_AWS_REGION_HERE
AWS_BUCKET_ID=YOUR_AWS_BUCKET_ID_HERE
AWS_ACCESS_KEY_ID=YOUR_AWS_ACCESS_KEY_ID_HERE
AWS_SECRET_ACCESS_KEY=YOUR_AWS_SECRET_ACCESS_KEY_HERE
```

Additional setting related to model fitting and prediction are described in their respective sections below. 

## R dependencies

The pipeline was created using R version 4.3.0 (2023-04-21).
This project uses the `{renv}` framework to record R package dependencies and versions.
Packages and versions used are recorded in `renv.lock` and code used to manage dependencies is in `renv/` and other files in the root project directory.
On starting an R session in the working directory, install R package dependencies:

```         
renv::restore()
```

or using the following command in Terminal

```         
Rscript -e 'renv::restore()'
```

## Targets workflow

This pipeline uses the [`targets` package](https://books.ropensci.org/targets/) as  a build system to resolve dependencies and cache results. This is similar conceptually to `make`, with the `_targets.R` file being the equivalent of a `Makefile`.
With `targets`, the user can build individual parts of the pipeline and they will be cached when running in the future.

<noscript>

```{=html}
<style>
 .withscript {display:none;}
</style>
```
</noscript>

[This diagram shows all the components of the workflow for the livestock model:]{.withscript}



## Docker

We have assembled a Docker image with necessary dependencies to run the pipeline, and a convenience shell script (`tar_make.sh`) for building pipeline steps in the console.
To build the image locally and use it to run the pipeline, run the following

```         
docker build . -t ecohealthalliance/repel2
docker run -v "$(pwd):/repel2" ecohealthalliance/repel2 ./tar_make.sh '<TARGET_NAME>'
```

`<TARGET_NAME>` can be any target and can also be `everything()` or other selection commands such `tidyr::contains(c("woah", "wahis", "iucn"))`.

In addition we have provided a tarball of Docker image.
Instead of building it, you can load it with

```         
docker load < repelcontainer_vXXX.tar.gz
```

# Data ingest and processing

The data ingest pipeline retrieves the datasets used by the REPEL model from their various sources.
These datasets and their respective sources are:

<table class=" lightable-paper" style='font-family: "Arial Narrow", arial, helvetica, sans-serif; margin-left: auto; margin-right: auto;'>
<caption>REPEL datasets with respective data sources</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> Name </th>
   <th style="text-align:left;"> Frequency </th>
   <th style="text-align:left;"> Dimension </th>
   <th style="text-align:left;"> Source </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Animal disease events and outbreaks </td>
   <td style="text-align:left;"> yearly </td>
   <td style="text-align:left;"> per country </td>
   <td style="text-align:left;"> [World Organisation for Animal Health](https://wahis.woah.org/#/home) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Country shared borders </td>
   <td style="text-align:left;"> static </td>
   <td style="text-align:left;"> bilateral </td>
   <td style="text-align:left;"> [CIA World Factbook archive](https://www.cia.gov/about/archives/download/factbook-2020.zip) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Wildlife migration </td>
   <td style="text-align:left;"> static </td>
   <td style="text-align:left;"> bilateral </td>
   <td style="text-align:left;"> [International Union for Conservation of Nature](https://www.iucnredlist.org/) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Livestock trade </td>
   <td style="text-align:left;"> yearly </td>
   <td style="text-align:left;"> bilateral </td>
   <td style="text-align:left;"> [Food and Agriculture Organization](https://www.fao.org/faostat/en/#data/QCL) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Agricultural Product Trade </td>
   <td style="text-align:left;"> yearly </td>
   <td style="text-align:left;"> bilateral </td>
   <td style="text-align:left;"> [United Nations Comtrade Database](https://comtradeplus.un.org/) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Gross Domestic Product (GDP) </td>
   <td style="text-align:left;"> yearly </td>
   <td style="text-align:left;"> per country </td>
   <td style="text-align:left;"> [World Bank](https://data.worldbank.org/indicator/NY.GDP.MKTP.CD) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Human population </td>
   <td style="text-align:left;"> yearly </td>
   <td style="text-align:left;"> per country </td>
   <td style="text-align:left;"> [World Bank](https://data.worldbank.org/indicator/NY.GDP.MKTP.CD) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Taxa population </td>
   <td style="text-align:left;"> yearly </td>
   <td style="text-align:left;"> per country </td>
   <td style="text-align:left;"> [Food and Agriculture Organization](https://www.fao.org/faostat/en/#data/QCL) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Veterinarian population </td>
   <td style="text-align:left;"> yearly </td>
   <td style="text-align:left;"> per country </td>
   <td style="text-align:left;"> [World Organisation for Animal Health](https://wahis.woah.org/#/home) </td>
  </tr>
</tbody>
</table>



The entire data ingest and processing pipeline can be run using the following command in the R console. 

```         
targets::tar_make(augmented_livestock_data_aggregated)
```

or using the following command in Terminal

```         
Rscript -e 'targets::tar_make(augmented_livestock_data_aggregated)'
```

The `augmented_livestock_data_aggregated` target endpoint is the full model dataset, which combines all predictor and outcome data sources, used for training and validation.
Note that this may take over a day to run due to the data download steps (particularly Comtrade).
Below we provide guidance for testing subsets of the data ingestion pipeline with faster run times.
Note, running `tar_make()` without specifying a target will run all livestock and crop targets.

## Pipeline testing

Given specific requirements (such as API tokens) and length of run times described above, we recommend the following steps for someone trying out this data ingest and processing pipeline for the first time or for someone reproducing the outputs:

1. Test that the pipeline works as described by running a data source pipeline that doesn't require any tokens

We would expect this pipeline to complete in \~20 minutes.

For this purpose, we recommend the pipelines for data retrieved from the FAO, UN Statistics Division, CIA World Factbook, and the World Bank.
To run these, the following command can be used in the R console:

```         
targets::tar_make(c(country_yearly_human_population, country_yearly_gdp, connect_static_shared_borders, country_yearly_taxa_population, country_yearly_vet_population, connect_yearly_fao_trade_livestock))
```

This step will give an indication that the general pipeline works as expected if the run completes without errors.
For a faster test, you could run the world bank GDP data pipeline, which should complete in seconds: `targets::tar_make(country_yearly_gdp)`.

2. Test the pipeline for the steps requiring authentication keys/tokens

We would expect this pipeline to complete in \~10 minutes.

The steps requiring authentication keys/tokens and completes fast are for data retrieved from the IUCN and WOAH (via EcoHealth Alliance's DoltHub database).
To run these, the following command can be used in the R console:

```         
targets::tar_make(c(connect_static_wildlife_migration, connect_livestock_outbreaks))
```

This step will test whether you have setup your authentication keys appropriately.

3. Run the pipeline for the UN Comtrade database

The remaining source, the UN Comtrade database, requires authentication and also runs the longest (depending on server traffic, could be 2-3 days).
So, we recommend running this last using this command in the R console:

```         
targets::tar_make(connect_yearly_comtrade_livestock)
```

**Addressing server errors with the UN Comtrade download pipeline**

The download pipeline for the trade data through the UN Comtrade data API uses authentication keys for a basic individual free subscription.
This type of subscription has specified [rate limits](https://unstats.un.org/wiki/display/comtrade/New+Comtrade+FAQ+for+First+Time+Users#NewComtradeFAQforFirstTimeUsers-Andwhat'sthedownloadcapacityforsubscriptionusers?) which has been taken into account in the pipeline.
However, performing bulk download with a basic individual free subscription is known to infrequently produce `HTTP 500 Internal Server Error`.
To avoid this, UN Comtrade recommends a premium individual or premium institution subscription which allows access to UN Comtrade's bulk API (click [here](https://unstats.un.org/wiki/display/comtrade/New+Comtrade+FAQ+for+First+Time+Users#NewComtradeFAQforFirstTimeUsers-Andwhat'sthedownloadcapacityforsubscriptionusers?) for details on the subscription packages).

The user can prevent these infrequent errors from stopping the full pipeline by setting an environment variable 
```
TARGETS_ERROR="null"
```
Because the Comtrade download pipeline uses dynamic targets branching, this setting allows the pipeline to skip over any failed branches and continue to run subsequent steps using only the data that has been successfully downloaded.
Then, a subsequent call to re-run the pipeline will run the downloads _only_ for the remaining data that have not been downloaded yet.
We recommend re-running the download pipeline at a later time after an `HTTP 500 Internal Server Error` particularly at less busy times (e.g. evenings, weekends).

## Data storage

All raw data from the various data sources are downloaded and then stored before any processing or standardization inside the `data-raw/` directory.

Unless the user has enabled AWS object storage (see Project settings above), all processed data are stored as [qs](https://cran.r-project.org/web/packages/qs/vignettes/vignette.html) files in the `_targets/objects/` directory. 

Data objects can be viewed using the `targets` packages. For example, to view GDP data:

```
targets::tar_read(country_yearly_gdp)
```

Data schemas and descriptions are available as csv files in the `inst/` directory.

-   `inst/data_dictionary_raw.csv` contains schemas for the raw downloaded data files; and,

-   `inst/data_dictionary.csv` contains schemas for the processed data

# Model fitting

Data are aggregated to the yearly time scale, such that we are predicting outbreak probabilities using 12-month windows. For example, we predict disease outbreak probability for Jan-Dec 2022 based on conditions in Jan-Dec 2021. 

The full dataset is randomly split into training (80%) and validation (20%) data. The training data are scaled and used to fit a linear mixed effects model, with random effects for each disease. 

All elements of the model pipeline can be inspected. This may be especially useful to view the model dataset:

```  
targets::tar_read(augmented_livestock_data_aggregated)
```  
Or the model object:

```  
targets::tar_read(repel_model)
```

## Model reports

-   `reports/comparison_repel_models.html` was developed to confirm that our Phase II pipeline can reproduce the dataset and model from the previous Phase I pipeline. Note that to match the Phase I approach, this report represents the Phase II model on the monthly time scale.

-   `reports/repel_model_updates.html` presents model results with a high-level list of the changes that have been made to the model since reproducing the Phase I pipeline.

## Model cache and retraining

The model was trained and validated on data ending in September 2022. This version and associated input data and validation steps are preserved in the  [Data Cache](https://github.com/ecohealthalliance/repel2-battelle/releases/tag/data-cache) GitHub version release. The pipeline can be run with cached data by setting the following environment variable:

```
LIVESTOCK_MODEL_USE_CACHE=TRUE
```

If/when there is a need to refit the model with more recent data, the user can set the maximum training date as an environment variable, with the date in the format yyyy-mm. 

```
LIVESTOCK_MODEL_MAX_TRAINING_DATE="2022-09"
```

To invalidate and refit the model:

1. `tar_invalidate(repel_full_pipeline)` invalidates the full pipeline including the model

2. Set an environment variable to specify that the model should not be pulled from the cache. 

```
LIVESTOCK_MODEL_USE_CACHE=FALSE
```

3. `tar_make(repel_full_pipeline)` refits the model, which takes ~1 hr, and updates predictions and reports.

4. Run the script `inst/cache_data_objects.R` to cache the new data objects. Within the script, you can specify a new GitHub version release to stash the data.

5. Set `LIVESTOCK_MODEL_USE_CACHE` to `TRUE` to prevent the model from refitting when there are future data changes. With this setting, predictions can be updated with new data (see below), but not the model. 

# Model predictions

The target `repel_predictions` provides model predictions for the full dataset, including 12 months ahead from when the data was last updated. 

The target `repel_predictions_priority_diseases_usa` is the output of this function for priority diseases entering the US. 

The target `repel_variable_importance_priority_diseases_usa` contains two data frames pertaining to priority diseases entering the US. `variable_importance` is the importance of each bilateral predictor variable for each month-country-disease prediction. `variable_importance_by_origin` disagreggates the variable importance by outbreak origin countries. 

## Updating model predictions

The model can generate predictions for 12 months ahead from when the data was last updated. To update the data, we suggest the following steps:

1. Make a backup of your existing `data-raw` directory.

2. Create an environmental variable to allow COMTRADE data to be redownloaded. This overrides the default time-saving behavior of skipping over files that have already been downloaded.
```
OVERWRITE_COMTRADE_LIVESTOCK_DOWNLOADED=TRUE
```
3. Run `source("inst/invalidate_livestock_pipeline.R")`. 

4. Set an environment variable for the current month, as follows. This tells the prediction function how far ahead it can make predictions.

```
LIVESTOCK_MODEL_LAST_DATA_UPDATE="2023-12"
```  

5. Run `tar_make(repel_full_pipeline)` to rerun the full data download and processing pipeline. Note this will not refit the model unless the user has `LIVESTOCK_MODEL_USE_CACHE` environment variable set to FALSE (see above). 

### Detecting changes in data sources

The workflow has been setup to detect that the data from source has changed and these steps will re-run. For the Comtrade data and the FAO trade and production data specifically, we have noted that during the period of developing this pipeline these data sources changed field names which caused errors. We have now put in place a check system that will detect these changes and provide a more informative error message regarding this during the data processing step and recommends that data processing functions be updated/refactored to adjust for the new field names. For Comtrade specifically, we have put in place a check in the pipeline that runs prior to the start of the Comtrade download step and provides a warning that Comtrade field names have changed. Because the Comtrade download step takes the most time in the pipeline, the data check doesn't stop the pipeline from performing the download but instead gives the warning in advance to allow for updating/refactoring of functions whilst the download is progressing. For all other data, the same checks are performed in case any change happens but for the most part we expect these to remain the same.
