# Kaplan-Meier Survival Analysis in R

## Overview
This project provides an example for a Kaplan-Meier survival analysis in R, including:
* Data preprocessing
* Kaplan-Meier model fitting
* Visualization of survival curves with confidence intervals
* Display of number-at-risk table <br>
The code is generalized and anonymized so it can be reused for different time-to-event datasets 

## Input Data Format
The input dataset must contain the following columns:

| Column name | Description                                        |
| ----------- | -------------------------------------------------- |
| subject_id  | Unique identifier for each subject                 |
| group       | Group or treatment assignment                      |
| time_days   | Time variable (e.g. days, weeks, etc.)             |
| event       | Event indicator (1 = event occurred, 0 = censored) |

Example:
| subject_id | group | time_days | event |
| ---------- | ----- | --------- | ----- |
| S01        | A     | 10        | 0     |
| S01        | A     | 20        | 1     |
| S02        | B     | 15        | 0     |

## Installation
Make sure the following R packages are installed:
```r
install.packages(c(
  "survival",
  "survminer",
  "dplyr",
  "readxl",
  "ggplot2",
  "ggpubr"
))
```

## Usage
1. Place your dataset in the `data/` folder
2. Adjust the file path in the script if necessary:
```r
input_file <- "data/example_survival_data.xlsx"
```
3. Run the script:
```r
source("scripts/kaplan_meier_analysis.R")
```

## Output
The script generates:
* A Kaplan-Meier survival plot with confidence intervals
* A p-value comparing groups
* A number-at-risk table below the plot

## Data Privacy
This repository uses anonymized example data <br>
No sensitive or experimental-specific identifiers are included.
