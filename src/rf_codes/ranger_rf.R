

library(caTools)
library(jsonlite)
library(caTools)
library(tidyverse)
library(pROC)
library(caret)
library(randomForest)
library(nanoparquet)
library(terra)

target_specie =12
control_specie = 13

#defining directories
path_root = paste0("./data/models/",target_specie, "_", control_specie, "/", target_specie, "_", control_specie)
data_path <- paste0(path_root,".parquet")
model_path <- paste0(path_root,"_model.bin")
viz_data_path = paste0(path_root,"_viz.csv")
hypers_path = paste0(path_root, "_hyper.json")

#defining precition tif
tiff_path_root = paste0("./data/prediction_tiff")
tiffs <- list.files(tiff_path_root, pattern = "*.tif", full.names = TRUE)


model_df <- read_parquet(data_path)


# Train - Test Split
sample <- sample.split(model_df$species, SplitRatio = 0.8)
train_data  <- subset(model_df, sample == TRUE)
test_data   <- subset(model_df, sample == FALSE)

trainData <- train_data %>% select(-c("lat", "long",'year'))
trainLabels <-as.factor(train_data$species)
testData <- test_data %>% select(-c("lat", "long",'year', "species"))
testLabels <-as.factor(test_data$species)

myControl <- trainControl(
  method = "cv", number = 10,
  verboseIter = TRUE
)

model_rf <- train(species ~., 
                  data = trainData, 
                  method='ranger',
                  splitrule = 'gini',
                  trControl = myControl)

save(model_rf, file = model_path)

p <- as_tibble(predict(model_rf,testData))
p <- p %>% mutate(predcited_class = ifelse(value > 0.5, 1, 0))
predicted_labels = as.factor(p$predcited_class)

confusionMatrix(predicted_labels,testLabels)


#####TIFF Prediction
pred_tiff = rast(tiffs[[1]])
  
# Rescale values to 0-1 range
min_val <- min(values(pred_tiff), na.rm = TRUE)
max_val <- max(values(pred_tiff), na.rm = TRUE)

pred_tiff_scaled <- (pred_tiff - min_val) / (max_val - min_val)
plot(pred_tiff_scaled)

tiff_predicted = terra::predict(pred_tiff_scaled, model_rf, na.rm=TRUE)
