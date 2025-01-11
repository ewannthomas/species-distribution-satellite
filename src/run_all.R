

externalDataSource = TRUE
years = seq(2020, 2020, 1)
months = seq(9, 12, 1)

#defining paths, libraries and utilities
source("./src/allPaths.R")
source("./src/utils.R")

#unzip all zipped scenes to the right folder
source("./src/unzipScenes.R")


#make sentinel point values
# source("./src/get_point_values.R")

# #making band composites and saving them
# source("./src/makeComposites.R")
# 
# #Making monthly mosaics and storing
# source("./src/makeMosaics.R")

