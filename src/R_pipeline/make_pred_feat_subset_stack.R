library(terra)

#defining precition tif
pred_stack_path = "./data/prediction_tiff/pred_stack.tif"

# Stacking
pred_stack <- rast(pred_stack_path)


#reordering the features
feature_order = c('B11summer', 'B11winter', 'B12summer', 'B12winter', 'B08summer',
                  'B03summer', 'CVIsummer', 'PVIsummer', 'sand_f', 'elevation', 'cfvo_f',
                  'phh2o_f', 'soc_f', 'slope', 'clay_f', 'nitrogen_f', 'cec_f', 'bdod_f',
                  'aspect', 'silt_f', 'ocd_f')


pred_stack <- pred_stack[[feature_order]]

#writing the prediction raster
writeRaster(pred_stack, "./data/prediction_tiff/pred_stack_feat_subset.tif", overwrite=TRUE)


