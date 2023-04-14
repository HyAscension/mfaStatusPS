import pandas as pd

# add trust to the pip install pandas for certain systems
# pip install pandas --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host=files.pythonhosted.org

df = pd.read_csv("/path/recentLoginList.csv", skip_blank_lines=False)
df = df[['UserPrincipalName', 'Name', 'AppInteractLastLogin', 'TokenInteractLastLogin', 'IsLicensed', 'IsGuestUser']]
df.to_csv("/path/LastLoginDateReport.csv", index=False)