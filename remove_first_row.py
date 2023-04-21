import pandas as pd
df = pd.read_csv("/path/InteractiveSignIns.csv")
df = df.iloc[1:]
df.to_csv("/path/InteractiveSignIns.csv", header=None)