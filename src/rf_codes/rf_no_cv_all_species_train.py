import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score
from pathlib import Path
from tqdm import tqdm 
import joblib


#defining directories
set_seed = 123
dir_path = Path.cwd()
data_folder = dir_path.joinpath("data/models")
training_data_path = data_folder.joinpath("model_df_year_subset.parquet")
model_path = data_folder.joinpath("all_species_subset_year_py_1n_500t.bin")


#reading in the model data frame
model_df = pd.read_parquet(training_data_path)


# Train-test split
X = model_df.drop(columns=["lat",'long','year','species'])
y = model_df["species"]
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=set_seed)

print(model_df.shape)

rf = RandomForestClassifier(random_state=set_seed,
                            n_estimators=500,
                            bootstrap= False, 
                            max_depth = None, 
                            min_samples_leaf = 1, 
                            min_samples_split = 2
                            )
 
# Adding a progress bar for the training process
with tqdm(total=1, desc="Hyperparameter tuning") as pbar:
    rf.fit(X_train, y_train)
    pbar.update(1)

 
# Predict the test set
y_pred = rf.predict(X_test)
 
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
    joblib.dump(rf, file)