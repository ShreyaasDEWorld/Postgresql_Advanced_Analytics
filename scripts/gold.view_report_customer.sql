/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
===============================================================================
*/
create view gold.report_customer as
with base_query as (
/*
1. Gathers essential fields such as names, ages, and transaction details.
*/
	SELECT 
	f.order_number,
	f.product_key,
	f.order_date,
	f.sales_amount,
	f.quantity,
	c.customer_key,
	c.customer_number,
	c.customer_firstname || ' ' ||c.customer_lastname as customer_name,
	c.birthday,
	extract (year from AGE(CURRENT_DATE, c.birthday)) AS age
	FROM 
	gold.fact_sales f
	left join gold.dim_customer c
	on c.customer_key = f.customer_key
	where f.order_date is not null
		
), customer_aggregation as (
		select 
		customer_key,
		customer_number,
		age,
		customer_name,
		count(distinct order_number) as Total_Orders,
		sum(sales_amount) as Total_Sales,
		sum(quantity) as Total_Quantity,
		max(order_date) as last_order_date,
		(
        EXTRACT(YEAR FROM AGE(CURRENT_DATE, MAX(order_date))) * 12
        +
        EXTRACT(MONTH FROM AGE(CURRENT_DATE, MAX(order_date)))
    	) AS months_since_last_order_recency,
				count(distinct product_key) as total_products,
		( 
			EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) * 12
        	+
        	EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date)))
    	) AS lifespan
		from base_query
		group by 
		customer_key,
		customer_number,
		age,
		customer_name

)

select 
		customer_key,
		customer_number,
		age,
		case when age < 20 then 'Under 20'
			 when age between 20 and 29 then '20-29'
			 when age between 30 and 39 then '30-39'
			 when age between 40 and 49 then '40-49'
			 else '50 and above'
		End as Age_group,
		case when lifespan >=12 and Total_Sales > 5000 THEN 'VIP'
			 when lifespan >=12 and Total_Sales < 5000 THEN 'REGULAR'
			 else 'New'
	    End as customer_segment,
		last_order_date,
		months_since_last_order_recency,
		customer_name,
		Total_Orders,
		Total_Sales,
		Total_Quantity,
		total_products,
		lifespan,
		--compute avg values 
		case when Total_Orders = 0 then 0
			 else Total_Sales/Total_Orders 
		End as avg_order_value,
		--compute avg monthly value
		ROUND
			(
			case when lifespan =0 then total_sales
		    	 else Total_Sales/lifespan
	    	End 
		, 2 ) as avg_monthly_total
		
from customer_aggregation



--select * from gold.report_customer
