import pandas as pd
import numpy as np
import os

# Створюємо директорію для очищених даних, якщо її немає
os.makedirs('../data/clean', exist_ok=True)

# Шляхи до файлів (відносні)
input_file = "../data/raw/TB_burden_countries_2025-05-18.csv"
output_file = "../data/clean/tuberculosis_stats.csv"

input_file2 = "../data/raw/data.csv"
output_file2 = "../data/clean/smoking_stats.csv"

input_file3 = "../data/raw/Global_Development_Indicators_2000_2020.csv"
output_file3 = "../data/clean/economic_stats.csv"

input_file4 = "../data/raw/countries.csv"
output_file4 = "../data/clean/social_stats.csv"

# Зчитування
df = pd.read_csv(input_file)
df2 = pd.read_csv(input_file2)
df3 = pd.read_csv(input_file3)
df4 = pd.read_csv(input_file4)

# Зводимо назви колонок до одного стандарту
dfs = [df, df2, df3, df4]
for i in range(len(dfs)):
    dfs[i].columns = [col[0].lower() + col[1:] if col else col for col in
    dfs[i].columns]
df, df2, df3, df4 = dfs

# Видаляємо непотрібні колонки та для зручності перейменовуємо ті що залишилися
df = df[["country", "year", "g_whoregion", "e_inc_num", "e_pop_num", "e_inc_tbhiv_num", "c_cdr", "cfr"]].copy()
df2 = df2[["country", "age", "gender", "year", "smoking_prevalence"]].copy()
df3 = df3[["country_name", "year", "gdp_per_capita", "health_development_ratio", "human_development_index"]].copy()
df4 = df4[["country", "language", "religion"]].copy()
df.rename(columns={
 "g_whoregion": "world_region",
 "e_inc_num": "infected_num",
 "e_pop_num": "population",
 "e_inc_tbhiv_num": "infected_with_hiv_num",
 "c_cdr": "case_detection_rate",
 "cfr": "case_fatality_rate"
}, inplace=True)
df3.rename(columns={"country_name": "country"}, inplace=True)

# Обрізаємо роки що не є між 2000 та 2012 для узгодженості даних
dfList = [df, df2, df3]
for i in range(len(dfList)):
    dfList[i] = dfList[i].copy()
    dfList[i]['year'] = pd.to_numeric(dfList[i]['year'], errors='coerce')
    dfList[i] = dfList[i][(dfList[i]['year'] >= 2000) & (dfList[i]['year'] <= 2012)]
df, df2, df3 = dfList

# Добавляємо нові колонки - відсоток хворих на туберкульоз та відсоток хворих на ВІЛ серед хворих на туберкульоз
df['infected_ratio'] = df['infected_num'] / df['population']
df['hiv_in_tb_ratio'] = df['infected_with_hiv_num'] / df['infected_num']
df['hiv_in_tb_ratio'] = pd.to_numeric(df['hiv_in_tb_ratio'], errors='coerce')
df['hiv_in_tb_ratio'] = df['hiv_in_tb_ratio'].replace([np.inf, -np.inf], np.nan)
df['hiv_in_tb_ratio'] = df.groupby('country')['hiv_in_tb_ratio'].transform(lambda x: x.fillna(x.mean()))
df['hiv_in_tb_ratio'] = df['hiv_in_tb_ratio'].fillna(df['hiv_in_tb_ratio'].mean())

# Зберігаємо
df.to_csv(output_file, index=False)
df2.to_csv(output_file2, index=False)
df3.to_csv(output_file3, index=False)
df4.to_csv(output_file4, index=False)

# Узгоджуємо країни між датасетами
clean_files = [output_file, output_file2, output_file3, output_file4]
country_sets = [set(pd.read_csv(f)['country'].dropna().str.strip()) for f in clean_files]
common_countries = set.intersection(*country_sets)
all_countries = set.union(*country_sets)
different_countries = all_countries - common_countries
common_countries = sorted(common_countries)
different_countries = sorted(different_countries)
print(f"Common countries in all files ({len(common_countries)}):")
print(common_countries)
print(f"\nDifferent countries (not in all files) ({len(different_countries)}):")
print(different_countries)
for file_path in clean_files:
    df_temp = pd.read_csv(file_path)
    df_temp['country'] = df_temp['country'].str.strip()
    df_temp = df_temp[df_temp['country'].isin(common_countries)]
    df_temp.to_csv(file_path, index=False)

# Видаляємо непотрібні колонки та рядки з датасету щодо куріння
file_path = output_file2
df = pd.read_csv(file_path)
df = df[df['age'] == 'All-ages']
df = df[df['gender'] == 'Both']
df = df.drop(columns=['age', 'gender'])
df.to_csv(file_path, index=False)

