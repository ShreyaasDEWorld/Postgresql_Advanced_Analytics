/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/

create view gold.report_products as 
with base_query as (
select 
			f.order_number,
			f.order_date,
			f.customer_key,
			f.quantity,
			f.sales_amount,
			p.product_key,
			p.product_name,
			p.category,
			p.subcategory,
			p.product_cost
	from 
	gold.fact_sales f
	left join gold.dim_products p
	on f.product_key = p.product_key
	where f.order_date is not null ---to  have valid sales in tables

), prodcust_aggregation as (
		
select 
			product_key,
			product_name,
			category,
			subcategory,
			product_cost,
			( 
				EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) * 12
        		+
        		EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date)))
    		) AS lifespan,
		count(distinct order_number) as Total_Orders,
		sum(sales_amount) as Total_Sales,
		sum(quantity) as Total_Quantity,
		ROUND(
    			SUM(sales_amount)::numeric / NULLIF(SUM(quantity), 0), 
			 1) AS avg_selling_price,
		max(order_date) as last_sale_date,
		(
        EXTRACT(YEAR FROM AGE(CURRENT_DATE, MAX(order_date))) * 12
        +
        EXTRACT(MONTH FROM AGE(CURRENT_DATE, MAX(order_date)))
    	) AS months_since_last_order_recency
from base_query
		group by 
		    product_key,
			product_name,
			category,
			subcategory,
			product_cost
)
select 
	product_key,
	product_name,
	category,
	subcategory,
	product_cost,
	last_sale_date,
	case when Total_Sales > 50000 then 'High-Performer'
		 when Total_Sales >= 10000 then 'Mid-Performer'
		 else 'Low-Performer'
	end as product_segment,
	Total_Orders,
	Total_Sales,
	Total_Quantity,
	avg_selling_price,
	--last_sale_date,
	lifespan,
	months_since_last_order_recency,
	case when Total_Orders=0 then 0 
	     else Total_Sales/Total_Orders
	End as avg_order_revenue,
	round 
		( case  when lifespan = 0 then Total_Sales
	      else Total_Sales/lifespan
	End ,2)  as avg_monthly_revenue
from prodcust_aggregation
