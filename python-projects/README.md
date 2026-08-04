# Python Projects

## `data-science/`
Geospatial data construction and machine learning forecasting for a mining production panel. See `data-science/README.md` for the full pipeline description (six notebooks, from geolocation extraction through anomaly integration) and `data-science/MachineLearning/` for the modeling stage (SARIMAX, linear/ridge/lasso, Random Forest, XGBoost, SHAP).

## `geocoding-cities/`
City-name geocoding via Nominatim/OpenStreetMap, cleaning and enriching coordinates for a list of cities read from an Excel file, with a second pass that retries failed lookups. Originally a duplicate file between this repository and `Research-Assistant-Sample-Codes`; kept here as the single copy.

## Requirements

See `requirements.txt` at the repository root. Core dependencies: pandas, numpy, geopandas, rioxarray, xarray, rasterstats, shapely, scikit-learn, statsmodels, xgboost, shap, matplotlib, seaborn.
