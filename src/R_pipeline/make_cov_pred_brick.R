library(terra)

out_folder = "./data/prediction_tiff/cov_tiffs/processed"

mask_path = "./data/ESA_HP_ClipExtent_Reclass.tif"
hp_buffer_path = "./data/shapes/hp_buffer/hp_buffer.shp"

orig_cov_path = tiff_path_root = paste0("./data/prediction_tiff/cov_tiffs/orig")
inter_cov_path = tiff_path_root = paste0("./data/prediction_tiff/cov_tiffs/inter")
orig_tiffs = list.files(orig_cov_path, pattern = "*.tif", full.names = TRUE, recursive = TRUE)


hp = vect(hp_buffer_path)
mask_tif = rast(mask_path)


for (tf_file in orig_tiffs){
  stem = strsplit(strsplit(tf_file, "/")[[1]][6], "\\.")[[1]][1]
  tif_out_file = paste0(out_folder, stem, ".tif")

  print(stem)
  
  #  checking for DEM elemnts and escaping them from covering with interpolated values
  if (stem %in% c('aspect', 'slope', 'elevation')){
    cov = rast(tf_file)
  }
  else{
    inter_stem = paste0(stem, "_250.tif")
    inter_path = paste0(inter_cov_path, "/" ,inter_stem)
    print(inter_path)
    
    cov_actual = rast(tf_file)
    inter_cov = rast(inter_path)
    
    cov = cover(cov_actual, inter_cov)
    print("........Covered")
  }
  
  #cropping covariates
  cov_cropped = crop(cov, hp, mask=TRUE, ext=TRUE)
  print("........Cropped")
  
  # resampling all covariates except DEM elements because they are already in 10m
  cov_resampled = resample(cov_cropped, mask_tif) 
  print("........Resampled")
  
  #masking for tree pixels
  cov_masked = mask(cov_resampled, mask_tif, maskvalues=0)
  
  plot(cov_masked)
  plot(hp, add = TRUE, col = "red", lwd = 1, alpha=0)
  
  writeRaster(cov_masked, tif_out_file, overwrite=TRUE)
}

###### Making the Covariates brick

names_brick <- c("aspect", "bdod_f", "cec_f", "cfvo_f", "clay_f", "elevation", "nitrogen_f", "ocd_f", "phh2o_f", "sand_f", 
                 "silt_f", "slope", "soc_f")


cov_tiffs <-list.files(out_folder, pattern = "*.tif", full.names = TRUE, recursive = TRUE)
cov_brick <- rast(cov_tiffs)

#setting names to model frame names 
names(cov_brick) <- names_brick

for (i in 1:nlyr(cov_brick)) { 
  print("*********************************************")
  print(cov_brick[[i]]) 
  layer <- cov_brick[[i]]   
  layer_min <- terra::minmax(cov_brick[[i]])[[1]]  
  layer_max <- terra::minmax(cov_brick[[i]])[[2]]   
  normalized_layer <- (layer - layer_min) / (layer_max - layer_min)   
  cov_brick[[i]] <- normalized_layer
  print("-----------------------------")
  print(cov_brick[[i]])  
}


#reassigning names to var_names of the brick as well
varnames(cov_brick) <- names(cov_brick)

writeRaster(cov_brick, "./data/covar_brick.tif")


