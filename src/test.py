
from pathlib import Path
import pandas as pd
from functools import reduce

# Defining directories
dir_path = Path.cwd()
sent1_dfs = dir_path.joinpath("data/cleaned/sentinel_1")
sent2_dfs = dir_path.joinpath("data/cleaned/sentinel_2")
prep_folder = dir_path.joinpath("data/prep")
if not prep_folder.exists():
    prep_folder.mkdir(parents=True)



sent_1_folders = list(sent1_dfs.glob("**"))
sent_2_folders = list(sent2_dfs.glob("**"))


def sent1_clean(df:pd.DataFrame):
    index_cols = ['date','long', 'lat', 'species_names']

    df.drop_duplicates(subset=index_cols, keep='first', inplace=True)

    band_name = [x for x in df.columns if x in ['vh', 'vv']]

    orbit = df['orbit_path'].unique()[0]

    new_colnames = [x for x in df.columns if x not in ['vh', 'vv', 'orbit_path']]

    new_colnames.append("_".join([band_name[0], orbit]))

    df_wide = df.pivot(index=index_cols, columns=['orbit_path'], values=band_name).reset_index()

    df_wide.columns = new_colnames
    
    return df_wide

def sent2_clean(df:pd.DataFrame):
    index_cols = ['date','long', 'lat', 'species_names']

    df.drop_duplicates(subset=index_cols, keep='first', inplace=True)

    return df

def sent1_data_compile():

    sent1_df = prep_folder.joinpath("sent_new.parquet")

    df_collector = []


    for folder in sent_2_folders[100:150]:

        data_holder = []
        df_paths = list(folder.glob("*.csv"))

        for df_path in df_paths:
            df = pd.read_csv(df_path, dtype={"long": str, "lat": str})

            if not df.shape[0]==0:
                df = sent2_clean(df)
                data_holder.append(df)
        if len(data_holder)>0:
            merged_df = reduce(lambda left, right: pd.merge(left, right, on=['date', 'long', 'lat', 'species_names'], how='outer', validate="1:1"), data_holder)
            merged_df.drop_duplicates(subset=['date','long', 'lat', 'species_names'], keep='first', inplace=True)

            

        df_collector.append(merged_df)
    

    final_df = pd.concat(df_collector, axis=0).fillna(0)


    final_df.to_parquet(sent1_df, index=False)
    
    df_new = pd.read_parquet(sent1_df)
    # df_new['dups']= df_new.duplicated(["date","lat","long"], keep=False )

    print(df_new)

sent1_data_compile()