WITH 
acs_2013 AS (
  SELECT geo_id, median_income AS income_2013
  FROM `bigquery-public-data.census_bureau_acs.zip_codes_2013_5yr`  
),
acs_2018 AS (
  SELECT geo_id, median_income AS income_2018
  FROM `bigquery-public-data.census_bureau_acs.zip_codes_2018_5yr`  
), 
acs_2013_2018 AS(
    SELECT acs_2013.geo_id, income_2013, income_2018
    FROM 
    acs_2013 
    FULL JOIN 
    acs_2018
    ON 
    acs_2013.geo_id =acs_2018.geo_id
),
# mean
mean_income_2013_2018 AS( 
    SELECT "2013-2018"AS years, AVG(income_2013) AS mean_income_2013, AVG(income_2018)AS mean_income_2018
    FROM acs_2013_2018
),
# median 
median_income_2013_2018 AS( 
    SELECT "2013-2018"AS years, PERCENTILE_CONT(income_2013, 0.5) OVER() AS median_income_2013,
    PERCENTILE_CONT(income_2018, 0.5) OVER() AS median_income_2018
    FROM acs_2013_2018
    LIMIT 1
),
# median+mean
mean_median_income_2013_2018 AS(
    SELECT mean.years, mean_income_2013, median_income_2013,mean_income_2018, median_income_2018 
    FROM (
      mean_income_2013_2018 mean
      JOIN 
      median_income_2013_2018 median
      ON 
      mean.years = median.years
    )
)
SELECT * FROM mean_median_income_2013_2018