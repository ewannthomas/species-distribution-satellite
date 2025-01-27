from qgis.core import (
    QgsProject,
    QgsRasterLayer,
    QgsProcessingFeedback,
    QgsProcessingContext,
)
from qgis.analysis import QgsRasterCalculatorEntry
from qgis import processing
import numpy as np
from pathlib import Path


# Defining directories
dir_path = Path.cwd()
work_dir = dir_path.joinpath("bipp/ncount/sentinel-2-grab")
data_dir = work_dir.joinpath("data")
final_folder = data_dir.parent.joinpath("qg")
raw_tifs = list(data_dir.rglob("*.tiff"))
final_folder = data_dir.parent.joinpath("qg")

rast = raw_tifs[0]
# Input file paths
raster_path = str(raw_tifs[0])
mask_raster_path = str(data_dir.joinpath("ESA_HP_ClipExtent_Reclass.tif"))
masked_path = str(data_dir.joinpath("pred_points_nod.tif"))

# Load layers
raster_layer = QgsRasterLayer(raster_path, "Input Raster")
mask_layer = QgsRasterLayer(mask_raster_path, "Mask Raster")


# Function to clean and prepare output path
def final_path_cleaner(raw_path):
    final_stem = ".".join([raw_path.stem, "csv"])
    final_sub_path = "/".join(str(raw_path).split("/")[8:11]).replace(".SAFE", "")
    final_sub_path = final_folder.joinpath(final_sub_path)

    if not final_sub_path.exists():
        final_sub_path.mkdir(parents=True)

    final_path = final_sub_path.joinpath(final_stem)
    return final_path


# function to make dates out of final path names
def datemaker(df_path):

    date_stem = str(df_path).split("-")[6].split("t")[0]

    year_val = date_stem[0:4]
    month_val = date_stem[4:6]
    day_val = date_stem[6:8]

    date_val = "-".join([year_val, month_val, day_val])

    return date_val


def band_maker(df_path):
    band_val = str(df_path).split("-")[5]

    return band_val


def orbit_maker(raw_path):
    tiff_stem = raw_path.stem
    parents_raw = raw_path.parents[1]
    parents_raw = parents_raw.joinpath("annotation")

    xml_file_path = list(parents_raw.glob(f"{tiff_stem}.xml"))[0]

    with open(xml_file_path, "rb") as xml_file:
        xml_vals = str(xml_file.readlines()[82])[14:24]

    if xml_vals == "Descending":
        return xml_vals
    elif xml_vals == "Ascending<":
        xml_vals = "Ascending"
        return xml_vals
    else:
        print("Unrecognized Orbit Parameter received.")
        print(str(raw_path))


def output_logger(raw_path):
    final_stem = raw_path.stem
    final_sub_path = "/".join(str(raw_path).split("/")[8:11]).replace(".SAFE", "")

    out_dict = {"source_folder": final_sub_path, "source_file": final_stem}

    print(out_dict)


if not raster_layer.isValid() or not mask_layer.isValid():
    print("Error: Failed to load layers. Check the file paths.")
else:
    # Define the extent from the input raster
    extent = raster_layer.extent()
    rast_width = raster_layer.width()
    rast_height = raster_layer.height()

    # Set NoData value for mask raster
    # raster_layer.dataProvider().setNoDataValue(1, 0)
    # raster_layer.triggerRepaint()
    mask_layer.dataProvider().setNoDataValue(1, 128)
    mask_layer.triggerRepaint()

    entries = []
    # Entering raste rprocess

    ras = QgsRasterCalculatorEntry()
    ras.ref = "ras@1"
    ras.raster = raster_layer
    ras.bandNumber = 1
    entries.append(ras)

    ras = QgsRasterCalculatorEntry()
    ras.ref = "ras@2"
    ras.raster = mask_layer
    ras.bandNumber = 1
    entries.append(ras)

    calc = QgsRasterCalculator(
        "ras@1 * ras@2", masked_path, "GTiff", extent, rast_width, rast_height, entries
    )

    calc.processCalculation()

    masked_layer = QgsRasterLayer(masked_path, "Masked Raster")

    if masked_layer.isValid():

        masked_layer_extent = masked_layer.extent()
        masked_layer_width = masked_layer.width()
        masked_layer_height = masked_layer.height()

        masked_layer_provider = masked_layer.dataProvider()

        # Assuming you want to read the first band (band indices in QGIS start from 1)
        band_number = 1

        # Extract raster data as a numpy array (or raw data)
        block = masked_layer_provider.block(band_number, masked_layer_extent, masked_layer_width, masked_layer_height)

        # Convert the block to a numpy array if needed (requires numpy)
        masked_layer_data = np.array(block.data()).reshape(masked_layer_height, masked_layer_width)

        print(masked_layer_data)
        
        # Extract raster values and write to CSV
        final_path = final_path_cleaner(rast)

        date_val = datemaker(final_path)

        band_name = band_maker(final_path)

        orbit_path = orbit_maker(rast)

        with open(final_path, "w") as csv_file:
            csv_file.write(
                f"date,long,lat,orbit_path,{band_name}\n"
            )  # Header

        # Loop through all the pixels and write to CSV
        for row in range(masked_layer_height):
            for col in range(masked_layer_width):
                pixel_value = masked_layer_data[row, col]
                if pixel_value !=0:
                    # Get pixel coordinates in the raster's CRS
                    x, y = raster_layer.dataProvider().coordinateTransform().mapPixelToCoord(col, row)

                    csv_file.write(f"{date_val},{x()},{y()},{orbit_path},{pixel_value}\n")

                    
    else:
        print("Masked Layer is invalid")
