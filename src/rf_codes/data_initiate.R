
#  This scripts prepares the data for training by adding the observation weights and obtaining the train-test split.
# train = 80%
# test = 20%

#defining directories
path_root = paste0("./data/models/",target_specie, "_", control_specie, "/", target_specie, "_", control_specie)
data_path <- paste0(path_root,".parquet")
model_path <- paste0(path_root,"_model.bin")
viz_data_path = paste0(path_root,"_viz.csv")
hypers_path = paste0(path_root, "_hyper.json")

model_df <- read_parquet(data_path)


# Train - Test Split
sample <- sample.split(model_df$species, SplitRatio = 0.8)
train_data  <- subset(model_df, sample == TRUE)
test_data   <- subset(model_df, sample == FALSE)

trainData <- train_data %>% select(-c("lat", "long",'species', 'year'))
trainLabels <-as.factor(train_data$species)
testData <- test_data %>% select(-c("lat", "long",'species', 'year'))
testLabels <-as.factor(test_data$species)

