INSERT IGNORE INTO main_storage.dim_country (country_name)
SELECT DISTINCT country FROM stage.tuberculosis_stats;

INSERT IGNORE INTO main_storage.dim_year (year)
SELECT DISTINCT year FROM stage.tuberculosis_stats;

INSERT IGNORE INTO main_storage.dim_language (language_name)
SELECT DISTINCT language FROM stage.social_stats;

INSERT IGNORE INTO main_storage.dim_religion (religion_name)
SELECT DISTINCT religion FROM stage.social_stats;

INSERT IGNORE INTO main_storage.dim_world_region (region_name)
SELECT DISTINCT world_region FROM stage.tuberculosis_stats;

INSERT INTO main_storage.fact_health_stats (
    country_id, year_id, language_id, religion_id, region_id,
    population, infected_num, infected_with_hiv_num,
    case_detection_rate, case_fatality_rate,
    smoking_prevalence, gdp_per_capita, health_development_ratio,
    human_development_index, infected_ratio, hiv_in_tb_ratio
)
SELECT
    dc.country_id,
    dy.year_id,
    dl.language_id,
    dr.religion_id,
    dwr.region_id,
    tb.population,
    tb.infected_num,
    tb.infected_with_hiv_num,
    tb.case_detection_rate,
    tb.case_fatality_rate,
    sm.smoking_prevalence,
    ec.gdp_per_capita,
    ec.health_development_ratio,
    ec.human_development_index,
    tb.infected_ratio,
    tb.hiv_in_tb_ratio
FROM stage.tuberculosis_stats tb
JOIN stage.smoking_stats sm ON tb.country = sm.country AND tb.year = sm.year
JOIN stage.economic_stats ec ON tb.country = ec.country AND tb.year = ec.year
JOIN stage.social_stats soc ON tb.country = soc.country
JOIN main_storage.dim_country dc ON tb.country = dc.country_name
JOIN main_storage.dim_year dy ON tb.year = dy.year
JOIN main_storage.dim_language dl ON soc.language = dl.language_name
JOIN main_storage.dim_religion dr ON soc.religion = dr.religion_name
JOIN main_storage.dim_world_region dwr ON tb.world_region = dwr.region_name;

UPDATE main_storage.fact_health_stats
SET
    population = ABS(population),
    infected_num = ABS(infected_num),
    infected_with_hiv_num = ABS(infected_with_hiv_num),
    case_detection_rate = ABS(case_detection_rate),
    case_fatality_rate = ABS(case_fatality_rate),
    smoking_prevalence = ABS(smoking_prevalence),
    gdp_per_capita = ABS(gdp_per_capita),
    health_development_ratio = ABS(health_development_ratio),
    human_development_index = ABS(human_development_index),
    infected_ratio = ABS(infected_ratio),
    hiv_in_tb_ratio = ABS(hiv_in_tb_ratio);

SELECT
    SUM(population IS NULL) AS null_population,
    SUM(infected_num IS NULL) AS null_infected,
    SUM(infected_with_hiv_num IS NULL) AS null_hiv,
    SUM(case_detection_rate IS NULL) AS null_detection,
    SUM(case_fatality_rate IS NULL) AS null_fatality,
    SUM(smoking_prevalence IS NULL) AS null_smoking,
    SUM(gdp_per_capita IS NULL) AS null_gdp,
    SUM(health_development_ratio IS NULL) AS null_health,
    SUM(human_development_index IS NULL) AS null_hdi
FROM main_storage.fact_health_stats;

CREATE TEMPORARY TABLE country_avgs AS
SELECT
    country_id,
    region_id,
    AVG(infected_with_hiv_num) AS avg_infected_with_hiv_num,
    AVG(case_detection_rate) AS avg_case_detection_rate,
    AVG(case_fatality_rate) AS avg_case_fatality_rate,
    AVG(gdp_per_capita) AS avg_gdp_per_capita,
    AVG(health_development_ratio) AS avg_health_development_ratio,
    AVG(human_development_index) AS avg_human_development_index
FROM fact_health_stats
GROUP BY country_id, region_id;

CREATE TEMPORARY TABLE region_avgs AS
SELECT
    region_id,
    AVG(case_detection_rate) AS reg_avg_case_detection_rate,
    AVG(case_fatality_rate) AS reg_avg_case_fatality_rate,
    AVG(gdp_per_capita) AS reg_avg_gdp_per_capita,
    AVG(health_development_ratio) AS reg_avg_health_dev_ratio,
    AVG(human_development_index) AS reg_avg_human_dev_index
FROM fact_health_stats
GROUP BY region_id;

UPDATE fact_health_stats f
JOIN country_avgs c ON f.country_id = c.country_id
JOIN region_avgs r ON c.region_id = r.region_id
SET
    f.infected_with_hiv_num = IFNULL(f.infected_with_hiv_num,
        IF(c.avg_infected_with_hiv_num IS NULL, 0, c.avg_infected_with_hiv_num)),

    f.case_detection_rate = IFNULL(f.case_detection_rate,
        IF(c.avg_case_detection_rate IS NULL, r.reg_avg_case_detection_rate, c.avg_case_detection_rate)),

    f.case_fatality_rate = IFNULL(f.case_fatality_rate,
        IF(c.avg_case_fatality_rate IS NULL, r.reg_avg_case_fatality_rate, c.avg_case_fatality_rate)),

    f.gdp_per_capita = IFNULL(f.gdp_per_capita,
        IF(c.avg_gdp_per_capita IS NULL, r.reg_avg_gdp_per_capita, c.avg_gdp_per_capita)),

    f.health_development_ratio = IFNULL(f.health_development_ratio,
        IF(c.avg_health_development_ratio IS NULL, r.reg_avg_health_dev_ratio, c.avg_health_development_ratio)),

    f.human_development_index = IFNULL(f.human_development_index,
        IF(c.avg_human_development_index IS NULL, r.reg_avg_human_dev_index, c.avg_human_development_index));

DROP TEMPORARY TABLE IF EXISTS country_avgs;
DROP TEMPORARY TABLE IF EXISTS region_avgs;
