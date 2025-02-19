import xgboost as xgb
import pandas as pd
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score
from pathlib import Path
from tqdm import tqdm 
import joblib



#defining directories
set_seed = 123
dir_path = Path.cwd()
data_folder = dir_path.joinpath("data/models")
training_data_path = data_folder.joinpath("subsetted_model_df.parquet")
model_path = data_folder.joinpath("xgb/xgb_all_species_subset_feats_500t.bin")


#reading in the model data frame
model_df = pd.read_parquet(training_data_path)


# Train-test split
X = model_df.drop(columns=["lat",'long','year','species'])
y = model_df["species"]
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=set_seed)

print(model_df.shape)


# Define the XGBoost classifier
xgb_clf = xgb.XGBClassifier(n_estimators=500,use_label_encoder=False, eval_metric="logloss", random_state=set_seed)

# Define the hyperparameter grid
param_grid = {
    "learning_rate": [0.01, 0.1, 0.2],
    'min_child_weight': [1, 5, 8],
    'gamma': [0, 0.1, 0.2, 0.5, 1]
}

# Perform Grid Search with 10-Fold Cross-Validation
# Adding a progress bar for the training process
with tqdm(total=1, desc="Hyperparameter tuning") as pbar:
    grid_search = GridSearchCV(xgb_clf, param_grid, cv=10, scoring="accuracy", n_jobs=-1, verbose=2)
    grid_search.fit(X_train, y_train)

# Get the best parameters and best model
best_params = grid_search.best_params_
best_model = grid_search.best_estimator_

print("Best Hyperparameters:", best_params)

# Evaluate on test set
y_pred = best_model.predict(X_test)
accuracy = accuracy_score(y_test, y_pred)
print(f"Test Set Accuracy: {accuracy:.4f}")

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