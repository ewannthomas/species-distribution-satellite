
from pathlib import Path
import shutil

month = 12

# Defining directories
dir_path = Path.cwd()
data_dir = dir_path.joinpath("data/extracted")
raw_tifs = list(data_dir.rglob("*.tiff"))
final_folder = data_dir.parent.joinpath("qg")


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
    elif xml_vals =="Ascending<":
        xml_vals="Ascending"
        return xml_vals
    else:
        print("Unrecognized Orbit Parameter received.")
        print(str(raw_path))

# Function to clean and prepare output path
def final_path_cleaner(band_name, orbit_name, raw_file_stem):

    final_file_folder = final_folder.joinpath(str(month), band_name, orbit_name)

    if not final_file_folder.exists():
        final_file_folder.mkdir(parents=True)

    final_path = final_file_folder.joinpath(raw_file_stem)
    return final_path
       

def output_logger(raw_path):
    final_stem = raw_path.stem
    final_sub_path = "/".join(str(raw_path).split("/")[8:11]).replace(".SAFE", "")

    out_dict={
        "source_folder":final_sub_path,
        "source_file": final_stem
    }

    print(out_dict)


for tiff in raw_tifs:
    orb = orbit_maker(tiff)
    band_name = band_maker(tiff)
    date_val = datemaker(tiff)

    final_file_path = final_path_cleaner(band_name, orb, tiff.name)

    shutil.copy(tiff, final_file_path)