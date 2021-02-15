# geo_id, income_2018
WITH acs_2018 AS (
    SELECT
        geo_id,
        median_income AS income_2018,
    FROM
        `bigquery-public-data.census_bureau_acs.zip_codes_2018_5yr` 
  ),
#median_income_us
median_income_in_us_2018 AS(
    SELECT
    region, MAX(median) as median_income_in_US_2018
    FROM(
        SELECT "US" AS region,
        PERCENTILE_CONT( median_income, 0.5) 
            OVER ()AS median
        FROM bigquery-public-data.census_bureau_acs.zip_codes_2018_5yr
    )
    AS tmp
    GROUP BY region
),
#mean_income_us
mean_income_in_us_2018 AS(
    SELECT 
     "US" AS region,AVG(median_income) AS mean_income_in_us_2018
     FROM
        `bigquery-public-data.census_bureau_acs.zip_codes_2018_5yr` 
),
acs_2018_with_statecode AS (
    SELECT
        geo_id,
        income_2018,
        geo.state_code
    FROM
        acs_2018 a18
    JOIN
        `bigquery-public-data.geo_us_boundaries.zip_codes` geo
    ON
        a18.geo_id = geo.zip_code 
    WHERE geo.state_code = 'NY' OR geo.state_code = 'CA' OR geo.state_code = 'TX' OR geo.state_code = 'FL'
),
#state median income
median_income_state_2018 AS(
    SELECT
    state_code, MAX(median) as median_income_2018
    FROM(
        SELECT state_code,
        PERCENTILE_CONT( income_2018, 0.5) 
            OVER (PARTITION BY state_code)AS median
        FROM acs_2018_with_statecode
    )
    AS tmp
    GROUP BY state_code
),
#state mean income
mean_income_state_2018 AS(
    SELECT
    state_code,
     AVG(income_2018) AS mean_income_in_2018,
    FROM
    acs_2018_with_statecode
    GROUP BY
    state_code
),
# states median + mean 
mean_median_income_state_2018 AS(
    SELECT mean_income_state_2018.state_code, mean_income_in_2018, median_income_state_2018.median_income_2018 FROM mean_income_state_2018 
    INNER JOIN  median_income_state_2018 
    ON mean_income_state_2018.state_code = median_income_state_2018.state_code
),
# US median + mean 
mean_median_income_us_2018 AS(
    SELECT median_income_in_us_2018.region,mean_income_in_us_2018.mean_income_in_US_2018, median_income_in_us_2018.median_income_in_US_2018 FROM median_income_in_us_2018 
    INNER JOIN  mean_income_in_us_2018  
    ON mean_income_in_us_2018.region = median_income_in_us_2018.region
),
state_us_mean_median_income_2018 AS(
    SELECT region, mean_income_in_US_2018, median_income_in_US_2018 
    FROM mean_median_income_us_2018
    UNION ALL
    SELECT state_code, mean_income_in_2018, median_income_2018
    FROM 
    mean_median_income_state_2018
)
SELECT * FROM state_us_mean_median_income_2018