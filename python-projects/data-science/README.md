# Data Science: Mine Production, Climate, and Forecasting

Six notebooks that build a geolocated mining production panel enriched with historical climate data, followed by a machine learning stage that forecasts production from the resulting panel.

## Pipeline (`Extraction/`)

### 1. Extraction of mines' geographical coordinates
`01_extract_mine_coordinates.ipynb`

Starts from a database of monthly mine production values, reshapes it from wide to long (panel) format, and cleans numeric fields stored as strings. Mine locations are then identified through a web scraping procedure applied to publicly available KML files, which are parsed for latitude and longitude and linked back to each mine. The production panel and the geographic positions are merged, with duplicate removal and identifier checks to keep the match reliable. Libraries: pandas, requests, xml.etree.ElementTree, folium.

### 2. Fine grid generation
`02_generate_fine_grid.ipynb`

Starts from large 5 degree by 5 degree polygons (Climate Research Unit) and subdivides them into a finer 0.1 degree by 0.1 degree grid (approximately 10 km by 10 km), exported as both KML (for inspection in tools like Google Earth) and Shapefile. Because EPSG:4326 is a geographic coordinate system, actual cell size varies with latitude, so the 10 km figure is an approximation, not an exact grid spacing. Libraries: geopandas, shapely, fiona.

### 3. Historical climate extraction
`03c_climate_cld_dtr_frs_pet_1901_2023.ipynb`, `03b_climate_tmn_tmx_vap_wet_1901_2023.ipynb`, `03a_climate_pre_tmp_1901_2023.ipynb`

Extracts monthly climate variables (precipitation, temperature, cloud cover, diurnal temperature range, frost days, potential evapotranspiration, minimum and maximum temperature, vapor pressure, wet days) from CRU TS4.08 NetCDF files, spatially joins them to the fine grid built in step 2, and applies zonal statistics to assign a monthly climate value to each mine location. Output is three CSV files (1901 to 2023), split by variable group. Libraries: xarray, rioxarray, geopandas, rasterstats.

### 4. Climate anomaly integration
`04_climate_anomalies_integration.ipynb`

Computes monthly climate anomalies relative to a 1901 to 1950 reference period, then merges the anomaly series with the mine production panel (extraction volume, prices) on mine, latitude, longitude, and date. Includes temporal filtering to a target window (for example 2003 to 2023) and basic quality checks (coordinate validity, encoding, date consistency).

### 5. Stylized facts
`05_stylized_facts.ipynb`

Descriptive analysis of the constructed panel.

## Modeling (`MachineLearning/`)

Forecasting stage applied to the panel built above: SARIMAX for the time series component, linear/ridge/lasso regression as baselines, Random Forest and XGBoost for the ensemble models, with SHAP used for feature attribution. Notebooks are numbered `00` through `03` in pipeline order (treatment, SARIMAX, linear models, ensemble models).

## Data

The notebooks expect a single consolidated dataset (mine production, coordinates, climate variables, and computed anomalies) as input; this file is not included in the repository. See the root README's data governance note.

## Requirements

See `requirements.txt` at the repository root.

## Provenance and execution environment

All notebooks in this repository are my own work. Parts of the pipeline were originally executed on a different machine than my own during the M2 thesis period, which is why early versions contained absolute paths from that environment. All paths now follow the repository convention (`./data` for inputs); see the data note in the root README.
