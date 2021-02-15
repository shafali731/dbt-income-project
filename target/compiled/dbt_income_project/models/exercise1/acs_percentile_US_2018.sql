SELECT  
  percentiles[offset(10)] as p10,
  percentiles[offset(25)] as p25,
  percentiles[offset(50)] as p50,
  percentiles[offset(75)] as p75,
  percentiles[offset(90)] as p90,
from (
  select approx_quantiles(median_income, 100) percentiles
  from  `bigquery-public-data.census_bureau_acs.zip_codes_2018_5yr` 
)