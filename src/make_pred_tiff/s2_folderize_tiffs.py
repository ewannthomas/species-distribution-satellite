
from pathlib import Path
import shutil

month = 3

# Defining directories
dir_path = Path.cwd()
data_dir = dir_path.joinpath("data/extracted")

b2_paths = list(data_dir.glob("**/IMG_DATA/R10m/*_B02_*.jp2"))
b3_paths = list(data_dir.glob("**/IMG_DATA/R10m/*_B03_*.jp2"))
b4_paths = list(data_dir.glob("**/IMG_DATA/R10m/*_B04_*.jp2"))
b8_paths = list(data_dir.glob("**/IMG_DATA/R10m/*_B08_*.jp2"))
b11_paths = list(data_dir.glob("**/IMG_DATA/R20m/*_B11_*.jp2"))
b12_paths = list(data_dir.glob("**/IMG_DATA/R20m/*_B12_*.jp2"))

raw_tifs = b2_paths + b3_paths + b4_paths + b8_paths + b11_paths + b12_paths

final_folder = data_dir.parent.joinpath("qg")



def band_maker(df_path):
    band_name = df_path.stem.split("_")[2]

    return band_name


# Function to clean and prepare output path
def final_path_cleaner(band_name, raw_file_stem):

    final_file_folder = final_folder.joinpath(str(month), band_name)

    if not final_file_folder.exists():
        final_file_folder.mkdir(parents=True)

    final_path = final_file_folder.joinpath(raw_file_stem)

    return final_path 
       


for tiff in raw_tifs:

    band_name = band_maker(tiff)

    final_file_path = final_path_cleaner(band_name, tiff.name)

    shutil.copy(tiff, final_file_path)