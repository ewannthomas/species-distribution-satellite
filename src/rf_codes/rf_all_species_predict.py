import pandas as pd
from pathlib import Path
import rasterio
from rasterio.windows import Window
from tqdm import tqdm 
import joblib
import numpy as np

# defining variables

set_seed = 123
chunk_size = 512


#defining directories
dir_path = Path.cwd()
data_folder = dir_path.joinpath("data/models")
tiff_folder = dir_path.joinpath("data/species_predicted_tiffs")
model_path = data_folder.joinpath("all_species_py_old.bin")
input_raster_path = dir_path.joinpath("data/prediction_tiff/pred_stack.tif")
predicted_raster_path = tiff_folder.joinpath("all_species_py_old.tif")


# reading the model
with open(model_path, 'rb') as file:
    loaded_rf = joblib.load(file)

# print(loaded_rf)

#reading in the input raster
feat_rast_input =  rasterio.open(input_raster_path)
feature_names = feat_rast_input.descriptions
# print(feature_names)

# #     print('File Name:', feat_rast_input.name)
# #     print('Mode:', feat_rast_input.mode)
# #     print('Width:', feat_rast_input.width)
# #     print('Height:', feat_rast_input.height)
# #     print('Coordinate Reference System:', feat_rast_input.crs)
# #     print('Transform:', feat_rast_input.transform)



# Function to predict and save a new raster in chunks with progress bar
def predict_new_raster_chunked(model, input_raster, predcited_rast, chunk_size):

    profile = input_raster.profile
    profile.update(dtype=rasterio.float64, count=1)  # Use float64 for larger NoData value

    rows, cols = input_raster.shape
    nodata_value = input_raster.nodata  # Get the no-data value from the raster 
 
      # Counter to track the number of DataFrames printed
    printed_chunks = 0
    max_chunks_to_print = 3  # Number of chunk DataFrames to print
 
    # Create a progress bar for chunk processing
    with rasterio.open(predcited_rast, 'w', **profile) as dst:
        total_chunks = (rows // chunk_size + 1) * (cols // chunk_size + 1)
        with tqdm(total=total_chunks, desc="Predicting in chunks") as pbar:
            for row_start in range(0, rows, chunk_size):
                for col_start in range(0, cols, chunk_size):
                    row_end = min(row_start + chunk_size, rows)
                    col_end = min(col_start + chunk_size, cols)
 
                    # Prepare a window for the current chunk
                    window = Window(col_start, row_start, col_end - col_start, row_end - row_start)
                    data = input_raster.read(window=window)

                    # Mask the no-raw_data value
                    if nodata_value is not None:
                        data[data == nodata_value] = np.nan  # Set no-raw_data pixels to NaN

                    # Reshape the data to a 2D array: (num_bands, num_rows * num_cols)
                    num_bands, num_rows, num_cols = data.shape
                    reshaped_data = data.reshape(num_bands, num_rows * num_cols)

                    # Transpose the array to get shape: (num_rows * num_cols, num_bands)
                    transposed_data = reshaped_data.T

                    chunk_features = np.array(transposed_data)

                    predictions = np.full(chunk_features.shape[0], np.nan, dtype=np.float64)  # Use float64 for predictions
 
                    # Convert chunk features to a DataFrame with feature names
                    chunk_features_df = pd.DataFrame(chunk_features, columns=feature_names)

                    # print(chunk_features_df)
                
 
                    # Identify valid pixels (pixels that are not NaN)
                    valid_pixels = np.isfinite(chunk_features_df).all(axis=1)  # Exclude NaN values (no-data pixels) 
 
                    # Print the chunk only if it has valid values
                    if np.any(valid_pixels) and printed_chunks < max_chunks_to_print:
                        print(f"Chunk DataFrame #{printed_chunks + 1} with valid values:")
                        print(chunk_features_df[valid_pixels].head())  # Print only valid rows
                        printed_chunks += 1
 
                   
                    if np.any(valid_pixels):
                        predictions[valid_pixels] = model.predict(chunk_features_df[valid_pixels])
 
                    # Reshape predictions to match the chunk size and write to output
                    predicted_chunk = predictions.reshape((row_end - row_start, col_end - col_start))
                    dst.write(predicted_chunk, 1, window=window)
 
                    pbar.update(1)  # Update progress bar
 
 


predict_new_raster_chunked(loaded_rf, feat_rast_input, predicted_raster_path, chunk_size)
