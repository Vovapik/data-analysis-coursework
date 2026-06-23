# Analysis of the Relationship Between Various Factors and Tuberculosis Incidence Rates to Solve a Categorization Problem

---

## 📋 Description

This coursework focuses on analyzing the relationship between socio-economic, demographic, and medical factors and the tuberculosis incidence rate. Based on the identified patterns, a **categorization** problem is solved — classifying countries by the degree of morbidity risk (4 categories based on the `infected_ratio` metric).

A full data lifecycle is implemented: from data collection and ETL processing to building and comparing machine learning models.

---

## 🗂️ Repository Structure

```
data-analysis-coursework/
│
├── data/           # Source and processed datasets (CSV)
├── docs/           # Explanatory note (documentation) for the coursework
├── scr/            # Python scripts and Jupyter Notebooks with the analysis
│   ├── PreparingFiles.py   # Preprocessing and aligning datasets
│   └── Analysis.py         # EDA, correlation analysis, classification models
├── sql/            # SQL scripts: data warehouse creation, Staging area, ETL
└── requirements.txt

```

---

## 🔬 Problem Statement

**Goal:** Investigate the impact of various factors on the tuberculosis incidence rate and build a categorization model.

**Tasks:**

* Collect data from 4 open sources and prepare the datasets
* Design a "star" schema data warehouse (MySQL 8.2.0)
* Implement a Staging area and ETL processes
* Perform Exploratory Data Analysis (EDA) and correlation analysis
* Build and compare 4 classification models
* Determine the optimal model

---

## 📦 Data Sources

| Dataset | Source |
| --- | --- |
| Tuberculosis statistics (`tuberculosis_stats.csv`) | [WHO TME](https://extranet.who.int/tme/generateCSV.asp?ds=estimates) |
| Smoking prevalence (`smoking_stats.csv`) | [John Snow Labs](https://www.johnsnowlabs.com/marketplace/global-smoking-prevalence-1980-to-2012/) |
| Socio-economic indicators (`economic_stats.csv`) | [Kaggle – Global Development Indicators](https://www.kaggle.com/datasets/michaelmatta0/global-development-indicators-2000-2020) |
| Languages and religions of countries (`social_stats.csv`) | [SimpleMaps](https://simplemaps.com/data/countries) |

The data covers the **2000–2012 period** and an aligned set of countries.

---

## 🏗️ Data Warehouse

The data warehouse is implemented using a **"star" schema** in MySQL 8.2.0:

* **Fact table:** `fact_health_stats` — incidence rates, smoking prevalence, GDP, HDI (Human Development Index), etc.
* **Dimension tables:** `dim_country`, `dim_year`, `dim_language`, `dim_religion`, `dim_world_region`

The Staging area mirrors the structure of the source CSV files for intermediate storage before loading into the warehouse.

---

## 📊 Data Mining

### Incidence Categories (infected_ratio)

| Category | Condition |
| --- | --- |
| 1 | `infected_ratio < 0.001` |
| 2 | `0.001 ≤ infected_ratio < 0.003` |
| 3 | `0.003 ≤ infected_ratio < 0.005` |
| 4 | `infected_ratio ≥ 0.005` |

### Key Factors (Pearson correlation with infected_ratio)

Highest correlation: `hiv_in_tb_ratio`, `case_detection_rate`, `human_development_index`, `health_development_ratio`, `case_fatality_rate`, `gdp_per_capita`.

### Classification Models and Results

| Model | Accuracy (test) | F1-score (test) |
| --- | --- | --- |
| **Gradient Boosting** | **0.8535** | **0.8544** |
| Random Forest | 0.8485 | 0.8489 |
| Extra Trees | 0.8384 | 0.8378 |
| Decision Tree | 0.8333 | 0.8295 |

**The best method is Gradient Boosting** (`learning_rate=0.1`, `max_depth=5`, `n_estimators=100`). If training time is critical, alternative options are Random Forest or Extra Trees.

---

## 🛠️ Tech Stack

| Tool | Purpose |
| --- | --- |
| Python 3 | Main programming language |
| Jupyter Notebook / Google Colab | Analysis environment |
| pandas, numpy | Data processing |
| matplotlib, seaborn | Visualization |
| scikit-learn | ML models (classification, GridSearchCV, cross-validation) |
| scipy | Correlation analysis (Pearson) |
| MySQL 8.2.0 | Data warehouse |
| DataGrip | Data import to the Staging area |

---

## 🚀 Launch

1. **Clone the repository:**
```bash
git clone https://github.com/Vovapik/data-analysis-coursework.git
cd data-analysis-coursework

```


2. **Install dependencies:**
```bash
pip install -r requirements.txt

```


3. **Data preparation** — run `scr/PreparingFiles.py`, specifying the paths to the input files.
4. **Deploy the data warehouse** — execute the SQL scripts from the `sql/` folder in MySQL 8.2.0.
5. **Analysis** — open `scr/Analysis.py` in Jupyter Notebook or Google Colab.

---

## 📄 Documentation

The complete explanatory note (documentation) is located in the `docs/` folder.
