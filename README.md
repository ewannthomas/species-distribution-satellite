# SPECIES DISTRIBUTION MODELLING
The species distribution modelling is an ongoing collaborative research between Indian School of Business and Government of Himachal Pradesh. It attempts to make spatial predictions of 14 tree species using point based presence only data. The model framework is unsupervised classification. We incorporate random forest and XG-Boost models, along with robustness checks stemming from Generalized Linear Models (GLM).

### DATA
- Sentinel 1  

    The Sentinel-1 C Band Synthetic Aperture Radar Ground Range Detected is a global log scaled, derived product from the Sentinel 1 mission. The bands VV - Single co-polarization, vertical transmit/vertical receive and VH - Dual-band cross-polarization, vertical transmit/horizontal receive have been used for feature generation. Both VV and VH have 10 meters resolution and the collection is updated daily.  

- Sentinel 2  

    The Harmonized Sentinel-2 Multispectral Instrument, Level-2A is a global product which provides a set of 12 scaled surface reflectance bands. The bands B2, B3, B4, B8 were incorporated in the feature generation process. The tiles were extracted at 10 meters resolution. The tiles were filtered for less than 10% cloud coverage.  

SAR and Sentinel 2 tiles pertaining to 2018 to 2024 were extracted from Copernicus browser and monthly medians were computed and supplied in the spatial random forest model.  
