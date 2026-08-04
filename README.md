# Applied Econometrics and Machine Learning

Applied economics code: econometric replications in Stata, reproducible analyses in R Markdown, and Python notebooks combining geospatial data construction with machine learning forecasting. Written as coursework, research assistant work, and independent replication exercises between 2023 and 2025.

## Contents

### `stata-projects/`
Five self-contained projects, each in its own folder with a short README describing the data and method.

| Folder | Method | Topic |
|---|---|---|
| `impact-evaluation-methods/` | RCT, RDD, DiD, PSM, IV | Replication of published impact evaluation methods |
| `panel-data-econometrics/` | Fixed effects, random effects, Hausman test, dynamic panel | Technology and income inequality, World Bank WDI panel (1993 to 2022) |
| `survey-data-analysis/` | Sampling weights, stratification, post-stratification | Household survey methodology, Albania LSMS |
| `household-survey-rwanda/` | Data cleaning, consumption aggregation | Rwanda LWH agricultural household follow-up survey |
| `education-rct-analysis/` | Balance tests, treatment effects, heterogeneity | School-level randomized subsidy program (2010 to 2012) |
| `econometrics-course-2024/` | Applied Stata exercise | Coursework sample, CERDI Econométrie 2024 |

### `r-projects/`
| Folder | Method | Topic |
|---|---|---|
| `food-security-mali/` | Descriptive statistics, food insecurity indicators | Food Insecurity Experience Scale, Mali |
| `pca-environment/` | Principal component analysis, dimensionality reduction | Environmental data |
| `analyse-pauvrete/` | Poverty analysis and reporting | (see in-folder script) |

### `python-projects/`
| Folder | Method | Topic |
|---|---|---|
| `data-science/Extraction/` | Web scraping, geospatial joins, NetCDF processing | Mine geolocation and historical climate data construction (CRU TS4.08, 1901 to 2023) |
| `data-science/MachineLearning/` | SARIMAX, linear/ridge/lasso regression, Random Forest, XGBoost, SHAP | Forecasting mining production from the constructed climate panel |
| `geocoding-cities/` | Geocoding via Nominatim/OpenStreetMap | City coordinate lookup and cleanup from an Excel city list |

## Data

Source data is not included in this repository. Several projects use survey or institutional data (World Bank WDI, Albania LSMS, Rwanda LWH follow-up survey, CRU climate data) that belongs to third-party institutions and cannot be redistributed here. Only the analysis scripts are shared. Scripts reference a relative `./data` path; point it at your own copy of the source data to reproduce the analysis.

## Requirements

Python dependencies are listed in `requirements.txt` at the repository root. Stata scripts require Stata 16 or later. R Markdown files require the packages listed at the top of each `.Rmd`.

## License

Code is released under the MIT License (see `LICENSE`). This applies to the analysis code only, not to any third-party data referenced above.
