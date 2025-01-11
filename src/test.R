

externalDataSource = TRUE


monthPathMaker = function(folderPrefix){
  years = seq(2022, 2022, 1)
  months = seq(1, 6, 1)
  
  monthPaths = unlist(lapply(years, function(year){lapply(months, function(month){
    paste(folderPrefix, year, month, sep = "/")
  })}))
  
  return (monthPaths)
}

getZippedFilesPath = function(externalSSD=externalDataSource){
  
  if (externalSSD==FALSE){
    zippedParent = "./data/sentinel_1"
  }
  else if(externalSSD==TRUE){
    
    zippedParent = list.files("/media/bippw1/Lilith", full.names = TRUE)[5]
  }
  
  monthPaths = monthPathMaker(folderPrefix = zippedParent)

  zipFiles = lapply(monthPaths, function(monthPath){list.files(monthPath, full.names=TRUE)})

  return(zipFiles)
}

getZipExportPath = function(zippedPath, externalSSD){
  
  extractedParent = "./data/extracted"
  
  if (externalSSD==FALSE){
    
    pathSplits = strsplit(zippedPath, "/")[[1]][c(4, 5, 6)]
    
  }
  else if(externalSSD==TRUE){
    
    pathSplits = strsplit(zippedPath, "/")[[1]][c(6, 7, 8)]
    
  }
  
  pathSplits[3] =strsplit(pathSplits[3], "\\.z")[[1]][[1]]
  
  print(pathSplits)
  
  extractedMonthlyFolder <- paste(extractedParent, pathSplits[1], pathSplits[2], sep="/")
  
  # Create the composite folder if it does not exist
  if (!file.exists(extractedMonthlyFolder)) {
    dir.create(extractedMonthlyFolder, recursive = TRUE)
  }
  
  return(extractedMonthlyFolder)
}
getZipExportPath("/media/bippw1/Lilith/sentinel_1/2022/6/S1A_IW_GRDH_1SDV_20220628T005912_20220628T005941_043856_053C4E_4DF3.SAFE.zip", externalSSD = externalDataSource)
