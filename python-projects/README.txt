All necessary data and scripts for execution are located in the **data&script** folder.



********************************************************************************************************************************************************************************************
**Extraction of Mines' Geographical Coordinates via Web Scraping** (script_title: Extraction des coordonnées géographiques des mines)

********************************************************************************************************************************************************************************************

We have a database containing monthly production data from various mines. The primary objective of the first script, titled **"Extraction of the Geographical Coordinates of Mines,"** is to identify the location of these mines based on the available information.

The process begins with a **data preparation** phase, which involves reading an Excel file containing production values and converting the data format from wide to long (panel). This transformation facilitates the longitudinal analysis of mining production. Next, a **data cleaning** phase is carried out, including the conversion of numeric fields—often stored as strings—and the removal of irrelevant entries.

The next step is the **extraction of the geographical coordinates of the mines**. This extraction relies on a web scraping procedure applied to publicly available KML files. These files contain latitude and longitude information for various mining sites. After downloading the KML files, their content is analyzed to extract precise coordinates, which are then linked to the mines in a DataFrame.

Once the geographical data has been extracted, we proceed with **database integration**. This involves unifying the monthly production data—now in long format—with the dataset containing the geographical positions of the sites. This integration requires strict alignment of mine names and verification of identifier consistency. Removing duplicates and resolving any discrepancies ensure the reliability of the merged data.

To ensure the smooth operation of this workflow, several libraries are used, including **pandas** for data manipulation, **requests** for downloading KML files, **xml.etree.ElementTree** for parsing XML/KML files, and **folium** for visualizing mining sites on an interactive map. Once the integration is complete, a final Excel file is generated and can be used for further analysis.


********************************************************************************************************************************************************************************************
**Generation of a Fine (10 km) Grid and Conversion to Shapefile** (script_title: Generation of a Fine (10 km) Grid and Conversion to Shapefile )
********************************************************************************************************************************************************************************************

The data used in this process comes from a KML file containing large polygons (5° × 5°) obtained from the Climate Research Unit Data website. However, for better precision, a finer grid of **0.1° × 0.1°** (approximately 10 km × 10 km) is generated. The methodology starts with loading the KML file using **Geopandas**, which enables access to the large polygons and their geographic boundaries. The script extracts the minimum and maximum latitude and longitude of each polygon and then subdivides each large cell into multiple smaller cells, each measuring **0.1° × 0.1°**. These smaller polygons are aggregated into a **GeoDataFrame**, preserving the original coordinate reference system (**EPSG:4326**).

Once the finer grid is generated, the script exports it as a **KML file** to facilitate visualization in tools like Google Earth. This allows users to inspect the newly created sub-cells before further processing. The next step involves converting the refined grid from KML format into a **Shapefile (SHP)** using the `to_file(...)` method in **Geopandas**, ensuring compatibility with a wide range of GIS applications.

Despite its advantages, some considerations must be taken into account when using this fine grid. Since the **EPSG:4326** coordinate system is based on geographic latitude and longitude, the actual size of the **0.1° × 0.1°** cells varies with latitude, meaning they only approximate 10 km × 10 km. Additionally, reducing the grid size even further to enhance precision would significantly increase the number of polygons, leading to higher memory usage and longer processing times.

The script relies on several key **Python libraries** to ensure smooth execution. **Geopandas** is used for handling geospatial data, while **Shapely** enables geometric operations such as defining and subdividing polygons. **Fiona** is also employed to support multiple GIS file formats, including KML and Shapefile. By integrating these tools, the script provides an efficient way to generate a high-resolution spatial grid that can be used for detailed geographic analysis.


********************************************************************************************************************************************************************************************
**Extraction and Processing of Historical Climate Data for Geolocated Mining Sites** (script_title: mine_climate_data_monthly_1901_2023_pre and temp; script_title: mine_climate_cld_dtr_frs_pet_1901_2023; script_title:mine_climate_tmn_tmx_vap_wet_1901_2023)
********************************************************************************************************************************************************************************************

This document presents a comprehensive process for extracting and processing historical climate data (precipitation, temperature, cloud cover, diurnal temperature range (DTR), frost days, potential evapotranspiration (PET), minimum and maximum temperatures, vapor pressure, and wet days) from NetCDF files, while linking them to geolocated mining sites. The climate data, sourced from the CRU TS4.08 database, span the period from 1901 to 2023 and encompass monthly information on precipitation, temperature, cloud cover, diurnal temperature range (DTR), frost days, potential evapotranspiration (PET), minimum and maximum temperatures, vapor pressure, and wet days.

The construction of the database begins with data preparation, relying on various Python libraries. On one hand, xarray and rioxarray are employed to load NetCDF files and select the required variables. On the other hand, the coordinates of the mining sites—extracted from an Excel file—are converted into a GeoDataFrame to facilitate spatial matching with the climate grid.

Spatial matching utilizes the capabilities of GeoPandas, particularly the spatial join function, which links each mining site to the corresponding climate grid cell. This grid was subdivided into finer cells (0.1°×0.1°), compared to its original resolution of 5°×5°, thereby enhancing matching accuracy.

Monthly extraction of climate variables for each site is carried out using zonal statistics methods (rasterstats) applied to each mining location. The resulting data are then aggregated and structured into a monthly dataset (in YYYY-MM format). Temporary files (rasters) are automatically deleted to reduce storage overhead.

At the end of this process, a comprehensive CSV file (1901–2023) lists monthly precipitation and temperatures, while a second file records cloud cover, diurnal temperature range (DTR), frost days, and potential evapotranspiration (PET), and a third file enumerates minimum and maximum temperatures, vapor pressure, and wet days for each site. In parallel, a DataFrame is available for any subsequent analytical work. The principal libraries employed—xarray, geopandas, rasterstats, pandas, and shapely—are indispensable for data manipulation, structuring, and integration into a spatial and econometric analysis framework.

********************************************************************************************************************************************************************************************
**Monthly Climate Anomaly Calculation and Integration (1901–2023) into Mining Production** (script_title: Monthly Climate Anomaly Calculation and Integration (1901–2023) into Mining Production)
********************************************************************************************************************************************************************************************

This text outlines a procedure for calculating monthly climate anomalies and integrating them into a mining production database, covering the period from 1901 to 2023. The primary challenge lies in harmonizing various data sources (climate and mining), ensuring consistency in date formats, and computing anomalies based on a reference period (1901–1950). By drawing on a set of CSV and Excel files, the methodology details the steps involved in temporal filtering and merging, with the ultimate objective of producing a panel dataset ready for econometric analysis.

The initial phase underscores the importance of preparing climate data, particularly converting it into a uniform (YYYY-MM) format and extracting variables such as Temp_Min, Temp_Max, and Precipitation. Harmonizing the spatial coordinates (latitude, longitude) ensures that mining production data can be accurately matched to the corresponding monthly climate measures. The text also highlights the necessity of a precise reference period (1901–1950): for each mine and each month, the difference between the current value and the historical mean for that month is computed, yielding the climate anomaly.

The merging stage consolidates the anomaly history and production indicators (extraction volume, prices) into a single dataset. Joins are performed on columns (Mine, Latitude, Longitude, Date) to preserve consistency across the different databases. In addition, temporal filtering can be applied to focus on a specific timespan, such as 2003–2023. Enforcing quality rules (removal of invalid coordinates, UTF-8 encoding, date verification) enhances the reliability of the resulting dataset. During this step, the procedure also integrates price and export data to maintain a single comprehensive database.


*************************************************************************
Final Data Requirement for Execution
*************************************************************************
To execute the provided scripts, only the final dataset is required. This dataset consolidates all necessary information, including mine production data, geographical coordinates, climate variables, and computed anomalies. No additional preprocessing is needed, as all scripts are designed to operate directly with this dataset.

All required Python packages are already installed and available within the accompanying Jupyter notebook. Therefore, users can proceed directly with execution without concern for package dependencies.
