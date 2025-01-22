from qgis.core import (
    QgsProject,
    QgsRasterLayer,
    QgsProcessingFeedback,
    QgsProcessingContext
)
from qgis.analysis import QgsRatserCalculatorEntry
from qgis import processing
from pathlib import Path

# Defining directories
dir_path = Path.cwd()
work_dir = dir_path.joinpath("bipp/ncount/sentinel-2-grab")
data_dir = work_dir.joinpath("data")

# Input file paths
raster_path = str(data_dir.joinpath("s1a-iw-grd-vh-20240911t004336-20240911t004401-055610-06c9e2-002.tiff"))
mask_raster_path = str(data_dir.joinpath("ESA_HP_ClipExtent_Reclass.tif"))
output_csv_path = str(data_dir.joinpath('pred_points.tif'))


# Load layers
raster_layer = QgsRasterLayer(raster_path, "Input Raster")
mask_layer = QgsRasterLayer(mask_raster_path, "Mask Raster")

if not raster_layer.isValid() or not mask_layer.isValid():
    print("Error: Failed to load layers. Check the file paths.")
else:
    # Define the extent from the input raster
    extent = raster_layer.extent()

    # Set NoData value for mask raster
    mask_layer.dataProvider().setNoDataValue(1, 128)
    mask_layer.triggerRepaint()

    out_rast = []

    # Step 1: Use raster calculator to apply the mask
    mask_params = {
        'EXPRESSION': 'A@1 * B@1',  # Use the raster calculator syntax
        'LAYERS': [raster_layer, mask_layer],
        'EXTENT': extent,
        'CRS': raster_layer.crs().toWkt(),
        'OUTPUT': output_csv_path
    }

    feedback = QgsProcessingFeedback()


    mask_result = processing.run(
        "qgis:rastercalculator",
        mask_params,
        feedback=feedback
    )


    temporary_raster = mask_result['OUTPUT']
    print(temporary_raster)

    # Save the temporary raster to a file (e.g., TIFF)
    temporary_raster.dataProvider().setNoDataValue(128)  # Optional: Set NoData value if needed
    temporary_raster.writeAsRaster(output_csv_path)  # Save to the specified output path



    # # Create a feedback object for processing feedback
    # feedback = QgsProcessingFeedback()

    # # Create a processing context
    # processing_context = QgsProcessingContext()

    # # Step 2: Use 'Raster Pixels to Points' with the masked raster
    # params = {
    #     'INPUT': mask_result['OUTPUT'],  # Masked raster as input
    #     'BAND': 1,  # Select the raster band to use
    #     'EXTENT': f"{extent.xMinimum()},{extent.xMaximum()},{extent.yMinimum()},{extent.yMaximum()}",
    #     'OUTPUT': 'TEMPORARY_OUTPUT'
    # }



    # # Create a feedback object for processing feedback
    # feedback = QgsProcessingFeedback()

    # # Create a processing context
    # processing_context = QgsProcessingContext()

    # # Run the 'Raster Pixels to Points' algorithm

    # result = processing.run(
    #     "native:pixelstopoints",
    #     params,
    #     context=processing_context,
    #     feedback=feedback,
    # )