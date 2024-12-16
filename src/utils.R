

#Loading the data
loadBands = function(rastPath){
  rastImg = terra::rast(rastPath)
  # rastReproj = reprojectRast(rastImg)
  # rastResam = resampleRast(rastReproj)
  return(rastImg)
}


reprojectRast = function(r){
  reprojectedRast = project(r, "EPSG:4326", threads=TRUE)
  
  auth = crs(r, describe=TRUE)[[2]]
  code = crs(r, describe=TRUE)[[3]]
  oldCRSCode = paste(auth, code, sep=":")
  
  # Correct the extent by recalculating it in the target CRS
  correct_extent <- project(ext(r), oldCRSCode, "EPSG:32643")
  ext(reprojectedRast) <- correct_extent
  
  # checkResExt(reprojectedRast)
  
  return(reprojectedRast)
}


resampleRast = function(r){
  
  # Define a target resolution (e.g., 10 meters)
  target_resolution <- 10
  
  # Create a new raster template with the desired resolution
  templateRast <- rast(extent=ext(r), crs=crs(r), resolution=c(10,10))
  
  resampledRast = resample(r, templateRast)
  

  
  
  return(resampledRast)
  
}


checkResExt = function(crast){
    print(res(crast))
    print(ext(crast))
    print(dim(crast))
    print(crs(crast, describe=TRUE, parse=TRUE))
}