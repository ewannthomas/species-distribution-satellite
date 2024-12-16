
makeComposites = function(){
  bandPaths = getBandPaths()
  
  for (resBandPaths in bandPaths){
    
    monthImagePath = getMonthPath(resBandPaths[1])
    
    if (!file.exists(monthImagePath)){
      cat("Composite for", monthImagePath, "\n")
      
      bandImgs = lapply(resBandPaths, loadBands)
      
      imgToBeResampled = seq(5,9,1)

      resamplesImgs = lapply(imgToBeResampled, function(lowResImg){
        highResImg = resample(bandImgs[[lowResImg]], bandImgs[[1]], threads=TRUE)
      })

      stacked = rast(c(bandImgs[seq(1,4,1)], resamplesImgs))

      # stacked = rast(bandImgs)
      
      writeRaster(stacked, monthImagePath, overwrite=TRUE)
      
    }
  }
  cat("All composites have been created.")
}

makeComposites()



