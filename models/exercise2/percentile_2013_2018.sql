WITH 
acs_2013 AS (
  SELECT geo_id, median_income AS income_2013
  FROM `bigquery-public-data.census_bureau_acs.zip_codes_2013_5yr`  
),
acs_2018 AS (
  SELECT  geo_id, median_income AS income_2018
  FROM `bigquery-public-data.census_bureau_acs.zip_codes_2018_5yr`  
), 
acs_2013_2018 AS(
    SELECT  acs_2013.geo_id, income_2013, income_2018
    FROM 
    acs_2013 
    FULL JOIN 
    acs_2018
    ON 
    acs_2013.geo_id =acs_2018.geo_id
),
percentiles_2013 AS(
  SELECT  
    "2013" as year,
    percentiles[offset(10)] as p10,
    percentiles[offset(25)] as p25,
    percentiles[offset(50)] as p50,
    percentiles[offset(75)] as p75,
    percentiles[offset(90)] as p90,
  from (
    select approx_quantiles(income_2013, 100) percentiles
    from  acs_2013_2018
  )
),
percentiles_2018 AS(
  SELECT  
    "2018" as year,
    percentiles[offset(10)] as p10,
    percentiles[offset(25)] as p25,
    percentiles[offset(50)] as p50,
    percentiles[offset(75)] as p75,
    percentiles[offset(90)] as p90,
  from (
    select approx_quantiles(income_2018, 100) percentiles
    from  acs_2013_2018
  )
)

SELECT * FROM 
  (
    SELECT year, p10, p25, p50, p75, p90
    FROM 
    percentiles_2013
    UNION ALL
    SELECT year, p10, p25, p50, p75, p90 
    FROM percentiles_2018
  ) percentiles_2013_2018