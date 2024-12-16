makeMosaics = function(){

  compositePaths = getCompositePaths()

  for (rasts in compositePaths){

    if (length(rasts)>0){

      monthlyMosaicPath = getMosaicPaths(rasts[1])

      if (!file.exists(monthlyMosaicPath)){
        cat("Composite for", monthlyMosaicPath, "\n")

        rastImgs = lapply(rasts, loadBands)

        merged = mosaic(x=c(rastImgs), fun="last")
        writeRaster(merged, monthlyMosaicPath, overwrite=TRUE)

      }
    }
  }
  cat("All Rasters have been mosaiced.")
}

makeMosaics()
