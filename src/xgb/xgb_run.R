library(caTools)
library(xgboost)
library(dplyr)
library(caret)
library(nanoparquet)



#defining directories
target_specie =8
control_specie = 10

#defining directories
path_root = paste0("./data/models/",target_specie, "_", control_specie, "/", target_specie, "_", control_specie)
data_path <- paste0(path_root,".parquet")
model_path <- paste0(path_root,"_model.RData")


model_df <- read_parquet(data_path)
table(model_df$species)


# Train - Test Split
set.seed(3456)

sample <- sample.split(model_df$species, SplitRatio = 0.8)
train_data  <- subset(model_df, sample == TRUE)
test_data   <- subset(model_df, sample == FALSE)

trainData <- train_data %>% select(-c("lat", "long", 'year'))
trainData <- trainData %>% mutate(species = as.factor(species))
testData <- test_data %>% select(-c("lat", "long",'species', 'year'))
testLabels <-as.factor(test_data$species)
table(trainData$species)

## Define repeated cross validation with 5 folds and three repeats
repeat_cv <- trainControl(method='repeatedcv', number=10, verboseIter = TRUE)

tune_grid <- expand.grid(nrounds = 1000, 
                         max_depth = 2,  # Set max_depth to 2 for 5 trees
                         eta = c(0.01, 0.1, 0.3),
                         gamma = c(0, 1, 5),
                         colsample_bytree = c(0.5, 0.7, 1),
                         min_child_weight = c(1, 3, 5),
                         subsample = c(0.5, 0.7, 1))

PR_model_xgb <- train(species ~., 
                  data = trainData, 
                  method='xgbTree',
                  trControl = repeat_cv,
                  tuneGrid = tune_grid,
                  metric='Accuracy')


PR_model_xgb$finalModel


save(PR_model_xgb, file = model_path)

p <- predict(PR_model_xgb,testData)


confusionMatrix(p,testLabels)


