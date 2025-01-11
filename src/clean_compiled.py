
from pathlib import Path
import pandas as pd
import geopandas as gpd

# Defining directories
dir_path = Path.cwd()
prep_folder = dir_path.joinpath("data/prep")
s1_path = prep_folder.joinpath("sent1.parquet")
s2_path = prep_folder.joinpath("sent2.parquet")

index_cols = ['long', 'lat','year', 'month', 'species_names']

def sent1():

    df = pd.read_parquet(s1_path)

    df['year'] = df['date'].str.split("-", expand=True)[0]
    df['month'] = df['date'].str.split("-", expand=True)[1]

    df_grouped = df.groupby(index_cols)[["vh_Ascending","vv_Ascending", "vh_Descending", "vv_Descending"]].median().reset_index()

    # df_grouped = df_grouped.sort_values(['long', 'lat', "species_names"])

    return df_grouped     



def sent2():

    df = pd.read_parquet(s2_path)

    df['year'] = df['date'].str.split("-", expand=True)[0]
    df['month'] = df['date'].str.split("-", expand=True)[1]

    df_grouped = df.groupby(index_cols)[["B02","B03", "B04", "B08", "B11", "B12"]].median().reset_index()

    # df_grouped = df_grouped.sort_values(['long', 'lat', "species_names"])

    return df_grouped



merged_df = pd.merge(left=sent1(), right=sent2(), on=index_cols, how="outer", validate="m:m")
print(merged_df)

merged_df.to_parquet("merged.parquet", index=False)


merged_df.to_csv("merged.csv", index=False)