library(terra)
library(stringr)

#defining precition tif
tiff_path_root = paste0("./data/test/sentinel_1/winter")
tiffs <- list.files(tiff_path_root, pattern = "*.tif$", full.names = TRUE, recursive = TRUE)

winter_median_path = "./data/prediction_tiff/medians/sentinel_1/winter_median.tif"


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
vh_Ascendingwinter <- app(vh_Ascending, fun = median, na.rm = TRUE)
vv_Ascendingwinter <- app(vv_Ascending, fun = median, na.rm = TRUE)
VV_VH_Awinter <- app(VV_VH_A, fun = median, na.rm = TRUE)
VH_VV_Awinter <- app(VH_VV_A, fun = median, na.rm = TRUE)
SAR_NDVI_Awinter <- app(SAR_NDVI_A, fun = median, na.rm = TRUE)
DVI_Awinter <- app(DVI_A, fun = median, na.rm = TRUE)
SVI_Awinter <- app(SVI_A, fun = median, na.rm = TRUE)
RDVI_Awinter <- app(RDVI_A, fun = median, na.rm = TRUE)
NRDVI_Awinter <- app(NRDVI_A, fun = median, na.rm = TRUE)
SSDVI_Awinter <- app(SSDVI_A, fun = median, na.rm = TRUE)

#Descending Median
vh_Descendingwinter <- app(vh_Descending, fun = median, na.rm = TRUE)
vv_Descendingwinter <- app(vv_Descending, fun = median, na.rm = TRUE)
VV_VH_Dwinter <- app(VV_VH_D, fun = median, na.rm = TRUE)
VH_VV_Dwinter <- app(VH_VV_D, fun = median, na.rm = TRUE)
SAR_NDVI_Dwinter <- app(SAR_NDVI_D, fun = median, na.rm = TRUE)
DVI_Dwinter <- app(DVI_D, fun = median, na.rm = TRUE)
SVI_Dwinter <- app(SVI_D, fun = median, na.rm = TRUE)
RDVI_Dwinter <- app(RDVI_D, fun = median, na.rm = TRUE)
NRDVI_Dwinter <- app(NRDVI_D, fun = median, na.rm = TRUE)
SSDVI_Dwinter <- app(SSDVI_D, fun = median, na.rm = TRUE)


sent1_winter_medians = c(vv_Descendingwinter,vh_Descendingwinter, vv_Ascendingwinter,vh_Ascendingwinter,
                         VV_VH_Awinter, VV_VH_Dwinter, VH_VV_Awinter,VH_VV_Dwinter,
                         SAR_NDVI_Awinter, SAR_NDVI_Dwinter, DVI_Awinter, DVI_Dwinter,  SVI_Awinter, 
                         SVI_Dwinter, RDVI_Awinter, RDVI_Dwinter, NRDVI_Awinter, NRDVI_Dwinter,  SSDVI_Awinter, 
                         SSDVI_Dwinter)

tiff_names = c('vv_Descendingwinter','vh_Descendingwinter', 'vv_Ascendingwinter','vh_Ascendingwinter',
               'VV_VH_Awinter', 'VV_VH_Dwinter', 'VH_VV_Awinter','VH_VV_Dwinter',
               'SAR_NDVI_Awinter', 'SAR_NDVI_Dwinter', 'DVI_Awinter', 'DVI_Dwinter',  'SVI_Awinter', 
               'SVI_Dwinter', 'RDVI_Awinter', 'RDVI_Dwinter', 'NRDVI_Awinter', 'NRDVI_Dwinter',  'SSDVI_Awinter', 
               'SSDVI_Dwinter')


names(sent1_winter_medians) <- tiff_names
varnames(sent1_winter_medians) <- tiff_names


# checking values
#removing Inf values arriving from division by 0 over bands
for (i in 1:20){
  print("*********************************")
  print(i)
  print(sent1_winter_medians[[i]])
}

# Normalizing across each layer of the brick 
for (i in 1:nlyr(sent1_winter_medians)) {
  print("*********************************************")
  print(sent1_winter_medians[[i]])
  layer <- sent1_winter_medians[[i]]   
  layer_min <- terra::minmax(sent1_winter_medians[[i]])[[1]]  
  layer_max <- terra::minmax(sent1_winter_medians[[i]])[[2]]   
  normalized_layer <- (layer - layer_min) / (layer_max - layer_min)   
  sent1_winter_medians[[i]] <- normalized_layer
  print("-----------------------")
  print(sent1_winter_medians[[i]])  
}

writeRaster(sent1_winter_medians, winter_median_path)
