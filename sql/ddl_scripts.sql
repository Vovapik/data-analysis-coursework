CREATE TABLE dim_country (
    country_id INT AUTO_INCREMENT PRIMARY KEY,
    country_name VARCHAR(100) UNIQUE
);

CREATE TABLE dim_year (
    year_id INT AUTO_INCREMENT PRIMARY KEY,
    year YEAR UNIQUE
);

CREATE TABLE dim_language (
    language_id INT AUTO_INCREMENT PRIMARY KEY,
    language_name VARCHAR(100) UNIQUE
);

CREATE TABLE dim_religion (
    religion_id INT AUTO_INCREMENT PRIMARY KEY,
    religion_name VARCHAR(100) UNIQUE
);

CREATE TABLE dim_world_region (
    region_id INT AUTO_INCREMENT PRIMARY KEY,
    region_name VARCHAR(100) UNIQUE
);

CREATE TABLE fact_health_stats (
    fact_id INT AUTO_INCREMENT PRIMARY KEY,

    country_id INT,
    year_id INT,
    language_id INT,
    religion_id INT,
    region_id INT,

    population INT,
    infected_num INT,
    infected_with_hiv_num INT,
    case_detection_rate DECIMAL(5,2),
    case_fatality_rate DECIMAL(5,2),
    smoking_prevalence DECIMAL(5,2),
    gdp_per_capita DECIMAL(12,2),
    health_development_ratio DECIMAL(5,2),
    human_development_index DECIMAL(4,3),

    FOREIGN KEY (country_id) REFERENCES dim_country(country_id),
    FOREIGN KEY (year_id) REFERENCES dim_year(year_id),
    FOREIGN KEY (language_id) REFERENCES dim_language(language_id),
    FOREIGN KEY (religion_id) REFERENCES dim_religion(religion_id),
    FOREIGN KEY (region_id) REFERENCES dim_world_region(region_id)
);
