


unzipScenes = function(){
  zippedFilesPath = getZippedFilesPath(externalSSD = externalDataSource)
  
  for (zipFiles in zippedFilesPath){
    if(length(zipFiles)>0){
      extractFolder = getZipExportPath(zippedPath = zipFiles[1], externalSSD = externalDataSource)
      
      for (zipFile in zipFiles){
        finalZipDir = getExportedZipPath(sourceDir = extractFolder, tailPath = zipFile)
        if (!file.exists(finalZipDir)){
          unzip(zipfile = zipFile, overwrite = TRUE, exdir = extractFolder)
        }
      }
    }
  }
  cat("All files unzipped")
}


unzipScenes()
