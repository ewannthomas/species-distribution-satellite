import pandas as pd
from pathlib import Path
df_path = Path.cwd().joinpath("data/coc.dta")
df_out = Path.cwd().joinpath("data/coc.csv")
print(df_path)
df = pd.read_stata(df_path)
df.to_csv(df_out, index=False)

print(df)