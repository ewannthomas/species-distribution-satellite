
library(terra)


#defining directories
path_root = paste0("./data/models/")
model_path <- paste0(path_root,"all_species_rf.RData")

pred_tiff_path = "./data/prediction_tiff/pred_stack.tif"

specie_predicted_tiff_path = paste0("./data/species_predicted_tiffs/","all_species.tif")

pred_stack <- rast(pred_tiff_path)


#loading the model
load(model_path)

PS_pred_layer <- terra::predict(pred_stack, PS_model_rf, na.rm=TRUE)

writeRaster(PS_pred_layer, specie_predicted_tiff_path)



