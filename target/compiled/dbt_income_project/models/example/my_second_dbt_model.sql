-- Use the `ref` function to select from other models

select *
from `dbt-income`.`dbt_shafali`.`my_first_dbt_model`
where id = 1