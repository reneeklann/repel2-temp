---
title: Repel Model Updates
author: Ernest Guevarra, Emma Mendelsohn and Noam Ross, EcoHealth Alliance
date: "2024-04-29"
output: 
  rmarkdown::html_document:
    toc: true
    keep_md: true
---



This report provides a quick side-by-side comparison for updates to the REPEL model. 
The document "repel_model_updates.Rmd" contains the stand-alone latest results and is updated as part of the targets pipeline.
Because of the reliance on `relic` and locally-archived versions of our models, this document needs to be run manually outside of our targets pipeline.

The following changes are reflected here. We're starting with our yearly recalibration as the baseline for assessing performance changes. 
1. We shifted the model to a yearly time interval ("baseline")
2. Removed non-livestock related commodities from the Comtrade dataset ("comtrade_prune")




### Confusion Matrix

Model predictions are in the form of probabilities from 0-1.
We assumed that a prediction of \>= 0.5 indicates that the model predicted an outbreak event.

While confusion matrices and their summary statistics are standard metrics for binary models, they are limited for evaluating this model, which predicts rare events that generally have a probability well below 0.5.
Metrics which weight negative events reflect the large number of zeroes in the dataset.
Metrics focusing only on rare outbreak events (Kappa, Negative Predictive Value, Matthews correlation coefficient) reflect performance in very small number of cases where monthly import risk is above 50%.
Calibration curves (next section) provide a better measure of rare events.

<img src="repel_model_iterative_comparison_checks_files/figure-html/unnamed-chunk-2-1.png" width="50%" /><img src="repel_model_iterative_comparison_checks_files/figure-html/unnamed-chunk-2-2.png" width="50%" />

<table class=" lightable-paper" style='font-family: "Arial Narrow", arial, helvetica, sans-serif; width: auto !important; '>
 <thead>
  <tr>
   <th style="text-align:left;"> .metric </th>
   <th style="text-align:left;"> .estimator </th>
   <th style="text-align:right;"> baseline </th>
   <th style="text-align:right;"> comtrade_prune </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> accuracy </td>
   <td style="text-align:left;"> binary </td>
   <td style="text-align:right;"> 0.9860439 </td>
   <td style="text-align:right;"> 0.9863640 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> kap </td>
   <td style="text-align:left;"> binary </td>
   <td style="text-align:right;"> 0.1000323 </td>
   <td style="text-align:right;"> 0.1024157 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sens </td>
   <td style="text-align:left;"> binary </td>
   <td style="text-align:right;"> 0.9940090 </td>
   <td style="text-align:right;"> 0.9941000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> spec </td>
   <td style="text-align:left;"> binary </td>
   <td style="text-align:right;"> 0.0943775 </td>
   <td style="text-align:right;"> 0.0969072 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ppv </td>
   <td style="text-align:left;"> binary </td>
   <td style="text-align:right;"> 0.9919273 </td>
   <td style="text-align:right;"> 0.9921607 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> npv </td>
   <td style="text-align:left;"> binary </td>
   <td style="text-align:right;"> 0.1233596 </td>
   <td style="text-align:right;"> 0.1250000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> mcc </td>
   <td style="text-align:left;"> binary </td>
   <td style="text-align:right;"> 0.1009445 </td>
   <td style="text-align:right;"> 0.1032592 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> j_index </td>
   <td style="text-align:left;"> binary </td>
   <td style="text-align:right;"> 0.0883865 </td>
   <td style="text-align:right;"> 0.0910072 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> bal_accuracy </td>
   <td style="text-align:left;"> binary </td>
   <td style="text-align:right;"> 0.5441932 </td>
   <td style="text-align:right;"> 0.5455036 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> detection_prevalence </td>
   <td style="text-align:left;"> binary </td>
   <td style="text-align:right;"> 0.9932264 </td>
   <td style="text-align:right;"> 0.9933153 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> precision </td>
   <td style="text-align:left;"> binary </td>
   <td style="text-align:right;"> 0.9919273 </td>
   <td style="text-align:right;"> 0.9921607 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> recall </td>
   <td style="text-align:left;"> binary </td>
   <td style="text-align:right;"> 0.9940090 </td>
   <td style="text-align:right;"> 0.9941000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> f_meas </td>
   <td style="text-align:left;"> binary </td>
   <td style="text-align:right;"> 0.9929670 </td>
   <td style="text-align:right;"> 0.9931294 </td>
  </tr>
</tbody>
</table>

<!-- ``` -->

### Calibration Curve

We assessed model predictions as probabilities against observed outbreak rates in the validation set.
We grouped predictions into 30 quantile-based bins.
We compared the average prediction of each bin to observed outbreak rates within the bin (represented as binomial probabilities and 95% confidence intervals).
Each prediction represents the expectation of an outbreak of a given disease in a country in a given month.
This assessment evaluates the reliability of predictions for rare events: given a predicted probability of a rare outbreak, how well is that probability borne out as a fraction of times that outbreaks actually occurred in the validation data?



<table class=" lightable-paper" style='font-family: "Arial Narrow", arial, helvetica, sans-serif; width: auto !important; '>
<caption>values are per 10,000 potential events</caption>
 <thead>
  <tr>
   <th style="text-align:right;"> Bin </th>
   <th style="text-align:left;"> baseline bins within 95% CI: 28 </th>
   <th style="text-align:left;"> comtrade_prune bins within 95% CI: 27 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> no </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:left;"> no </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> no </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 11 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 12 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 13 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 14 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 15 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 16 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 17 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 18 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 19 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 20 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 21 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 23 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 25 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 26 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 27 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 28 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 29 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 30 </td>
   <td style="text-align:left;"> no </td>
   <td style="text-align:left;"> no </td>
  </tr>
</tbody>
</table>


### Coefficients
This looks at the distribution of random effects (coefficients) for each variable. There is a random effect for each disease for each variable. 

Note: Our model does not include fixed effects for each variable, only random effects by disease. `randef(mod)` returns individual slopes by disease, which _can_ be interpreted as slopes (positive or negative relationships, magnitude of effect). These slopes are drawn from a normal distribution. If we had included a fixed effect for the variables, the random effect slopes would be offsets that you add to the fixed effect slope.

So, variables with higher magnitudes of effects (either positive or negative) have a greater overall effect on the probability of disease outbreak. Coefficients around 0 do not predict disease outbreak.   

The relationship between GDP and outbreak probability is positive for almost all diseases. For some diseases, that slope is highly positive.

The relationship between each continent and outbreak probability can be positive or negative, depending on the disease. And the effects can be steep in either direction. This makes sense, as some diseases are going to be highly associated with a given continent.

The magnitude of the effect of comtrade and FAO is low overall. 

![](repel_model_iterative_comparison_checks_files/figure-html/unnamed-chunk-6-1.png)<!-- -->


### Variable Importance
Variable importance is calculated as the coefficient (random effect) for each disease-variable combination _times_ the value for that variable. 

This shows random effects for a subset of our dataset - import of priority diseases into USA in 2022. It does not represent overall variable importance, which we can calculate by summarizing over all years, countries, diseases in the full dataset. 

![](repel_model_iterative_comparison_checks_files/figure-html/unnamed-chunk-7-1.png)<!-- -->


<details>
<summary>Session info</summary>

-   Built at: 2024-04-29 13:09:08.301831
-   Last git commit hash: d834ef04db7dc58a8770d45386b832f4dbd77841

</details>

