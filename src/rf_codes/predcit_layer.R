
library(terra)

# For Pine VS Rhododendron
target_specie =8
control_specie = 10


#defining directories
path_root = paste0("./data/models/",target_specie, "_", control_specie, "/", target_specie, "_", control_specie)
model_path <- paste0(path_root,"_model.RData")

pred_tiff_path = "./data/prediction_tiff/pred_stack.tif"

specie_predicted_tiff_path = paste0("./data/species_predicted_tiffs/", target_specie, "_", control_specie, ".tif")

pred_stack <- rast(pred_tiff_path)


#loading the model
load(model_path)

PR_pred_layer <- terra::predict(pred_stack, PR_model_xgb, na.rm=TRUE)

writeRaster(PR_pred_layer, specie_predicted_tiff_path)
