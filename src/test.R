library(terra)


s1p = "./data/s1.tif"
s2p = "./data/s2.tif"
s3p = "./data/s3.tif"
s4p = "./data/s4.tif"


s1 = rast(s1p)
s2 = rast(s2p)
s3 = rast(s3p)
s4 = rast(s4p)

hp_y_lat_min = 3361536.581
hp_x_long_max = 555603.883

hp_x_long_min = 313386.107
hp_y_lat_max = 3681425.141

# Define the new extent (xmin, xmax, ymin, ymax)
new_extent <- ext(hp_x_long_min, hp_x_long_max, hp_y_lat_min, hp_y_lat_max)

# Reassign the extent to each raster
ext(s1) <- new_extent
ext(s2) <- new_extent
ext(s3) <- new_extent
ext(s4) <- new_extent

s4_re = reprojectRast(s4)

merged = merge(sprc(s1, s2, s3, s4), first=FALSE)
merged_new = merge(s3, s4, first=FALSE)

writeRaster(merged, "./data/mos_test2.tif", overwrite=TRUE)
writeRaster(merged_new, "./data/mos_test_merge_43.tif", overwrite=TRUE)

