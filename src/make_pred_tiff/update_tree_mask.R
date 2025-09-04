
library(terra)

#tree mask and its value update
tree_mask = rast('./data/ESA_HP_Trees_UTM43.tif') # the source file is a 1.5 GB file. Reproject the mask in QGIS to make this file from the original mask

tree_mask_updated = ifel(tree_mask ==128, 0, tree_mask)
ext(tree_mask_updated)

writeRaster(tree_mask_updated, "data/tree_mask_utm43.tif", datatype='INT1U', overwrite=TRUE)
