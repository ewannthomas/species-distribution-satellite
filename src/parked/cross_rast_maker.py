from qgis.core import (
    QgsProject,
    QgsRasterLayer,
    QgsProcessingFeedback,
    QgsProcessingContext
)


from qgis.analysis import QgsRasterCalculatorEntry
from qgis import processing
from pathlib import Path

# Defining directories
dir_path = Path.cwd()
work_dir = dir_path.joinpath("bipp/ncount/sentinel-2-grab")
data_dir = work_dir.joinpath("data")

# Input file paths
raster_path = str(data_dir.joinpath("s1a-iw-grd-vh-20240911t004336-20240911t004401-055610-06c9e2-002.tiff"))
mask_raster_path = str(data_dir.joinpath("ESA_HP_ClipExtent_Reclass.tif"))
output_csv_path = str(data_dir.joinpath('pred_points_nod.tif'))

# Load layers
raster_layer = QgsRasterLayer(raster_path, "Input Raster")
mask_layer = QgsRasterLayer(mask_raster_path, "Mask Raster")

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
    # mask_layer.dataProvider().setNoDataValue(1, 128)
    # mask_layer.triggerRepaint()
    
    entries = []
    # Entering raste rprocess
    
    ras = QgsRasterCalculatorEntry()
    ras.ref = 'ras@1'
    ras.raster = raster_layer
    ras.bandNumber = 1
    entries.append(ras)
    
    ras = QgsRasterCalculatorEntry()
    ras.ref = 'ras@2'
    ras.raster = mask_layer
    ras.bandNumber = 1
    entries.append(ras)
    
    calc = QgsRasterCalculator('ras@1 * ras@2', output_csv_path, 'GTiff', extent, \
    rast_width, rast_height, entries)
    
    calc.processCalculation()


