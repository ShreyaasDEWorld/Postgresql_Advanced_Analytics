/* Analyze the yearly performance of products by comparing their sales 
to both the average sales performance of the product and the previous year's sales */
with yearly_product_sales as (
select 
	extract (year from f.order_date) as order_year,
	p.product_name as product_name,
	sum(f.sales_amount) as current_sales
	from gold.fact_sales f
	left join gold.dim_products p
	on f.product_key=p.product_key
where f.order_date is not null
group by extract (year from f.order_date),
p.product_name
)
select order_year,
product_name,
current_sales,
round(avg(current_sales) over (partition by product_name),2) as avg_sales,
current_sales-round(avg(current_sales) over (partition by product_name),2) as diff_avg,
case when current_sales-round(avg(current_sales) over (partition by product_name),2) > 0 then 'Above Average'
	 when current_sales-round(avg(current_sales) over (partition by product_name),2) < 0 then 'Below Average'
	 else 'Avg'
end as Avg_change,
----year over year Analysis 
LAG(current_sales) over (partition by product_name order by order_year) as previous_year_change,
current_sales -LAG(current_sales) over (partition by product_name order by order_year) as diff_previous_year_change,
case when current_sales -LAG(current_sales) over (partition by product_name order by order_year) > 0 then  'Increase'
     when current_sales -LAG(current_sales) over (partition by product_name order by order_year) < 0 then  'Decrease'
	 else 'No_Change'
end as prev_year_change
from yearly_product_sales;
