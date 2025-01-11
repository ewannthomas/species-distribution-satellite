
getS1Values = function(){
  
  hpTrees = vect(getShpFilePath("himachal_species"))
  
  bandPaths = getS1BandPaths()
  
  for (resBandPaths in bandPaths){
    
    for (img in resBandPaths){
      
      finalDFPath = sentinel1DFPath(img)
      
      if (!file.exists(finalDFPath)){
        
        rastMetaData = getXmlMeta(img)
        
        hpRast = rast(img)
        crs(hpRast) = "epsg:4326"
        
        hpRastRotated = rastRotate(hpRast)
        
        df = pointValueExtractor(aoi=hpTrees, imgRast=hpRastRotated, metaData=rastMetaData)
        
        write_parquet(x=df, sink=finalDFPath)
        
        cat("Created DF at ", finalDFPath, "\n")
      }
      
      else{
        cat("skipping", finalDFPath, "\n")
      }
      
    }
  }
  
  cat("All Sentinel 1 Tiles have been processed")
 
}

getS1Values()


