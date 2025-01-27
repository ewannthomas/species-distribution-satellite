# Load necessary libraries
library(dplyr)
library(readr)

# Define the column names
col_names <- c('lat', 'long', 'actual', 'predicted', 'data_type')

# Prepare the train visualization data
train_viz_data <- train_data %>%
  select(lat, long, species) %>%
  mutate(
    actual = train_data$species,  # Assuming 'species' is the 'actual' column
    predicted = as.numeric(classifier_RF[["predicted"]]) - 1,
    data_type = "train",
    new = paste(actual, predicted, data_type, sep = "_")  # Concatenate 'actual', 'predicted', 'data_type' as a single string
  )

# Prepare the test visualization data
test_viz_data <- test_data %>%
  select(lat, long, species) %>%
  mutate(
    actual = test_data$species,  # Assuming 'species' is the 'actual' column
    predicted = test_pred$predicted_labels,  # Assuming 'predicted_labels' is a column in the test prediction object
    data_type = "test",
    new = paste(actual, predicted, data_type, sep = "_")  # Concatenate 'actual', 'predicted', 'data_type' as a single string
  )

# Combine the train and test data
data_4_viz <- bind_rows(train_viz_data, test_viz_data)

# Write the combined data to a CSV file
write_csv(data_4_viz, viz_data_path, na = "")
