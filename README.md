# Аналіз зв'язку різних факторів та рівня захворювання туберкульозом для розв'язання задачі категоризації


---

## 📋 Опис

Курсова робота присвячена аналізу взаємозв'язку соціально-економічних, демографічних та медичних факторів з рівнем захворюваності на туберкульоз. На основі виявлених закономірностей розв'язується задача **категоризації** — класифікація країн за ступенем ризику захворюваності (4 категорії за показником `infected_ratio`).

Реалізовано повний цикл роботи з даними: від збору та ETL-обробки до побудови і порівняння моделей машинного навчання.

---

## 🗂️ Структура репозиторію

```
data-analysis-coursework/
│
├── data/           # Вихідні та оброблені датасети (CSV)
├── docs/           # Пояснювальна записка до курсової роботи
├── scr/            # Python-скрипти та Jupyter Notebooks з аналізом
│   ├── PreparingFiles.py   # Попередня обробка та узгодження датасетів
│   └── Analysis.py         # EDA, кореляційний аналіз, моделі класифікації
├── sql/            # SQL-скрипти: створення сховища, Stage зони, ETL
└── requirements.txt
```

---

## 🔬 Постановка задачі

**Мета:** дослідити вплив різних факторів на рівень захворюваності на туберкульоз та побудувати модель категоризації.

**Задачі:**
- Зібрати дані з 4 відкритих джерел та підготувати датасети
- Спроектувати сховище даних типу «зірка» (MySQL 8.2.0)
- Реалізувати Stage зону та ETL процеси
- Провести EDA та кореляційний аналіз
- Побудувати та порівняти 4 моделі класифікації
- Визначити найоптимальнішу модель

---

## 📦 Джерела даних

| Датасет | Джерело |
|---------|---------|
| Статистика туберкульозу (`tuberculosis_stats.csv`) | [WHO TME](https://extranet.who.int/tme/generateCSV.asp?ds=estimates) |
| Поширення куріння (`smoking_stats.csv`) | [John Snow Labs](https://www.johnsnowlabs.com/marketplace/global-smoking-prevalence-1980-to-2012/) |
| Соціально-економічні показники (`economic_stats.csv`) | [Kaggle – Global Development Indicators](https://www.kaggle.com/datasets/michaelmatta0/global-development-indicators-2000-2020) |
| Мови та релігії країн (`social_stats.csv`) | [SimpleMaps](https://simplemaps.com/data/countries) |

Дані охоплюють **період 2000–2012 рр.** та узгоджений набір країн.

---

## 🏗️ Сховище даних

Сховище реалізовано за схемою **«зірка»** у MySQL 8.2.0:

- **Таблиця фактів:** `fact_health_stats` — показники захворюваності, куріння, ВВП, ІЛР тощо
- **Таблиці вимірів:** `dim_country`, `dim_year`, `dim_language`, `dim_religion`, `dim_world_region`

Stage зона копіює структуру вхідних CSV-файлів для проміжного зберігання перед завантаженням у сховище.

---

## 📊 Інтелектуальний аналіз даних

### Категорії захворюваності (infected_ratio)

| Категорія | Умова |
|-----------|-------|
| 1 | `infected_ratio < 0.001` |
| 2 | `0.001 ≤ infected_ratio < 0.003` |
| 3 | `0.003 ≤ infected_ratio < 0.005` |
| 4 | `infected_ratio ≥ 0.005` |

### Ключові фактори (кореляція Пірсона з infected_ratio)

Найвища кореляція: `hiv_in_tb_ratio`, `case_detection_rate`, `human_development_index`, `health_development_ratio`, `case_fatality_rate`, `gdp_per_capita`.

### Моделі класифікації та результати

| Модель | Accuracy (test) | F1-score (test) |
|--------|:-:|:-:|
| **Gradient Boosting** | **0.8535** | **0.8544** |
| Random Forest | 0.8485 | 0.8489 |
| Extra Trees | 0.8384 | 0.8378 |
| Decision Tree | 0.8333 | 0.8295 |

**Найкращий метод — Gradient Boosting** (`learning_rate=0.1`, `max_depth=5`, `n_estimators=100`). За умови критичності часу тренування — альтернатива: Random Forest або Extra Trees.

---

## 🛠️ Технологічний стек

| Інструмент | Призначення |
|------------|-------------|
| Python 3 | Основна мова |
| Jupyter Notebook / Google Colab | Середовище аналізу |
| pandas, numpy | Обробка даних |
| matplotlib, seaborn | Візуалізація |
| scikit-learn | Моделі ML (класифікація, GridSearchCV, cross-validation) |
| scipy | Кореляційний аналіз (Pearson) |
| MySQL 8.2.0 | Сховище даних |
| DataGrip | Імпорт даних у Stage зону |

---

## 🚀 Запуск

1. **Клонуйте репозиторій:**
   ```bash
   git clone https://github.com/Vovapik/data-analysis-coursework.git
   cd data-analysis-coursework
   ```

2. **Встановіть залежності:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Підготовка даних** — запустіть `scr/PreparingFiles.py`, вказавши шляхи до вхідних файлів.

4. **Розгорніть сховище** — виконайте SQL-скрипти з папки `sql/` у MySQL 8.2.0.

5. **Аналіз** — відкрийте `scr/Analysis.py` у Jupyter Notebook або Google Colab.

---

## 📄 Документація

Повна пояснювальна записка знаходиться у папці `docs/`.
