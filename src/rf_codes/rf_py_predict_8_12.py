import pandas as pd
from pathlib import Path
import rasterio
from rasterio.windows import Window
from tqdm import tqdm 
import joblib
import numpy as np

# defining variables
target = str(8)
control = str(12)
set_seed = 123
specie_folder = target + "_" + control
model_stem = target + "_" + control + "_py" + ".bin"
tiff_stem = target + "_" + control + "_py" + ".tif"
chunk_size = 512


#defining directories
dir_path = Path.cwd()
data_folder = dir_path.joinpath("data/models")
tiff_folder = dir_path.joinpath("data/species_predicted_tiffs")
model_path = data_folder.joinpath(f"{specie_folder}/{model_stem}")
input_raster_path = dir_path.joinpath("data/prediction_tiff/pred_stack.tif")
predicted_raster_path = tiff_folder.joinpath(f"{tiff_stem}")



feature_order = ['vv_Descendingsummer',
       'vv_Descendingwinter', 'vh_Descendingsummer', 'vh_Descendingwinter',
       'vv_Ascendingsummer', 'vv_Ascendingwinter', 'vh_Ascendingsummer',
       'vh_Ascendingwinter', 'VV_VH_Asummer', 'VV_VH_Awinter', 'VV_VH_Dsummer',
       'VV_VH_Dwinter', 'VH_VV_Asummer', 'VH_VV_Awinter', 'VH_VV_Dsummer',
       'VH_VV_Dwinter', 'SAR_NDVI_Asummer', 'SAR_NDVI_Awinter',
       'SAR_NDVI_Dsummer', 'SAR_NDVI_Dwinter', 'DVI_Asummer', 'DVI_Awinter',
       'DVI_Dsummer', 'DVI_Dwinter', 'SVI_Asummer', 'SVI_Awinter',
       'SVI_Dsummer', 'SVI_Dwinter', 'RDVI_Asummer', 'RDVI_Awinter',
       'RDVI_Dsummer', 'RDVI_Dwinter', 'NRDVI_Asummer', 'NRDVI_Awinter',
       'NRDVI_Dsummer', 'NRDVI_Dwinter', 'SSDVI_Asummer', 'SSDVI_Awinter',
       'SSDVI_Dsummer', 'SSDVI_Dwinter', 'B11summer', 'B11winter', 'B02summer',
       'B02winter', 'B12summer', 'B12winter', 'B08summer', 'B08winter',
       'B04summer', 'B04winter', 'B03summer', 'B03winter', 'NDVIsummer',
       'NDVIwinter', 'ARVI2summer', 'ARVI2winter', 'BWDRVIsummer',
       'BWDRVIwinter', 'CVIsummer', 'CVIwinter', 'CTVIsummer', 'CTVIwinter',
       'EVI2summer', 'EVI2winter', 'GVMIsummer', 'GVMIwinter',
       'MSVAIhypersummer', 'MSVAIhyperwinter', 'MTVI2summer', 'MTVI2winter',
       'MNDVIsummer', 'MNDVIwinter', 'OSAVIsummer', 'OSAVIwinter', 'PVIsummer',
       'PVIwinter', 'SARVIsummer', 'SARVIwinter', 'SLAVIsummer', 'SLAVIwinter',
       'TSAVI2summer', 'TSAVI2winter', 'WDVIsummer', 'WDVIwinter',
       'WDRVIsummer', 'WDRVIwinter', 'sand_f', 'elevation', 'cfvo_f',
       'phh2o_f', 'soc_f', 'slope', 'clay_f', 'nitrogen_f', 'cec_f', 'bdod_f', 'aspect', 'silt_f', 'ocd_f']

# reading the model
with open(model_path, 'rb') as file:
    loaded_rf = joblib.load(file)


with rasterio.open(input_raster_path) as dataset:
#     print('File Name:', dataset.name)
#     print('Mode:', dataset.mode)
    band_descriptions =  dataset.descriptions
#     print('Width:', dataset.width)
#     print('Height:', dataset.height)
#     print('Coordinate Reference System:', dataset.crs)
#     print('Transform:', dataset.transform)



# Function to predict and save a new raster in chunks with progress bar
def predict_new_raster_chunked(model, input_rast, predcited_rast, chunk_size):
    with rasterio.open(input_rast) as src:
        profile = src.profile
        profile.update(dtype=rasterio.float64, count=1)  # Use float64 for larger NoData value
 
        rows, cols = src.shape
        nodata_value = src.nodata  # Get the no-data value from the raster
        
        feature_names = src.descriptions
 
 
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
                    with rasterio.open(input_rast) as src:
                        band_holder = []
                        for band_name in feature_order:
                            band_index = band_descriptions.index(band_name) + 1
                            raw_data = src.read(band_index, window=window)

                            # Mask the no-raw_data value
                            if nodata_value is not None:
                                raw_data[raw_data == nodata_value] = np.nan  # Set no-raw_data pixels to NaN

                            band_holder.append(raw_data)
                    
                    data = np.stack(band_holder)

                    # Reshape the data to a 2D array: (num_bands, num_rows * num_cols)
                    num_bands, num_rows, num_cols = data.shape
                    reshaped_data = data.reshape(num_bands, num_rows * num_cols)

                    # Transpose the array to get shape: (num_rows * num_cols, num_bands)
                    transposed_data = reshaped_data.T

                    chunk_features = np.array(transposed_data)

                    predictions = np.full(chunk_features.shape[0], np.nan, dtype=np.float64)  # Use float64 for predictions
 
                    # Convert chunk features to a DataFrame with feature names
                    chunk_features_df = pd.DataFrame(chunk_features, columns=feature_names)
                
 
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
 
 


predict_new_raster_chunked(loaded_rf, input_raster_path, predicted_raster_path, chunk_size)
