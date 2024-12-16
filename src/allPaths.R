library(readr)
library(terra)

monthPathMaker = function(folderPrefix){
  years = seq(2018, 2018, 1)
  months = seq(1,12, 1)
  
  monthPaths = unlist(lapply(years, function(year){lapply(months, function(month){
    paste(folderPrefix, year, month, sep = "/")
  })}))
  
  return (monthPaths)
}


getZippedFilesPath = function(){
  zippedParent = "./data/sentinel_2"
  monthPaths = monthPathMaker(folderPrefix = zippedParent)
  
  zipFiles = lapply(monthPaths, function(monthPath){list.files(monthPath, full.names=TRUE)})
  
  return(zipFiles)
}

getZipExportPath = function(zippedPath){
  extractedParent = "./data/extracted"
  
  pathSplits = strsplit(zippedPath, "/")[[1]][c(4, 5, 6)]
  
  pathSplits[3] =strsplit(pathSplits[3], "\\.z")[[1]][[1]]
  
  extractedMonthlyFolder <- paste(extractedParent, pathSplits[1], pathSplits[2], sep="/")
  
  # Create the composite folder if it does not exist
  if (!file.exists(extractedMonthlyFolder)) {
    dir.create(extractedMonthlyFolder, recursive = TRUE)
  }
  
  return(extractedMonthlyFolder)
}


getExportedZipPath = function(sourceDir, tailPath){
  pathSplits = strsplit(tailPath, "/")[[1]][6]
  
  pathSplits=strsplit(pathSplits, "\\.z")[[1]][[1]]
  finalPath = paste(sourceDir, pathSplits, sep="/")
  return(finalPath)
}

getDayFolders = function(){
  data_folder = "./data/extracted"
  
  monthPaths = monthPathMaker(folderPrefix = data_folder)
  
  
  dayFolders = unlist(lapply(monthPaths, function(monthPath){list.files(monthPath, full.names=TRUE)}))
  
  return(dayFolders)
}


getBandPaths <- function(){
  
  # Return a list containing all three
  bandPaths = lapply(getDayFolders(), function(dayFolder){
    img_paths = list.files(path=dayFolder,full.names = TRUE, recursive = TRUE, pattern = "*B0.*.10m.jp2|*B0[5-8]_20m.jp2|*B11_20m.jp2|*B12_20m.jp2")
    
  })
  
  return(bandPaths)
}



# Function to return month path for export band composites images
getMonthPath = function(imgPath) {
  
  compositeDataParent = "./data/composites"
  
  pathSplits = strsplit(imgPath, "/")[[1]][c(4, 5, 6)]
  
  compositeMonthlyFolder = paste(compositeDataParent, pathSplits[1], pathSplits[2], sep = "/")
  
  # Create the composite folder if it does not exist
  if (!file.exists(compositeMonthlyFolder)) {
    dir.create(compositeMonthlyFolder, recursive = TRUE)
    cat("Folder created:", compositeMonthlyFolder, "\n")
  }
  
  pathSplits[3] = paste(strsplit(pathSplits[3], "\\.")[[1]][[1]], "tif", sep=".")

  compositeImgPath = paste(compositeMonthlyFolder, pathSplits[3], sep="/")
  
  return(compositeImgPath)
}



getCompositePaths = function(){
  compositeDataParent = "./data/composites"
  
  monthPaths = monthPathMaker(folderPrefix = compositeDataParent)
  
  img_paths = lapply(monthPaths, function(monthFolder){
    list.files(path=monthFolder, full.names = TRUE, pattern = "*.tif")})
  
  
  return(img_paths)

}

getMosaicPaths = function(compositePath){
  mosaicParent = "data/mosaics"
  pathSplits = strsplit(compositePath, "/")[[1]][c(4,5)]
  
  mosaicYearFolder = paste(mosaicParent, pathSplits[1], sep = "/")
  
  # Create the composite folder if it does not exist
  if (!file.exists(mosaicYearFolder)) {
    dir.create(mosaicYearFolder, recursive = TRUE)
    cat("Folder created:", mosaicYearFolder, "\n")
  }
  
  monthlyMosaicPath = paste(mosaicYearFolder, paste0(pathSplits[2], ".tif"), sep = "/")
  
  return(monthlyMosaicPath)}



