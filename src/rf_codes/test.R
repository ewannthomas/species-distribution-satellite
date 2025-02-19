
library(terra)

mask_path = "./data/"
grid_path = "./data/shapes/5k_grid_hp/5k_grid_hp.shp"


variable_vector <- c(
  "vv_Descendingsummer", "vv_Descendingwinter", "vh_Descendingsummer", "vh_Descendingwinter",
  "vv_Ascendingsummer", "vv_Ascendingwinter", , "vh_Ascendingwinter",
  "VV_VH_Asummer", "VV_VH_Awinter", "VV_VH_Dsummer", "VV_VH_Dwinter",
  "VH_VV_Asummer", "VH_VV_Awinter", "VH_VV_Dsummer", "VH_VV_Dwinter",
  "SAR_NDVI_Asummer", "SAR_NDVI_Awinter", "SAR_NDVI_Dsummer", "SAR_NDVI_Dwinter",
  "DVI_Asummer", "DVI_Awinter", "DVI_Dsummer", "DVI_Dwinter",
  "SVI_Asummer", "SVI_Awinter", "SVI_Dsummer", "SVI_Dwinter",
  "RDVI_Asummer", "RDVI_Awinter", "RDVI_Dsummer", "RDVI_Dwinter",
  "NRDVI_Asummer", "NRDVI_Awinter", "NRDVI_Dsummer", "NRDVI_Dwinter",
  "SSDVI_Asummer", "SSDVI_Awinter", "SSDVI_Dsummer", "SSDVI_Dwinter",
  "B11summer", "B11winter", "B02summer", "B02winter", "B12summer", "B12winter",
  "B08summer", "B08winter", "B04summer", "B04winter", "B03summer", "B03winter",
  "NDVIsummer", "NDVIwinter", "ARVI2summer", "ARVI2winter", "BWDRVIsummer", "BWDRVIwinter",
  "CVIsummer", "CVIwinter", "CTVIsummer", "CTVIwinter", "EVI2summer", "EVI2winter",
  "GVMIsummer", "GVMIwinter", "MSVAIhypersummer", "MSVAIhyperwinter",
  "MTVI2summer", "MTVI2winter", "MNDVIsummer", "MNDVIwinter", "OSAVIsummer", "OSAVIwinter",
  "PVIsummer", "PVIwinter", "SARVIsummer", "SARVIwinter", "SLAVIsummer", "SLAVIwinter",
  "TSAVI2summer", "TSAVI2winter", "WDVIsummer", "WDVIwinter", "WDRVIsummer", "WDRVIwinter"
)




# Assuming the dataframe `df` already exists with columns "B04" and "B03"
df$NDVI <- (df$B04 - df$B03) / (df$B04 + df$B03)

# Create a temporary dataframe with just the "NDVI" column
temp_df <- df["NDVI"]


bdod = rast(orig_tiffs[[2]])
bdod_250 = rast(inter_tiffs[[1]])


bm = cover(bdod, bdod_250)
bm_clipped = crop(bm, hp, mask=TRUE, ext=TRUE)
bm_resam = resample(bm_clipped, mask_tif)
# ext(mask_tif) <- ext(bm_resam)
# mask_resam = resample(mask_tif, bm_clipped, method='max')
bm_masked = mask(bm_resam, mask_tif, maskvalues=0)

plot(bdod)
plot(bdod_250)
plot(bm_clipped)
plot(bm_masked)
plot(hp, add = TRUE, col = "red", lwd = 1, alpha=0)
writeRaster(bm_masked, out_file, overwrite=TRUE)



pred_brick_sub <- pred_brick[[11:86]]


new_tiffs = tiffs[1:10][1] 

"vh_Ascendingsummer"  "vh_Descendingsummer" "vv_Ascendingsummer"  "vv_Descendingsummer" "vh_Ascendingwinter" 
[6] "vh_Descendingwinter" "vv_Ascendingwinter"  "vv_Descendingwinter" "B11summer"           "B12summer"          
[11] "B02summer"           "B03summer"           "B04summer"           "B08summer"           "B11winter"          
[16] "B12winter"           "B02winter"           "B03winter"           "B04winter"           "B08winter"          
[21] "VV_VH_Asummer"       "VV_VH_Dsummer"       "VH_VV_Asummer"       "VH_VV_Dsummer"       "SAR_NDVI_Asummer"   
[26] "SAR_NDVI_Dsummer"    "DVI_Asummer"         "DVI_Dsummer"         "SVI_Asummer"         "SVI_Dsummer"        
[31] "RDVI_Asummer"        "RDVI_Dsummer"        "NRDVI_Asummer"       "NRDVI_Dsummer"       "SSDVI_Asummer"      
[36] "SSDVI_Dsummer"       "VV_VH_Awinter"       "VV_VH_Dwinter"       "VH_VV_Awinter"       "VH_VV_Dwinter"      
[41] "SAR_NDVI_Awinter"    "SAR_NDVI_Dwinter"    "DVI_Awinter"         "DVI_Dwinter"         "SVI_Awinter"        
[46] "SVI_Dwinter"         "RDVI_Awinter"        "RDVI_Dwinter"        "NRDVI_Awinter"       "NRDVI_Dwinter"      
[51] "SSDVI_Awinter"       "SSDVI_Dwinter"       "NDVIsummer"          "NDVIwinter"          "ARVI2summer"        
[56] "ARVI2winter"         "BWDRVIsummer"        "BWDRVIwinter"        "CVIsummer"           "CVIwinter"          
[61] "CTVIsummer"          "CTVIwinter"          "EVI2summer"          "EVI2winter"          "GVMIsummer"         
[66] "GVMIwinter"          "MSVAIhypersummer"    "MSVAIhyperwinter"    "MTVI2summer"         "MTVI2winter"        
[71] "MNDVIsummer"         "MNDVIwinter"         "OSAVIsummer"         "OSAVIwinter"         "PVIsummer"          
[76] "PVIwinter"           "SARVIsummer"         "SARVIwinter"         "SLAVIsummer"         "SLAVIwinter"        
[81] "TSAVI2summer"        "TSAVI2winter"        "WDVIsummer"          "WDVIwinter"          "WDRVIsummer"        
[86] "WDRVIwin"
 
 
new_pred_b = rast(new_tiffs)

pred_brick[[1:10]]<-new_pred_b

names(pred_brick[[1:10]]) <-name_mapping[1:10]

num_val = 3
pred_brick_new[[num_val]]
terra::minmax(pred_brick_new[[num_val]])[[1]]  
terra::minmax(pred_brick_new[[num_val]])[[2]]  
# terra::plot(pred_brick_new[[num_val]])


for (i in 1:46){
  print(sent2_layers[[i]])
}
pred_brick




# Create a SpatRaster
r <- rast(nrows=3, ncols=3)
values(r) <- c(1, Inf, 3, -Inf, 5, 6, 7, 8, Inf)

# Apply is.infinite
is_inf <- is.infinite(r)

# Output: SpatRaster with TRUE where values are Inf or -Inf
print(is_inf)








# Create a sample multi-layer SpatRaster
r1 <- rast(nrows=3, ncols=3, vals=c(1, 2, NaN, 4, 5, 6, NaN, 8, 9))
r2 <- rast(nrows=3, ncols=3, vals=c(10, NaN, 30, 40, 50, 60, 70, NaN, 90))
r3 <- rast(nrows=3, ncols=3, vals=c(100, 200, 300, NaN, 500, 600, 700, 800, 900))

# Combine into a SpatRaster stack
stack <- c(r1, r2, r3)
names(stack) <- c("Layer1", "Layer2", "Layer3")

# Identify pixels with any NaN or NA across layers
na_mask <- app(stack, function(x) any(is.na(x)))

# Remove pixels with any NaN or NA (set them to NA across all layers)
clean_stack <- mask(stack, na_mask, maskvalue=TRUE)

# View results
print(stack)        # Original stack
print(clean_stack)  # Cleaned stack

