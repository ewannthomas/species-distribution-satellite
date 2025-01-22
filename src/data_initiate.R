
#  This scripts prepares the data for training by adding the observation weights and obtaining the train-test split.
# train = 98%
# test = 2%

#defining directories
path_root = paste0("./data/models/",target_specie, "_", control_specie, "/", target_specie, "_", control_specie)
data_path <- paste0(path_root,".parquet")
model_path <- paste0(path_root,"_model.bin")
viz_data_path = paste0(path_root,"_viz.csv")
hypers_path = paste0(path_root, "_hyper.json")

model_df <- read_parquet(data_path)


# Train - Test Split
sample <- sample.split(model_df$speciesID, SplitRatio = 0.98)
train_data  <- subset(model_df, sample == TRUE)
test_data   <- subset(model_df, sample == FALSE)

trainData <- train_data %>% select(-c("lat", "long",'speciesID'))
trainLabels <-as.factor(train_data$speciesID)
testData <- test_data %>% select(-c("lat", "long",'speciesID'))
testLabels <-as.factor(test_data$speciesID)

