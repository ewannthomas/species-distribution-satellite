library(terra)

#defining precition tif
tiff_path_root = paste0("./data/qg/vh/Ascending")
tiffs <- list.files(tiff_path_root, pattern = "*/*/*.tif", full.names = TRUE, recursive = TRUE)

#hp_state_bound_buffer path
hp_buffer_path = "./data/shapes/hp_buffer/hp_buffer.shp"
hp = vect(hp_buffer_path)


final_tiff_path = "./data/sent1_pred.tif"

s1_rast = rast(tiffs[[1]])
s1_rast = rectify(s1_rast)
s1_re = project(s1_rast, "epsg:32643", method='near')
writeRaster(s1_re, "./data/reproj.tif", datatype = "INT2U", overwrite = TRUE)
# for (i in tiffs){
#   s1_rast = rast(tiffs[[1]])
#   
#   s1_rast_cropped = crop(s1_rast, hp)
# }
