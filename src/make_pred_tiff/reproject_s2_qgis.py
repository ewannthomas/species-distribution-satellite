from qgis.core import (
    QgsRasterLayer,
    QgsCoordinateReferenceSystem,
)
from qgis import processing
from pathlib import Path

# Define directories
dir_path = Path.cwd()
work_dir = dir_path.joinpath("bipp/ncount/sentinel-2-grab")
data_dir = work_dir.joinpath("data/qg")
raw_tifs = list(data_dir.rglob("**/*.jp2"))
final_folder = data_dir.parent.joinpath("reprojected")


# Function to clean and prepare output path
def final_path_cleaner(raw_file_path):
    final_path = str(raw_file_path).replace("qg", "reprojected").replace(".jp2", ".tiff")
    final_file_folder = Path(final_path).parent
    final_file_folder.mkdir(parents=True, exist_ok=True)  # Ensure the directory exists
    return final_path


for input_raster in raw_tifs:  # Process first two rasters

    out_path = final_path_cleaner(input_raster)

    print(out_path)

    # Load the raster layer
    raster_layer = QgsRasterLayer(str(input_raster), "Input Raster")

    # Check if the raster layer is valid
    if not raster_layer.isValid():
        print(f"Error: Invalid raster {input_raster}. Check the file path.")
        continue  # Skip this iteration

    # Get the NoData value of the first band
    raster_data_provider = raster_layer.dataProvider()
    no_data_value = raster_data_provider.sourceNoDataValue(1)  # Get NoData for Band 1

    crs_val = str(raster_layer.crs().authid())

    # Run the reprojection
    try:
        result = processing.run(
            "gdal:warpreproject",
            {
                "INPUT": raster_layer,  # Pass path instead of QgsRasterLayer
                "SOURCE_CRS": QgsCoordinateReferenceSystem(crs_val),
                "TARGET_CRS": QgsCoordinateReferenceSystem("EPSG:32643"),
                "RESAMPLING": 0,  # Nearest neighbor
                "NODATA": no_data_value,
                "TARGET_RESOLUTION": 10,
                "OPTIONS": None,
                "DATA_TYPE": 3,  # Unsigned 16-bit integer
                "TARGET_EXTENT": None,
                "TARGET_EXTENT_CRS": None,
                "MULTITHREADING": False,
                "EXTRA": "",
                "OUTPUT": out_path,
            },
        )

        if result["OUTPUT"]:
            print(f"Reprojected raster saved at: {out_path}")
        else:
            print("Error: Reprojection failed.")

    except Exception as e:
        print(f"Error during processing: {e}")

