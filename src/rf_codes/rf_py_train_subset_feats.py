import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score
from pathlib import Path
from tqdm import tqdm 
import joblib

# defining variables
set_seed = 123

#defining directories
dir_path = Path.cwd()
data_folder = dir_path.joinpath("data/processed")
training_data_path = data_folder.joinpath("subsetted_model_df.parquet")
model_path = dir_path.joinpath("data/models/all_species_subset_feats.bin")


#reading in the model data frame
model_df = pd.read_parquet(training_data_path)

print(model_df)


# Train-test split
X = model_df.drop(columns=["lat",'long','year','species'])
y = model_df["species"]
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=set_seed)


# Hyperparameter tuning for Random Forest with progress bar
param_grid = {
    'n_estimators': [100, 200, 500],
    'max_depth': [10, 20, None],
    'min_samples_split': [2, 5, 10],
    'min_samples_leaf': [1, 2, 4],
    'bootstrap': [True, False]
}
rf = RandomForestClassifier(random_state=set_seed)
grid_search = GridSearchCV(estimator=rf, param_grid=param_grid, cv=5, n_jobs=4, verbose=2)
 
# Adding a progress bar for the training process
with tqdm(total=1, desc="Hyperparameter tuning") as pbar:
    grid_search.fit(X_train, y_train)
    pbar.update(1)
 
# Best model
best_model = grid_search.best_estimator_
print(f"Best Parameters: {grid_search.best_params_}")
print(f"Model Accuracy: {best_model.score(X_test, y_test):.2f}")
 
# Predict the test set
y_pred = best_model.predict(X_test)
 
# Overall Accuracy
overall_accuracy = accuracy_score(y_test, y_pred)
print(f"Overall Model Accuracy: {overall_accuracy:.2f}")
 
# Confusion Matrix
conf_matrix = confusion_matrix(y_test, y_pred)
print("Confusion Matrix:")
print(conf_matrix)
 
# Detailed Classification Report
class_names = list(map(str, y.unique()))  # Ensure class names are strings
class_report = classification_report(y_test, y_pred, target_names=class_names)
print("Classification Report:")
print(class_report)
 
# Class-Wise Accuracy
class_accuracies = conf_matrix.diagonal() / conf_matrix.sum(axis=1)  # Diagonal/row sums
print("\nClass-Wise Accuracy:")
for class_name, accuracy in zip(class_names, class_accuracies):
    print(f"Class {class_name} Accuracy: {accuracy:.2f}")


# Save the model
with open(model_path, 'wb') as file:
    joblib.dump(best_model, file)