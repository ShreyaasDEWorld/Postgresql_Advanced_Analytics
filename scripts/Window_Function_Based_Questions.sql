Window Function Based Questions

1)--Find the top 3 highest revenue-generating products per sub_category.

WITH revenue_generating AS (
    SELECT *,
           DENSE_RANK() OVER (PARTITION BY subcategory ORDER BY total_sales DESC ) AS drnk
    FROM gold.report_products
)

SELECT *
FROM revenue_generating
WHERE drnk <= 3;



2)--Rank products by monthly_revenue within each category and return only products ranked ≤ 5.
  with monthly_revenue as (
select *,
dense_rank() over (partition by category order by avg_monthly_revenue) as drnk
from 
gold.report_products
)
select * from monthly_revenue where drnk <= 3

3)--Calculate the running total of total_sales by order_date for each product.

Find products where current month sales are greater than previous month sales.

Identify products whose profit decreased consecutively for 2 months
