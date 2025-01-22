from qgis.core import (
    QgsProject,
    QgsRasterLayer,
    QgsVectorLayer,
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
print(data_dir )

rast = raw_tifs[0]
# Input file paths
raster_path = str(raw_tifs[0])
mask_raster_path = str(data_dir.joinpath("ESA_HP_ClipExtent_Reclass.tif"))
masked_path = str(data_dir.joinpath("pred_points_nod.tif"))
centroid_shp_path = str(data_dir.joinpath("centroids/centroids.shp"))

# Load layers
raster_layer = QgsRasterLayer(raster_path, "Input Raster")
mask_layer = QgsRasterLayer(mask_raster_path, "Mask Raster")


# Function to clean and prepare output path
def final_path_cleaner(raw_path):
    final_stem = ".".join([raw_path.stem, "csv"])
    final_sub_path = str(raw_path).split("/")[8].replace(".SAFE", "")
    final_sub_path = final_folder.joinpath(final_sub_path)

    if not final_sub_path.exists():
        final_sub_path.mkdir(parents=True)

    final_path = final_sub_path.joinpath(final_stem)
    print(final_path) 


final_path_cleaner(raw_tifs[0])