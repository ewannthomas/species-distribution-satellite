

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



getXmlMeta = function(imgPath) {

  xmlPath = getS1TiffXml(imgPath)
  
  xmlFile = read_xml(xmlPath)
  
  # Getting meta data from the XML file
  startDateNode = xml_find_first(xmlFile, "//adsHeader/startTime")  # Find the first occurrence
  bandNameNode = xml_find_first(xmlFile, "//adsHeader/polarisation")
  orbitPassNode = xml_find_first(xmlFile, "//pass")       # Find the first occurrence
  
  # Extract text from nodes
  startDate = strsplit(xml_text(startDateNode), "T")[[1]][[1]]
  bandName = str_to_lower(xml_text(bandNameNode))
  orbitPass = xml_text(orbitPassNode)
  
  # Using the stem of the fiel to create the system generated column name in the final data.
  # This stem value will be used to identify this column without fail and rename it to the bandName value
  pathStem = strsplit(xmlPath, "/")[[1]][8]
  pathStem = sub(pattern =".xml", replacement= "", x = pathStem)
  pathStem = gsub(pattern ="-", replacement= ".", x = pathStem)
  
  # Store metadata in a named list
  metaData = list(startDate = startDate, bandName=bandName, orbitPass = orbitPass, pathStem = pathStem)
  
  return(metaData)
}


rastRotate = function(imgRast){
  is_rotated = is.rotated(imgRast)
  if (is_rotated==TRUE){
    # print("Rotating raster")
    rotatedRaster = rectify(imgRast)
    
    return(rotatedRaster)
  }
  else{
    return(imgRast)
  }

}


pointValueExtractor = function(aoi, imgRast, metaData){
  df = as_tibble(extract(imgRast, aoi, method="simple", bind= TRUE, raw=FALSE))
  
  cols_to_keep = c("Lat", "Long", "Altitude", "classname", metaData[["pathStem"]])
  
  df = df %>% select(all_of(cols_to_keep))
  
  df = df %>% rename(!!metaData[["bandName"]] := !!metaData[["pathStem"]])
  
  df = df %>% mutate(date=metaData[["startDate"]]) %>% 
    mutate(orbit=metaData[["orbitPass"]])
  
  df = df %>% filter(!is.na(!!sym(metaData[["bandName"]])))
  
  df = df %>% rename_with(tolower) %>% rename("species_name"="classname")
  
  return(df)
}

