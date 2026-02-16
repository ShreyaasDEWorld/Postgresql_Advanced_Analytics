
-----We need to group the customber bsaed on purchase pattern 
--customer spend more than $5000 in last 12 months is vip
---customer spend less than or less $5000 in last 12 motnhs is regular
---lifespan less than 12 months.
--find total number of customer in each group


select 
c.customer_key,
sum(f.sales_amount) as total_spending,
min(f.order_date) as first_order_date ,
max(f.order_date) as last_order_date,
max(f.order_date)-min(f.order_date) as days_between_orders,
age(max(f.order_date))-age(min(f.order_date)) as months_between_orders
from 
gold.fact_sales f
left join gold.dim_customer c
on f.customer_key=c.customer_key
group by c.customer_key


