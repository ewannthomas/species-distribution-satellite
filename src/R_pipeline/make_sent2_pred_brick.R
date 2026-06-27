library(terra)

#defining precition tif
tiff_path_root = paste0("./data/prediction_tiff/sentinel_tiffs/s2")
tiffs <- list.files(tiff_path_root, pattern = "*/*/*.tif", full.names = TRUE, recursive = TRUE)

final_tiff_path = "./data/sent2_pred.tif"

#####TIFF Prediction
pred_brick = rast(tiffs)

name_mapping <- c(
  "B11summer", "B12summer", "B02summer", "B03summer", "B04summer", "B08summer",
  "B11winter", "B12winter", "B02winter", "B03winter", "B04winter", "B08winter"
)

names(pred_brick) <-name_mapping


##Making Sentinel 2 Indices

# NDVI calculation for summer and winter using pred_brick
pred_brick$NDVIsummer <- (pred_brick$B08summer - pred_brick$B04summer) / (pred_brick$B08summer + pred_brick$B04summer)
pred_brick$NDVIwinter <- (pred_brick$B08winter - pred_brick$B04winter) / (pred_brick$B08winter + pred_brick$B04winter)

# Create a single temporary dataframe without suffix
temp_df <- c(pred_brick$NDVIsummer, pred_brick$NDVIwinter)

# ARVI2 calculation for summer and winter using pred_brick
pred_brick$ARVI2summer <- -0.18 + 1.17 * pred_brick$NDVIsummer
pred_brick$ARVI2winter <- -0.18 + 1.17 * pred_brick$NDVIwinter

# BWDRVI calculation for summer and winter using pred_brick
pred_brick$BWDRVIsummer <- (0.1 * (pred_brick$B08summer - pred_brick$B02summer)) / 
  (0.1 * (pred_brick$B08summer + pred_brick$B02summer))
pred_brick$BWDRVIwinter <- (0.1 * (pred_brick$B08winter - pred_brick$B02winter)) / 
  (0.1 * (pred_brick$B08winter + pred_brick$B02winter))

# CVI calculation for summer and winter using pred_brick
pred_brick$CVIsummer <- pred_brick$B08summer * (pred_brick$B04summer / (pred_brick$B03summer^2))
pred_brick$CVIwinter <- pred_brick$B08winter * (pred_brick$B04winter / (pred_brick$B03winter^2))

## Corrected Transformed Vegetation Index
temp_df$ndvi_plus_0_5summer <- temp_df$NDVIsummer + 0.5
temp_df$ndvi_plus_0_5winter <- temp_df$NDVIwinter + 0.5
temp_df$ctvi1summer <- (temp_df$ndvi_plus_0_5summer) / abs(temp_df$ndvi_plus_0_5summer)
temp_df$ctvi1winter <- (temp_df$ndvi_plus_0_5winter) / abs(temp_df$ndvi_plus_0_5winter)
temp_df$ctvi2summer <- sqrt(abs(temp_df$ndvi_plus_0_5summer))
temp_df$ctvi2winter <- sqrt(abs(temp_df$ndvi_plus_0_5winter))
pred_brick$CTVIsummer <- temp_df$ctvi1summer * temp_df$ctvi2summer
pred_brick$CTVIwinter <- temp_df$ctvi1winter * temp_df$ctvi2winter

# Calculate EVI2 for summer and winter and assign it directly to pred_brick
pred_brick$EVI2summer <- 2.5 * ((pred_brick$B08summer - pred_brick$B04summer) / (pred_brick$B08summer + (2.4 * pred_brick$B04summer) + 1))
pred_brick$EVI2winter <- 2.5 * ((pred_brick$B08winter - pred_brick$B04winter) / (pred_brick$B08winter + (2.4 * pred_brick$B04winter) + 1))


# Calculate GVMI for summer and winter
temp_df$gvminummer <- (pred_brick$B08summer + 0.1) - (pred_brick$B12summer + 0.02)
temp_df$gvmidenummer <- (pred_brick$B08summer + 0.1) + (pred_brick$B12summer + 0.02)
temp_df$gvminumwinter <- (pred_brick$B08winter + 0.1) - (pred_brick$B12winter + 0.02)
temp_df$gvmidenwinter <- (pred_brick$B08winter + 0.1) + (pred_brick$B12winter + 0.02)
pred_brick$GVMIsummer <- temp_df$gvminummer / temp_df$gvmidenummer
pred_brick$GVMIwinter <- temp_df$gvminumwinter / temp_df$gvmidenwinter

# Modified Soil Adjusted Vegetation Index hyper calculation
temp_df$hyperfirsttermsummer <- 2 * pred_brick$B08summer + 1
temp_df$hypersecondsummer <- sqrt(temp_df$hyperfirsttermsummer^2 - (8 * (pred_brick$B08summer - pred_brick$B04summer)))
temp_df$hyperfirsttermwinter <- 2 * pred_brick$B08winter + 1
temp_df$hypersecondwinter <- sqrt(temp_df$hyperfirsttermwinter^2 - (8 * (pred_brick$B08winter - pred_brick$B04winter)))
pred_brick$MSVAIhypersummer <- 0.5 * (temp_df$hyperfirsttermsummer - temp_df$hypersecondsummer)
pred_brick$MSVAIhyperwinter <- 0.5 * (temp_df$hyperfirsttermwinter - temp_df$hypersecondwinter)


# MTVI2 calculation for summer and winter
temp_df$mtvi2numsummer <- 1.5 * (1.2 * (pred_brick$B08summer - pred_brick$B03summer) - 2.5 * (pred_brick$B04summer - pred_brick$B03summer))
temp_df$mtvi2densummer <- sqrt((2 * pred_brick$B08summer + 1)^2 - (6 * pred_brick$B08summer - 5 * (sqrt(pred_brick$B04summer))) - 0.5)
temp_df$mtvi2numwinter <- 1.5 * (1.2 * (pred_brick$B08winter - pred_brick$B03winter) - 2.5 * (pred_brick$B04winter - pred_brick$B03winter))
temp_df$mtvi2denwinter <- sqrt((2 * pred_brick$B08winter + 1)^2 - (6 * pred_brick$B08winter - 5 * (sqrt(pred_brick$B04winter))) - 0.5)
pred_brick$MTVI2summer <- temp_df$mtvi2numsummer / temp_df$mtvi2densummer
pred_brick$MTVI2winter <- temp_df$mtvi2numwinter / temp_df$mtvi2denwinter

# MNDVI calculation for summer and winter
pred_brick$MNDVIsummer <- (pred_brick$B08summer - pred_brick$B12summer) / (pred_brick$B08summer + pred_brick$B12summer)
pred_brick$MNDVIwinter <- (pred_brick$B08winter - pred_brick$B12winter) / (pred_brick$B08winter + pred_brick$B12winter)

# Optimized Soil Adjusted Vegetation Index (OSAVI) for summer and winter
temp_df$Y <- 0.16
temp_df$osavi_num_summer <- pred_brick$B08summer - pred_brick$B04summer
temp_df$osavi_den_summer <- pred_brick$B08summer + pred_brick$B04summer + temp_df$Y
temp_df$osavi_num_winter <- pred_brick$B08winter - pred_brick$B04winter
temp_df$osavi_den_winter <- pred_brick$B08winter + pred_brick$B04winter + temp_df$Y
pred_brick$OSAVIsummer <- (temp_df$Y + 1) * (temp_df$osavi_num_summer / temp_df$osavi_den_summer)
pred_brick$OSAVIwinter <- (temp_df$Y + 1) * (temp_df$osavi_num_winter / temp_df$osavi_den_winter)

# Perpendicular Vegetation Index (PVI) for summer and winter
pvi_a <- 0.149
pvi_ar <- 0.374
pvi_b <- 0.735
temp_df$pvi_firstsummer <- 1 / sqrt(1 + (pvi_a * pvi_a))
temp_df$pvi_secondsummer <- pred_brick$B08summer - pvi_ar - pvi_b
temp_df$pvi_firstwinter <- 1 / sqrt(1 + (pvi_a * pvi_a))
temp_df$pvi_secondwinter <- pred_brick$B08winter - pvi_ar - pvi_b
pred_brick$PVIsummer <- temp_df$pvi_firstsummer * temp_df$pvi_secondsummer
pred_brick$PVIwinter <- temp_df$pvi_firstwinter * temp_df$pvi_secondwinter


# Soil and Atmospherically Resistant Vegetation Index (SARVI) for summer and winter
y <- 0.735
Rr <- 0.740
L <- 0.487
RB <- 0.560
temp_df$sarvinumsummer <- pred_brick$B08summer - (Rr - y * (RB - Rr))
temp_df$sarvidensummer <- (pred_brick$B08summer + -(Rr - y * (RB - Rr))) + L
temp_df$sarvinumwinter <- pred_brick$B08winter - (Rr - y * (RB - Rr))
temp_df$sarvidenwinter <- (pred_brick$B08winter + -(Rr - y * (RB - Rr))) + L
pred_brick$SARVIsummer <- (1 + L) * (temp_df$sarvinumsummer / temp_df$sarvidensummer)
pred_brick$SARVIwinter <- (1 + L) * (temp_df$sarvinumwinter / temp_df$sarvidenwinter)


# Specific Leaf Area Vegetation Index (SLAVI) for summer and winter
pred_brick$SLAVIsummer <- pred_brick$B08summer / (pred_brick$B04summer + pred_brick$B12summer)
pred_brick$SLAVIwinter <- pred_brick$B08winter / (pred_brick$B04winter + pred_brick$B12winter)

# Transformed Soil Adjusted Vegetation Index 2 (TSAVI2) for summer and winter
tsavi2_a <- 0.419
tsavi2_b <- 0.787
temp_df$tsavi2_num_summer <- (tsavi2_a * pred_brick$B08summer) - (tsavi2_a * pred_brick$B04summer) - tsavi2_b
temp_df$tsavi2_den_summer <- pred_brick$B04summer + (tsavi2_a * pred_brick$B08summer) - (tsavi2_a * tsavi2_b)
temp_df$tsavi2_num_winter <- (tsavi2_a * pred_brick$B08winter) - (tsavi2_a * pred_brick$B04winter) - tsavi2_b
temp_df$tsavi2_den_winter <- pred_brick$B04winter + (tsavi2_a * pred_brick$B08winter) - (tsavi2_a * tsavi2_b)
pred_brick$TSAVI2summer <- temp_df$tsavi2_num_summer / temp_df$tsavi2_den_summer
pred_brick$TSAVI2winter <- temp_df$tsavi2_num_winter / temp_df$tsavi2_den_winter


# Weighted Difference Vegetation Index (WDVI) for summer and winter
wdvi_a <- 0.752
pred_brick$WDVIsummer <- pred_brick$B08summer - (wdvi_a * pred_brick$B04summer)
pred_brick$WDVIwinter <- pred_brick$B08winter - (wdvi_a * pred_brick$B04winter)

# Wide Dynamic Range Vegetation Index (WDRVI) for summer and winter
pred_brick$WDRVIsummer <- (0.1 * (pred_brick$B08summer - pred_brick$B04summer)) / (0.1 * (pred_brick$B08summer + pred_brick$B04summer))
pred_brick$WDRVIwinter <- (0.1 * (pred_brick$B08winter - pred_brick$B04winter)) / (0.1 * (pred_brick$B08winter + pred_brick$B04winter))


#removing Inf values arriving from division by 0 over bands
for (i in 1:46){
  print("*********************************")
  print(i)
  print(pred_brick[[i]])
}

# From the above its evident that layers 19, 20 have Inf and their max values cannot be estimated.
# So we will replace these Inf values with NanN
for (i in c(19, 20)){
  pred_brick[[i]] = ifel(is.infinite(pred_brick[[i]]), NaN, pred_brick[[i]])
}

#checking whether the assignment worked
for (i in c(19, 20)){
  print("*********************************")
  print(i)
  print(pred_brick[[i]])
}

# Normalizing across each layer of the brick 
for (i in 30:nlyr(pred_brick)) {
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


# #isolating sentinel 2 layers before exporting
# sent2_index = c(9:20, 53:86)
# 
# sent2_layers <- pred_brick[[sent2_index]]

#saving the RDS
# saveRDS(pred_brick, file = final_tiff_path)

writeRaster(pred_brick, final_tiff_path)
