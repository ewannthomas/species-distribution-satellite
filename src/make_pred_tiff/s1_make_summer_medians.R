library(terra)
library(stringr)

#defining precition tif
tiff_path_root = paste0("./data/test/sentinel_1/summer")
tiffs <- list.files(tiff_path_root, pattern = "*.tif$", full.names = TRUE, recursive = TRUE)

summer_median_path = "./data/prediction_tiff/medians/sentinel_1/summer_median.tif"


# Reading in the tiffs
ascending_tiffs <- tiffs[grepl("Ascending", tiffs)]
descending_tiffs <- tiffs[grepl("Descending", tiffs)]

ascending_tiffs
descending_tiffs

### Ascending
vh_Ascending = rast(ascending_tiffs[1:3])
vv_Ascending = rast(ascending_tiffs[4:6])
### Descending
vh_Descending = rast(descending_tiffs[1:3])
vv_Descending = rast(descending_tiffs[4:6])


#making indices
######
#Ascending calculations
VV_VH_A <- vv_Ascending / vh_Ascending
VH_VV_A <- vh_Ascending / vv_Ascending
SAR_NDVI_A <- (vh_Ascending - vv_Ascending) / (vh_Ascending + vv_Ascending)
DVI_A <- vh_Ascending - vv_Ascending
SVI_A <- vh_Ascending + vv_Ascending
RDVI_A <- VH_VV_A - VV_VH_A
NRDVI_A <- RDVI_A /(VH_VV_A + VV_VH_A)
SSDVI_A <- vh_Ascending^2 - vv_Ascending^2

#Descending calculations
VV_VH_D <- vv_Descending / vh_Descending
VH_VV_D <- vh_Descending / vv_Descending
SAR_NDVI_D <- (vh_Descending - vv_Descending) / (vh_Descending + vv_Descending)
DVI_D <- vh_Descending - vv_Descending
SVI_D <- vh_Descending + vv_Descending
RDVI_D <- VH_VV_D - VV_VH_D
NRDVI_D <- RDVI_D /(VH_VV_D + VV_VH_D)
SSDVI_D <- vh_Descending^2 - vv_Descending^2


#taking medians of indices
#####
# Ascending medians
vh_Ascendingsummer <- app(vh_Ascending, fun = median, na.rm = TRUE)
vv_Ascendingsummer <- app(vv_Ascending, fun = median, na.rm = TRUE)
VV_VH_Asummer <- app(VV_VH_A, fun = median, na.rm = TRUE)
VH_VV_Asummer <- app(VH_VV_A, fun = median, na.rm = TRUE)
SAR_NDVI_Asummer <- app(SAR_NDVI_A, fun = median, na.rm = TRUE)
DVI_Asummer <- app(DVI_A, fun = median, na.rm = TRUE)
SVI_Asummer <- app(SVI_A, fun = median, na.rm = TRUE)
RDVI_Asummer <- app(RDVI_A, fun = median, na.rm = TRUE)
NRDVI_Asummer <- app(NRDVI_A, fun = median, na.rm = TRUE)
SSDVI_Asummer <- app(SSDVI_A, fun = median, na.rm = TRUE)

#Descending Median
vh_Descendingsummer <- app(vh_Descending, fun = median, na.rm = TRUE)
vv_Descendingsummer <- app(vv_Descending, fun = median, na.rm = TRUE)
VV_VH_Dsummer <- app(VV_VH_D, fun = median, na.rm = TRUE)
VH_VV_Dsummer <- app(VH_VV_D, fun = median, na.rm = TRUE)
SAR_NDVI_Dsummer <- app(SAR_NDVI_D, fun = median, na.rm = TRUE)
DVI_Dsummer <- app(DVI_D, fun = median, na.rm = TRUE)
SVI_Dsummer <- app(SVI_D, fun = median, na.rm = TRUE)
RDVI_Dsummer <- app(RDVI_D, fun = median, na.rm = TRUE)
NRDVI_Dsummer <- app(NRDVI_D, fun = median, na.rm = TRUE)
SSDVI_Dsummer <- app(SSDVI_D, fun = median, na.rm = TRUE)


sent1_summer_medians = c(vv_Descendingsummer,vh_Descendingsummer, vv_Ascendingsummer,vh_Ascendingsummer,
          VV_VH_Asummer, VV_VH_Dsummer, VH_VV_Asummer,VH_VV_Dsummer,
            SAR_NDVI_Asummer, SAR_NDVI_Dsummer, DVI_Asummer, DVI_Dsummer,  SVI_Asummer, 
            SVI_Dsummer, RDVI_Asummer, RDVI_Dsummer, NRDVI_Asummer, NRDVI_Dsummer,  SSDVI_Asummer, 
            SSDVI_Dsummer)

tiff_names = c('vv_Descendingsummer','vh_Descendingsummer', 'vv_Ascendingsummer','vh_Ascendingsummer',
               'VV_VH_Asummer', 'VV_VH_Dsummer', 'VH_VV_Asummer','VH_VV_Dsummer',
               'SAR_NDVI_Asummer', 'SAR_NDVI_Dsummer', 'DVI_Asummer', 'DVI_Dsummer',  'SVI_Asummer', 
               'SVI_Dsummer', 'RDVI_Asummer', 'RDVI_Dsummer', 'NRDVI_Asummer', 'NRDVI_Dsummer',  'SSDVI_Asummer', 
               'SSDVI_Dsummer')


names(sent1_summer_medians) <- tiff_names
varnames(sent1_summer_medians) <- tiff_names


# checking values
#removing Inf values arriving from division by 0 over bands
for (i in 1:20){
  print("*********************************")
  print(i)
  print(sent1_summer_medians[[i]])
}

# Normalizing across each layer of the brick 
for (i in 1:nlyr(sent1_summer_medians)) {
  print("*********************************************")
  print(sent1_summer_medians[[i]])
  layer <- sent1_summer_medians[[i]]   
  layer_min <- terra::minmax(sent1_summer_medians[[i]])[[1]]  
  layer_max <- terra::minmax(sent1_summer_medians[[i]])[[2]]   
  normalized_layer <- (layer - layer_min) / (layer_max - layer_min)   
  sent1_summer_medians[[i]] <- normalized_layer
  print("-----------------------")
  print(sent1_summer_medians[[i]])  
}

writeRaster(sent1_summer_medians, summer_median_path)
