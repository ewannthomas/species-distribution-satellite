from qgis.core import (
    QgsApplication,
    QgsProject,
    QgsRasterLayer,
    QgsVectorLayer,
    QgsCoordinateTransform,
    QgsCoordinateTransformContext,
    QgsField,
)
from qgis.PyQt.QtCore import QVariant
from pathlib import Path


# Defining directories
dir_path = Path.cwd()
work_dir = dir_path.joinpath("bipp/ncount/sentinel-2-grab")
data_dir = work_dir.joinpath("data/extracted")

file_patterns = ["*B0[2-4]_10m.jp2", "*B08_10m.jp2", "*B11_20m.jp2", "*B12_20m.jp2"]

raw_tifs = [y for x in file_patterns for y in list(data_dir.rglob(x))]


final_folder = data_dir.parent.joinpath("qg")
shp_path = data_dir.parent.joinpath("shapes/himachal_species/himachal_species.shp")


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

    date_stem = df_path.stem.split("_")[1].split("T")[0]

    year_val = date_stem[0:4]
    month_val = date_stem[4:6]
    day_val = date_stem[6:8]

    date_val = "-".join([year_val, month_val, day_val])

    return date_val


def band_maker(df_path):
    band_val = df_path.stem.split("_")[2]

    return band_val


def output_logger(raw_path):
    final_stem = raw_path.stem
    final_sub_path = "/".join(str(raw_path).split("/")[8:11]).replace(".SAFE", "")

    out_dict = {"source_folder": final_sub_path, "source_file": final_stem}

    print(out_dict)


# Load the vector layer (shapefile)
vector_layer = QgsVectorLayer(str(shp_path), "Vector Layer", "ogr")
if not vector_layer.isValid():
    print("Failed to load vector layer!")
    exit()

# Add a new field to store raster values (if needed)
vector_layer_provider = vector_layer.dataProvider()


# Process each raster file
for rast in raw_tifs:
    final_path = final_path_cleaner(rast)

    if not final_path.exists():

        date_val = datemaker(final_path)

        band_name = band_maker(final_path)

        # Load the raster layer
        raster_layer = QgsRasterLayer(str(rast), "Raster Layer")
        if not raster_layer.isValid():
            print(f"Failed to load raster layer: {rast}")
            continue

        raster_data_provider = (
            raster_layer.dataProvider()
        )  # Define provider inside the loop

        # Extract raster values and write to CSV
        with open(final_path, "w") as csv_file:
            csv_file.write(f"date,long,lat,species_names,{band_name}\n")  # Header

            for feature in vector_layer.getFeatures():
                # Get the geometry of the point
                point = feature.geometry().asPoint()

                attrs = feature.attributes()

                # Transform the point if layers have different CRS
                raster_crs = raster_layer.crs()
                vector_crs = vector_layer.crs()

                # print(raster_crs)
                # print(vector_crs)
                if raster_crs != vector_crs:
                    transform_context = QgsProject.instance().transformContext()
                    transform = QgsCoordinateTransform(
                        vector_crs, raster_crs, transform_context
                    )
                    point_crs_updated = transform.transform(point)

                # Get raster value at the point
                raster_data_provider.setNoDataValue(1, 0)
                value = raster_data_provider.sample(point_crs_updated, 1)

                if value[1] is not False:
                    # if value[0] != 0:
                    raster_value = value[0]
                    # Write to CSV
                    csv_file.write(
                        f"{date_val},{point.x()},{point.y()},{attrs[6]},{raster_value}\n"
                    )

    output_logger(rast)
