library(terra)

#defining precition tif
tiff_path_root = paste0("./data/prediction_tiff/pred_bricks")
tiffs <- list.files(tiff_path_root, pattern = "*/*/*.tif", full.names = TRUE, recursive = TRUE)

#hp_state_bound_buffer path
hp_buffer_path = "./data/shapes/hp_buffer/hp_buffer.shp"
hp = vect(hp_buffer_path)

#Calling in the pred bricks
covar = rast(tiffs[[1]])
sent1 = rast(tiffs[[2]])
sent2 = rast(tiffs[[3]])

#setting HP buffer extent for sent 1, sent 2 and covar
ext(sent1) <- ext(hp)
ext(sent2) <- ext(hp)
ext(covar) <- ext(hp)

# resampling covar to sentinel dimensions
covar <- resample(covar, sent1)


# Stacking
pred_stack <- c(sent1, sent2, covar)


#reordering the features
feature_order = c('vv_Descendingsummer',
                  'vv_Descendingwinter', 'vh_Descendingsummer', 'vh_Descendingwinter',
                  'vv_Ascendingsummer', 'vv_Ascendingwinter', 'vh_Ascendingsummer',
                  'vh_Ascendingwinter', 'VV_VH_Asummer', 'VV_VH_Awinter', 'VV_VH_Dsummer',
                  'VV_VH_Dwinter', 'VH_VV_Asummer', 'VH_VV_Awinter', 'VH_VV_Dsummer',
                  'VH_VV_Dwinter', 'SAR_NDVI_Asummer', 'SAR_NDVI_Awinter',
                  'SAR_NDVI_Dsummer', 'SAR_NDVI_Dwinter', 'DVI_Asummer', 'DVI_Awinter',
                  'DVI_Dsummer', 'DVI_Dwinter', 'SVI_Asummer', 'SVI_Awinter',
                  'SVI_Dsummer', 'SVI_Dwinter', 'RDVI_Asummer', 'RDVI_Awinter',
                  'RDVI_Dsummer', 'RDVI_Dwinter', 'NRDVI_Asummer', 'NRDVI_Awinter',
                  'NRDVI_Dsummer', 'NRDVI_Dwinter', 'SSDVI_Asummer', 'SSDVI_Awinter',
                  'SSDVI_Dsummer', 'SSDVI_Dwinter', 'B11summer', 'B11winter', 'B02summer',
                  'B02winter', 'B12summer', 'B12winter', 'B08summer', 'B08winter',
                  'B04summer', 'B04winter', 'B03summer', 'B03winter', 'NDVIsummer',
                  'NDVIwinter', 'ARVI2summer', 'ARVI2winter', 'BWDRVIsummer',
                  'BWDRVIwinter', 'CVIsummer', 'CVIwinter', 'CTVIsummer', 'CTVIwinter',
                  'EVI2summer', 'EVI2winter', 'GVMIsummer', 'GVMIwinter',
                  'MSVAIhypersummer', 'MSVAIhyperwinter', 'MTVI2summer', 'MTVI2winter',
                  'MNDVIsummer', 'MNDVIwinter', 'OSAVIsummer', 'OSAVIwinter', 'PVIsummer',
                  'PVIwinter', 'SARVIsummer', 'SARVIwinter', 'SLAVIsummer', 'SLAVIwinter',
                  'TSAVI2summer', 'TSAVI2winter', 'WDVIsummer', 'WDVIwinter',
                  'WDRVIsummer', 'WDRVIwinter', 'sand_f', 'elevation', 'cfvo_f',
                  'phh2o_f', 'soc_f', 'slope', 'clay_f', 'nitrogen_f', 'cec_f', 'bdod_f', 
                  'aspect', 'silt_f', 'ocd_f')


pred_stack <- pred_stack[[feature_order]]

#writing the prediction raster
writeRaster(pred_stack, "./data/prediction_tiff/pred_stack.tif")

# #Removing NaN pixels across the stack
# # Identify pixels with any NaN or NA across layers
# na_mask <- app(pred_stack, function(x) any(is.na(x)))
# 
# # Remove pixels with any NaN or NA (set them to NA across all layers)
# clean_stack <- mask(pred_stack, na_mask, maskvalue=TRUE)


