
from pathlib import Path
import pandas as pd
import geopandas as gpd


dir_path = Path.cwd()

shapes_folder = dir_path.joinpath("data/shapes/new_species")

shp_file = shapes_folder.joinpath("himachal_species_removed_duplicates.shp")

df = gpd.read_file(shp_file)

df['dups'] = df.duplicated(['Long'], keep=False)

print(df[df['dups']])