library(readr)
library(terra)
library(xml2)
library(tibble)
library(dplyr)
library(arrow)
library(stringr)

monthPathMaker = function(folderPrefix){
  
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
    
    zippedParent = list.files("/media/bippw1/Bhumi SSD", full.names = TRUE)[14]
  }
  
  print(zippedParent)
  
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


getS2BandPaths <- function(){
  
  # Return a list containing all s2 bands
  bandPaths = lapply(getDayFolders(), function(dayFolder){
    img_paths = list.files(path=dayFolder,full.names = TRUE, recursive = TRUE, pattern = "*B0.*.10m.jp2|*B0[5-8]_20m.jp2|*B11_20m.jp2|*B12_20m.jp2")
    
  })
  
  return(bandPaths)
}

getS1BandPaths <- function(){
  
  # Return a list containing all s1 bands
  bandPaths = lapply(getDayFolders(), function(dayFolder){
    img_paths = list.files(path=dayFolder,full.names = TRUE, recursive = TRUE, pattern = "*-vh.*.tiff$|*-vv.*.tiff$")
    
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


getS1TiffXml = function(tiffPath){
  newPath = sub(pattern ="measurement", replacement= "annotation", x = tiffPath)
  newPath = sub(pattern ="tiff", replacement= "xml", x = newPath)
  
  return(newPath)
}



getShpFilePath = function(shpFileStem){
  stemWithExt = paste(shpFileStem, "shp", sep=".")
  shpParent = "./data/shapes"
  
  shpPath = paste(shpParent, shpFileStem, stemWithExt, sep="/")
  
  return(shpPath)
}

sentinel1DFPath = function(imgPath){
  sent1Parent = "./data/dfs/sentinel_1"
  
  pathSplits = strsplit(imgPath, "/")[[1]][c(4,5,6,8)]

  sent1Folder = paste(c(sent1Parent, pathSplits[c(1,2,3)]), collapse = "/")
  
  sent1Folder = sub(pattern = ".SAFE", replacement = "", x=sent1Folder)
  
  sent1Stem = sub(pattern = ".tiff", replacement = ".parquet", x=pathSplits[4])
  
  sent1DFPath = paste(c(sent1Folder, sent1Stem), collapse = "/")
  
  # Create the df folder if it does not exist
  if (!file.exists(sent1Folder)) {
    dir.create(sent1Folder, recursive = TRUE)
    cat("Folder created:", sent1Folder, "\n")
  }

  return(sent1DFPath)

  
}
