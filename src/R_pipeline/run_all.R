

externalDataSource = TRUE
years = seq(2024, 2024, 1)
months = seq(4, 4, 1)
# months = c(3, 5, 6, 7, 8, 9)

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

