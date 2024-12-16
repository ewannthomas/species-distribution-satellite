


unzipScenes = function(){
  zippedFilesPath = getZippedFilesPath()
  
  for (zipFiles in zippedFilesPath){
    if(length(zipFiles)>0){
      extractFolder = getZipExportPath(zippedPath = zipFiles[1])
      
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
