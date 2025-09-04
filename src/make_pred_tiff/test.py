import rasterio
from rasterio.merge import merge
from rasterio.warp import calculate_default_transform, reproject, Resampling
from pathlib import Path
import numpy as np

# Defining directories
dir_path = Path.cwd()
data_dir = dir_path.joinpath("data/qg/vh/Ascending")
raw_tifs = list(data_dir.rglob("*.tiff"))


# #Get a list of all raster files (modify the pattern if needed)

# #Open all rasters
# src_files = [rasterio.open(file) for file in raw_tifs]

# #Merge rasters
# mosaic, out_transform = merge(src_files)

# #Copy metadata from the first raster
# out_meta = src_files[0].meta.copy()
# out_meta.update({
#     "driver": "GTiff",
#     "height": mosaic.shape[1],
#     "width": mosaic.shape[2],
#     "transform": out_transform
# })

# #Save the mosaicked raster
# output_path = "data/mosaic.tif"
# with rasterio.open(output_path, "w", **out_meta) as dest:
#     dest.write(mosaic)
# band_index = 1  # Change if you want a different band


# print("Mosaic created successfully!")


# 📌 2. Define the target CRS (UTM Zone 43N)
target_crs = "EPSG:32643"  # UTM 43N (WGS 84)
# 📌 3. Open the input raster
with rasterio.open("data/test mosaic vh 3.tif") as src:
    # Get transform, width, and height for the new projection
    transform, width, height = calculate_default_transform(
        src.crs, target_crs, src.width, src.height, *src.bounds
    )

    band = src.read(1)  # Read the band as a NumPy array

    # 📌 2. Compute min and max (ignoring NoData values)
    if src.nodata is not None:
        band = band[band != src.nodata]  # Exclude NoData values

    min_val = np.min(band)
    max_val = np.max(band)
    print(min_val, max_val)

#     # Update metadata for the new raster
#     new_meta = src.meta.copy()
#     new_meta.update({
#         "crs": target_crs,
#         "transform": transform,
#         "width": width,
#         "height": height
#     })

#     # 📌 4. Create the output raster and reproject
#     with rasterio.open("data/io_reproj.tif", "w", **new_meta) as dst:
#             reproject(
#                 source=rasterio.band(src, 1),
#                 destination=rasterio.band(dst, 1),
#                 # src_transform=src.transform,
#                 # src_crs=src.crs,
#                 # dst_transform=transform,
#                 dst_crs=target_crs,
#                 resampling=Resampling.nearest  # Change method if needed
#             )

# # print("✅ Reprojection complete: Saved to", output_tiff)


# from qgis.core import QgsRasterLayer, QgsProcessingFeedback, QgsProcessingContext, QgsProject, QgsCoordinateReferenceSystem
# from qgis import processing

# # Define file paths
# input_raster = "/path/to/your/input_raster.tif"  # Change this to your raster path
# output_raster = "/path/to/your/output_raster_utm43N.tif"  # Change to desired output path

# # Load the raster layer
# raster_layer = QgsRasterLayer(input_raster, "Input Raster")

# # Check if the raster layer is valid
# if not raster_layer.isValid():
#     print("Error: Invalid raster. Check the file path.")
# else:
#     print("Raster loaded successfully.")

#     # Define the reprojection parameters
#     params = {
#         'INPUT': raster_layer,
#         'TARGET_CRS': 'EPSG:32643',  # UTM Zone 43N
#         'RESAMPLING': 0,  # Nearest neighbor resampling (change as needed)
#         'NODATA': None,  # Keep existing NoData values
#         'DATA_TYPE': 0,  # Keep the same data type
#         'OUTPUT': output_raster
#     }

#     # Run the reprojection
#     feedback = QgsProcessingFeedback()
#     processing_context = QgsProcessingContext()

#     try:
#         result = processing.run(
#             "gdal:warpreproject",
#             params,
#             context=processing_context,
#             feedback=feedback
#         )

#         if result['OUTPUT']:
#             print(f"Reprojected raster saved at: {output_raster}")
#             # Load the output raster into the QGIS project
#             QgsProject.instance().addMapLayer(QgsRasterLayer(output_raster, "Reprojected Raster"))
#         else:
#             print("Error: Reprojection failed.")
#     except Exception as e:
#         print(f"Error during processing: {e}")


# processing.run(
#     "gdal:warpreproject",
#     {
#         "INPUT": "/tmp/processing_HTbTVe/6b92a9cf027746b085f78d41937c48fc/OUTPUT.tif",
#         "SOURCE_CRS": QgsCoordinateReferenceSystem("EPSG:4326"),
#         "TARGET_CRS": QgsCoordinateReferenceSystem("EPSG:32643"),
#         "RESAMPLING": 0,
#         "NODATA": None,
#         "TARGET_RESOLUTION": 10,
#         "OPTIONS": None,
#         "DATA_TYPE": 0,
#         "TARGET_EXTENT": None,
#         "TARGET_EXTENT_CRS": None,
#         "MULTITHREADING": False,
#         "EXTRA": "",
#         "OUTPUT": "TEMPORARY_OUTPUT",
#     },
# )


# def band_maker(raw_file_path):
#     month, band_name, orbit = str(raw_file_path).split("/")[8:11]

#     if month in ["3", "4", "5"]:
#         season = 'summer'
#     elif month in ["10", "11", "12"]:
#         season = 'winter'

#     final_band_name = band_name + "_" + orbit + season

#     return final_band_name


{
    "DATA_TYPE": 2,
    "EXTRA": "",
    "INPUT": [
    ],
    "NODATA_INPUT": 0,
    "NODATA_OUTPUT": None,
    "OPTIONS": None,
    "OUTPUT": "TEMPORARY_OUTPUT",
    "PCT": False,
    "SEPARATE": False,
}



feature_order = c('vv_Descendingsummer',
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
                  'phh2o_f', 'soc_f', 'slope', 'clay_f', 'nitrogen_f', 'cec_f', 'bdod_f', 
                  'aspect', 'silt_f', 'ocd_f')

