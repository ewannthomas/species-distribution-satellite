

library(caTools)
library(dplyr)
library(caret)
library(nanoparquet)


#defining directories
path_root = paste0("./data/models/")
data_path <- paste0(path_root,"model_df.parquet")
model_path <- paste0(path_root,"all_species_rf.RData")


model_df <- read_parquet(data_path)
table(model_df$species)

# Train - Test Split
sample <- sample.split(model_df$species, SplitRatio = 0.8)
train_data  <- subset(model_df, sample == TRUE)
test_data   <- subset(model_df, sample == FALSE)

trainData <- train_data %>% select(-c("lat", "long",'year'))
trainData <- trainData %>% mutate(species = as.factor(species))
testData <- test_data %>% select(-c("lat", "long",'year', "species"))
testLabels <-as.factor(test_data$species)

table(trainData$species)

#defining CV params
## Set seed for reproducibility
set.seed(123)

## Define repeated cross validation with 5 folds and three repeats
repeat_cv <- trainControl(method='repeatedcv', number=10, repeats=5)



PS_model_rf <- train(species ~., 
                     data = trainData, 
                     method='rf',
                     trControl = repeat_cv,
                     ntree = 500,
                     maxnodes = 5,
                     metric='Accuracy')

PS_model_rf$finalModel
PS_model_rf$results


save(PS_model_rf, file = model_path)

p <- predict(PS_model_rf,testData)


confusionMatrix(p,testLabels)


