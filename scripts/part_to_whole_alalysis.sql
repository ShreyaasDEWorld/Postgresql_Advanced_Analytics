-------------
--SQL Functions Used:
  --  - SUM(), AVG(): Aggregates values for comparison.
    --- Window Functions: SUM() OVER() for total calculations.
===============================================================================
*/
-- Which categories contribute the most to overall sales?
with category_sales as (
select 
	p.category as category,
	sum(f.sales_amount) as total_sales_amount
	from gold.fact_sales f
	left join gold.dim_products p
	on p.product_key=f.product_key
group by p.category
)
select 
category,
total_sales_amount,
sum(total_sales_amount) over() as total_over_all_sales,
round((total_sales_amount/sum(total_sales_amount) over())*100,2)::TEXT || '%' as percentage_of_total 
from category_sales

