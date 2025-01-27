
library(caTools)
library(jsonlite)
library(caTools)
library(tidyverse)
library(pROC)
library(caret)
library(randomForest)
library(nanoparquet)


west_low_species = c(12,11,8,7,6,5,4,3,1)

mid_line_species = c(13,10,9,2,0)

for (target_specie in west_low_species){
  for (control_specie in mid_line_species){
    #Pre model processing
    source('./src/rf_codes/data_initiate.R')
    
    # Model initialization
    source('./src/rf_codes/model_initiate.R')
    
    #Post model processing
    source('./src/rf_codes/viz_data_prep.R')
  }
}

