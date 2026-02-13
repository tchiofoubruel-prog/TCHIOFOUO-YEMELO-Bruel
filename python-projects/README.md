# Climate Change Impact on Firm Investment in Africa - Master's Thesis Project

## Overview

Complete Python pipeline for a Master's thesis examining how climate anomalies affect firm-level investment decisions across Sub-Saharan Africa. Combines advanced geocoding, spatial climate data extraction, and econometric analysis.

## What This Code Does

### 1. Geocoding Pipeline (Multi-Stage Quality Assurance)
Geocodes 5,000+ firm locations across 40+ African countries using:
- Automated geocoding (Nominatim, Google Maps, OpenCage) with progressive fallback
- Quality control: embassy detection, country verification, encoding correction
- Geospatial validation: geometric boundary checking with country polygons
- Achieves 97%+ accuracy through 7-layer validation

### 2. Data Integration
- Extracts World Bank Enterprise Surveys (WBES) data for Africa
- Parses heterogeneous city fields (multiple cities per cell)
- Normalizes data by "exploding" multi-city entries into separate rows
- Merges firm data with validated geographic coordinates

### 3. Climate Data Extraction & Matching
- Loads CRU TS 4.08 climate data (1901-2023): monthly temperature and precipitation grids
- Calculates baseline climate (1901-1950 average) for each grid cell
- Constructs climate anomalies: `Anomaly = Observed - Baseline`
- Spatially matches each firm (lat/lon) to nearest climate grid cell
- Extracts lagged climate variables (lag 0, 1, 2 years) for ~10,000 firm-year observations

### 4. Variable Construction
Creates econometric dataset with:
- **Dependent variable**: Binary investment indicator (purchased fixed assets: Yes/No)
- **Climate variables**: Temperature and precipitation anomalies (°C, mm) with 0-2 year lags
- **Controls**: Firm size, age, credit access, foreign ownership, manager experience, export status

### 5. Econometric Analysis
Estimates multiple specifications:
- **Logit models** with country-year fixed effects
- **Linear Probability Models (LPM)** for comparison
- **Robustness checks**: Excluding crisis years (2016 El Niño, 2020 COVID)
- Tests distributed lag effects (0, 1, 2 years)
- Generates publication-ready regression tables

## Research Question

**Do temperature and precipitation anomalies affect firms' probability of investing in fixed assets?**

## Technical Highlights

- **Data fusion**: Merges firm surveys, climate grids, and geocoding across 40+ countries and 120+ years
- **Spatial precision**: Firm-level climate matching (not country aggregates)
- **Robust pipeline**: Comprehensive error handling, caching, and validation at each stage
- **Reproducible**: Fully automated workflow from raw data to regression results

## Key Files Produced

| File | Description |
|------|-------------|
| `resultats_geocodage_valide.csv` | Validated firm coordinates |
| `donnees_finales_coordonnees.csv` | Geocoded firm data |
| `donnees_firmes_avec_climat_lags.csv` | Firm data + climate anomalies |
| Regression tables | Coefficient estimates for climate impact on investment |

## Tech Stack

**Python**: pandas • geopandas • xarray • geopy • osmnx • statsmodels • matplotlib

**Data**: WBES (World Bank) • CRU TS 4.08 (climate) • OpenStreetMap (boundaries)

## Applications

- Climate adaptation strategies for African firms
- Investment vulnerability to environmental shocks
- Policy design for climate-affected enterprises
- Firm-level climate risk assessment

## Author

Tchiofouo Yemelo Bruel | Master's Thesis | Development Economics & Climate Economics

