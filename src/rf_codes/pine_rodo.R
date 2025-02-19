

library(caTools)
library(jsonlite)
library(caTools)
library(dplyr)
library(caret)
library(nanoparquet)
library(terra)

target_specie =8
control_specie = 10

#defining directories
path_root = paste0("./data/models/",target_specie, "_", control_specie, "/", target_specie, "_", control_specie)
data_path <- paste0(path_root,".parquet")
model_path <- paste0(path_root,"_model.bin")
viz_data_path = paste0(path_root,"_viz.csv")
hypers_path = paste0(path_root, "_hyper.json")



model_df <- read_parquet(data_path)
model_df <- model_df[1:1000,]


# Train - Test Split
sample <- sample.split(model_df$species, SplitRatio = 0.8)
train_data  <- subset(model_df, sample == TRUE)
test_data   <- subset(model_df, sample == FALSE)

trainData <- train_data %>% select(-c("lat", "long",'year'))
trainData <- trainData %>% mutate(species = as.factor(species))
testData <- test_data %>% select(-c("lat", "long",'year', "species"))
testLabels <-as.factor(test_data$species)



#defining CV params
## Set seed for reproducibility
set.seed(123)

## Define repeated cross validation with 5 folds and three repeats
repeat_cv <- trainControl(method='repeatedcv', number=2, repeats=1)



model_rf <- train(species ~., 
                  data = trainData, 
                  method='rf',
                  trControl = repeat_cv,
                  ntree = 1000,
                  maxnodes = 5,
                  metric='Accuracy')

model_rf$finalModel


save(model_rf, file = model_path)

p <- predict(model_rf,testData)


confusionMatrix(p,testLabels)


