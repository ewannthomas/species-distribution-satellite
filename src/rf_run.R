
library(caTools)
library(jsonlite)
library(caTools)
library(tidyverse)
library(pROC)
library(caret)
library(randomForest)
library(nanoparquet)


mid_line_species = c(0, 1, 5, 6, 9)

low_line_species = c(2, 3, 4, 7, 8, 10)

for (target_specie in mid_line_species){
  for (control_specie in low_line_species){
    #Pre model processing
    source('./src/data_initiate.R')
    
    # Model initialization
    source('./src/model_initiate.R')
    
    #Post model processing
    source('./src/viz_data_prep.R')
  }
}

