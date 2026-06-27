library(terra)

#defining precition tif
tiff_path_root = paste0("./data/prediction_tiff/sentinel_tiffs/s1")
tiffs <- list.files(tiff_path_root, pattern = "*/*/*.tif", full.names = TRUE, recursive = TRUE)

final_tiff_path = "./data/sent1_pred.tif"

#####TIFF Prediction
pred_brick = rast(tiffs)

name_mapping <- c(
  "vh_Ascendingsummer", "vh_Descendingsummer", "vv_Ascendingsummer", "vv_Descendingsummer",
  "vh_Ascendingwinter", "vh_Descendingwinter", "vv_Ascendingwinter", "vv_Descendingwinter")


names(pred_brick) <-name_mapping


# masking histograms for sentinel 1 bands for value evaluation
# hist_vals = terra::hist(pred_brick, layer=2, plot=FALSE)
# hist_vals$xname
# hist_vals$breaks
# hist_vals$counts
# round(hist_vals$density, 3)

# Making Sent 1 Indices
# For Summer 
pred_brick$VV_VH_Asummer <- pred_brick$vv_Ascendingsummer / pred_brick$vh_Ascendingsummer
pred_brick$VV_VH_Dsummer <- pred_brick$vv_Descendingsummer / pred_brick$vh_Descendingsummer

pred_brick$VH_VV_Asummer <- pred_brick$vh_Ascendingsummer / pred_brick$vv_Ascendingsummer
pred_brick$VH_VV_Dsummer <- pred_brick$vh_Descendingsummer / pred_brick$vv_Descendingsummer

pred_brick$SAR_NDVI_Asummer <- (pred_brick$vh_Ascendingsummer - pred_brick$vv_Ascendingsummer) / (pred_brick$vh_Ascendingsummer + pred_brick$vv_Ascendingsummer)
pred_brick$SAR_NDVI_Dsummer <- (pred_brick$vh_Descendingsummer - pred_brick$vv_Descendingsummer) / (pred_brick$vh_Descendingsummer + pred_brick$vv_Descendingsummer)

pred_brick$DVI_Asummer <- pred_brick$vh_Ascendingsummer - pred_brick$vv_Ascendingsummer
pred_brick$DVI_Dsummer <- pred_brick$vh_Descendingsummer - pred_brick$vv_Descendingsummer

pred_brick$SVI_Asummer <- pred_brick$vh_Ascendingsummer + pred_brick$vv_Ascendingsummer
pred_brick$SVI_Dsummer <- pred_brick$vh_Descendingsummer + pred_brick$vv_Descendingsummer

pred_brick$RDVI_Asummer <- pred_brick$VH_VV_Asummer - pred_brick$VV_VH_Asummer
pred_brick$RDVI_Dsummer <- pred_brick$VH_VV_Dsummer - pred_brick$VV_VH_Dsummer

pred_brick$NRDVI_Asummer <- pred_brick$RDVI_Asummer / (pred_brick$VH_VV_Asummer + pred_brick$VV_VH_Asummer)
pred_brick$NRDVI_Dsummer <- pred_brick$RDVI_Dsummer / (pred_brick$VH_VV_Dsummer + pred_brick$VV_VH_Dsummer)

pred_brick$SSDVI_Asummer <- pred_brick$vh_Ascendingsummer^2 - pred_brick$vv_Ascendingsummer^2
pred_brick$SSDVI_Dsummer <- pred_brick$vh_Descendingsummer^2 - pred_brick$vv_Descendingsummer^2

# For Winter
pred_brick$VV_VH_Awinter <- pred_brick$vv_Ascendingwinter / pred_brick$vh_Ascendingwinter
pred_brick$VV_VH_Dwinter <- pred_brick$vv_Descendingwinter / pred_brick$vh_Descendingwinter

pred_brick$VH_VV_Awinter <- pred_brick$vh_Ascendingwinter / pred_brick$vv_Ascendingwinter
pred_brick$VH_VV_Dwinter <- pred_brick$vh_Descendingwinter / pred_brick$vv_Descendingwinter

pred_brick$SAR_NDVI_Awinter <- (pred_brick$vh_Ascendingwinter - pred_brick$vv_Ascendingwinter) / (pred_brick$vh_Ascendingwinter + pred_brick$vv_Ascendingwinter)
pred_brick$SAR_NDVI_Dwinter <- (pred_brick$vh_Descendingwinter - pred_brick$vv_Descendingwinter) / (pred_brick$vh_Descendingwinter + pred_brick$vv_Descendingwinter)

pred_brick$DVI_Awinter <- pred_brick$vh_Ascendingwinter - pred_brick$vv_Ascendingwinter
pred_brick$DVI_Dwinter <- pred_brick$vh_Descendingwinter - pred_brick$vv_Descendingwinter

pred_brick$SVI_Awinter <- pred_brick$vh_Ascendingwinter + pred_brick$vv_Ascendingwinter
pred_brick$SVI_Dwinter <- pred_brick$vh_Descendingwinter + pred_brick$vv_Descendingwinter

pred_brick$RDVI_Awinter <- pred_brick$VH_VV_Awinter - pred_brick$VV_VH_Awinter
pred_brick$RDVI_Dwinter <- pred_brick$VH_VV_Dwinter - pred_brick$VV_VH_Dwinter

pred_brick$NRDVI_Awinter <- pred_brick$RDVI_Awinter / (pred_brick$VH_VV_Awinter + pred_brick$VV_VH_Awinter)
pred_brick$NRDVI_Dwinter <- pred_brick$RDVI_Dwinter / (pred_brick$VH_VV_Dwinter + pred_brick$VV_VH_Dwinter)

pred_brick$SSDVI_Awinter <- pred_brick$vh_Ascendingwinter^2 - pred_brick$vv_Ascendingwinter^2
pred_brick$SSDVI_Dwinter <- pred_brick$vh_Descendingwinter^2 - pred_brick$vv_Descendingwinter^2



#removing Inf values arriving from division by 0 over bands
for (i in 1:40){
  print("*********************************")
  print(i)
  print(pred_brick[[i]])
}

# From the above its evident that layers 11, 19, 27, 28, 35, 36 have -Inf and their min values cannot be estimated.
# So we will replace these -Inf values with NanN
for (i in c(11, 19, 27, 28, 35, 36)){
  pred_brick[[i]] = ifel(is.infinite(pred_brick[[i]]), NaN, pred_brick[[i]])
}

#checking whether the assignmebt worked
for (i in c(11, 19, 27, 28, 35, 36)){
  print("*********************************")
  print(i)
  print(pred_brick[[i]])
}


# Normalizing across each layer of the brick 
for (i in 1:nlyr(pred_brick)) {
  print("*********************************************")
  print(pred_brick[[i]])
  layer <- pred_brick[[i]]   
  layer_min <- terra::minmax(pred_brick[[i]])[[1]]  
  layer_max <- terra::minmax(pred_brick[[i]])[[2]]   
  normalized_layer <- (layer - layer_min) / (layer_max - layer_min)   
  pred_brick[[i]] <- normalized_layer
  print("-----------------------")
  print(pred_brick[[i]])  
}

#reassigning names to var_names of the brick as well
varnames(pred_brick) <- names(pred_brick)


#saving the RDS
# saveRDS(pred_brick, file = final_tiff_path)

writeRaster(pred_brick, final_tiff_path)
