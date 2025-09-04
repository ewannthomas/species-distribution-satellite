library(terra)
library(stringr)

#defining precition tif
tiff_path_root = paste0("./data/monthly_mosaics/sentinel_2/summer")
tiffs <- list.files(tiff_path_root, pattern = "*_3.tif$", full.names = TRUE, recursive = TRUE)
tiffs

tree_mask = rast("./data/tree_mask_utm43.tif")

for (i in 1:length(tiffs)){
  
  img = rast(tiffs[[i]])
  
  # making the folders and path to store masked tiffs
  new_rast_path = str_replace(tiffs[[i]], "monthly_mosaics", "test")
  
  new_tiff_folder = paste0(str_split(new_rast_path, "/")[[1]][1:5], collapse ="/")
  raster_name = str_split(new_rast_path, "/")[[1]][6]
  
  if (!dir.exists(new_tiff_folder)){
    dir.create(new_tiff_folder, recursive = TRUE)
  }
  
  #masking the tiff
  
  img_masked = mask(img, tree_mask, maskvalues=0)
  
  writeRaster(img_masked, new_rast_path, datatype='INT2U', overwrite=TRUE)
  print(raster_name)
  
}
