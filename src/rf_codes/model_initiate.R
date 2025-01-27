

#Initiating the model call
set.seed(3456)
classifier_RF <- randomForest(x = trainData, 
                             y = trainLabels, 
                             type = "classification",
                             ntree = 100) 


save(classifier_RF, file = model_path)
print(classifier_RF)


# Predict outcomes with the test data
test_pred <- tibble(predict(classifier_RF, newdata = testData))
colnames(test_pred) <- c("predicted_probs")
test_pred <- test_pred %>% mutate(predicted_labels=as.numeric(test_pred$predicted_probs)-1)
test_pred <- test_pred %>% mutate(actual_labels=testLabels)


# confusion matrix of test set
cm <- confusionMatrix(factor(test_pred$predicted_labels),
                      factor(test_pred$actual_labels),
                      mode = "everything")

print(paste0("Target:",target_specie))
print(paste0("Control:", control_specie))
print(round(cm[["overall"]], digits=4))


#Saving instance and hyper parameters
current_time <- Sys.time()
timestamp_string <- format(current_time, "%Y-%m-%d %H:%M:%S")
overall_metrics <- cm[["overall"]]  # This assumes 'cm' is a confusionMatrix object

# Create a named list to hold the data
all_vals <- list(
  time = timestamp_string,
  target = target_specie,
  control = control_specie,
  accuracy = overall_metrics["Accuracy"],  # Example: add the accuracy metric
  kappa = overall_metrics["Kappa"],        # Add Kappa metric
  accuracy_lower = overall_metrics["AccuracyLower"],  # Lower bound of the accuracy
  accuracy_upper = overall_metrics["AccuracyUpper"],  # Upper bound of the accuracy
  accuracy_null = overall_metrics["AccuracyNull"],     # Null accuracy
  accuracy_pvalue = overall_metrics["AccuracyPValue"], # P-value for accuracy
  mcnemar_pvalue = cm[["mcnemar"]][["p.value"]]  # Assuming cm contains McNemar's test p-value
)

# Convert the list to a JSON string with pretty formatting
hypers <- toJSON(all_vals, pretty = TRUE)

# Write the JSON to the specified file
write(hypers, hypers_path)
