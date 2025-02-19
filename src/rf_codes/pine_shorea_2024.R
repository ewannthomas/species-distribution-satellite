

library(caTools)
library(dplyr)
library(caret)
library(nanoparquet)

target_specie =8
control_specie = 12

#defining directories
path_root = paste0("./data/models/2024/",target_specie, "_", control_specie, "/", target_specie, "_", control_specie)
data_path <- paste0(path_root,".parquet")
model_path <- paste0(path_root,"_model.RData")


model_df <- read_parquet(data_path)
table(model_df$species)

# Train - Test Split
sample <- sample.split(model_df$species, SplitRatio = 0.8)
train_data  <- subset(model_df, sample == TRUE)
test_data   <- subset(model_df, sample == FALSE)

trainData <- train_data %>% select(-c("lat", "long"))
trainData <- trainData %>% mutate(species = as.factor(species))
testData <- test_data %>% select(-c("lat", "long","species"))
testLabels <-as.factor(test_data$species)



#defining CV params
## Set seed for reproducibility
set.seed(123)

## Define repeated cross validation with 5 folds and three repeats
repeat_cv <- trainControl(method='repeatedcv', number=10, repeats=5)



PS_model_rf <- train(species ~., 
                  data = trainData, 
                  method='rf',
                  trControl = repeat_cv,
                  ntree = 100,
                  maxnodes = 2,
                  metric='Accuracy')

PS_model_rf$finalModel
PS_model_rf$results


save(PS_model_rf, file = model_path)

p <- predict(PS_model_rf,testData)


confusionMatrix(p,testLabels)


