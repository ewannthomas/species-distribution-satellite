from pathlib import Path
import pandas as pd
import numpy as np

# Defining directories
dir_path = Path.cwd()
prep_folder = dir_path.joinpath("data/prep")
df_path = prep_folder.joinpath("merged.parquet")


df = pd.read_parquet(df_path)
index_cols = ["long", "lat", "season", "species_names"]

# creating seasons
conds = [df["month"].isin(["03", "04", "05"]), df["month"].isin(["10", "11", "12"])]
opts = ["summer", "winter"]
df["season"] = np.select(conds, opts, default="NA")
df = df[~(df["season"] == "NA")]
df = df.drop(["year", "month"], axis=1)


# Making indices
def make_indices(df):

    ## NDVI
    df["NDVI"] = (df["B08"] - df["B04"]) / (df["B08"] + df["B04"])
    temp_df = pd.DataFrame(df["NDVI"])

    ## Atmospherically Resistant Vegetation Index 2
    df["ARVI2"] = -0.18 + 1.17 * df["NDVI"]

    ## Blue-wide dynamic range vegetation index
    df["BWDRVI"] = 0.1 * (df["B08"] - df["B02"]) / 0.1 * (df["B08"] + df["B02"])

    ## Chlorophyll vegetation index
    df["CVI"] = df["B08"] * df["B04"] / (df["B03"].pow(2))

    ## Corrected Transformed Vegetation Index
    temp_df["ndvi+0.5"] = temp_df["NDVI"] + 0.5
    temp_df["ctvi1"] = (temp_df["ndvi+0.5"]) / (temp_df["ndvi+0.5"].abs())
    temp_df["ctvi2"] = np.sqrt(temp_df["ndvi+0.5"].abs())
    df["CTVI"] = temp_df["ctvi1"] * temp_df["ctvi2"]

    ## Enhanced Vegetation Index 2 -2
    df["EVI2"] = 2.5 * ((df["B08"] - df["B04"]) / (df["B08"] + (2.4 * df["B04"]) + 1))

    ## Global Vegetation Moisture Index
    temp_df['gvmi_num'] = (df['B08'] + 0.1) - (df['B11'] + 0.02)
    temp_df['gvmi_den'] = (df['B08'] + 0.1) + (df['B11'] + 0.02)
    df['GVMI'] = temp_df['gvmi_num']/temp_df['gvmi_den']

    ## Mid-infrared vegetation index
    df['MVI'] = df['B08']/df['B11']

    ## Modified Soil Adjusted Vegetation Index hyper
    temp_df['2800+1'] = df['B12'] + 1
    temp_df['hyper_second'] = np.sqrt(temp_df['2800+1'].pow(2) - (8 * (df['B08'] - df['B04'])))
    df['MSVAIhyper'] = 0.5 * (temp_df['2800+1'] - temp_df['hyper_second'])

    ## Modified Triangular Vegetation Index 2
    # temp_df['mtvi2_num'] = 1.2 * (df['B08'] - df['B03']) - 2.5 *(df['B04'] - df['B03'])
    # df['MTVI2']


    ## Normalized Difference NIR/MIR Modified Normalized Difference Vegetation Index
    df['MNDVI'] = (df['B08'] - df['B03'])/(df['B08'] + df['B03'])

    ## Optimized Soil Adjusted Vegetation Index
    temp_df['Y'] = 0.16
    temp_df['osavi_num'] = df['B08'] - df['B04']
    temp_df['osavi_den'] = df['B08'] + df['B04'] + temp_df['Y']
    df['OSAVI'] = (temp_df['Y'] + 1) * (temp_df['osavi_num']/temp_df['osavi_den'])

    ## Perpendicular Vegetation Index
    # df['PVI'] = 

    ## Soil and Atmospherically Resistant Vegetation Index
    # df['SARVI]

    ## Specific Leaf Area Vegetation Index
    df['SLAVI'] = df['B08'] / (df['B04'] + df['B11'])

    ## Transformed Soil Adjusted Vegetation Index 2

    ## Weighted Difference Vegetation Index

    ## Wide Dynamic Range Vegetation Index
    df['WDRVI'] = 0.1*(df['B08'] - df['B04'])/(0.1*(df['B08'] + df['B04']))




    print(temp_df)

    print(df)
    return df


make_indices(df)
# #Grouping vars by season
# df = df.groupby(index_cols).median().reset_index()

# # check for missingness
# print(df.shape)
# print(df.dropna(axis=0, how='any'))

# # widening the frame
# df_wide = df.pivot(index=['long', 'lat', 'species_names'], columns=['season']).reset_index()
# new_cols = ["".join(x) for x in df_wide.columns]
# df_wide.columns = new_cols
# print(df_wide)
