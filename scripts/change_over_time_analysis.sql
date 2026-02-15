--Report on total_sales,total_csutomers,total_quantity 
SELECT
  EXTRACT(year from order_date) as year_order_date,
  EXTRACT(month from order_date) as month_order_date,
  TO_CHAR(order_date, 'FMMonth') AS month_name,
  sum(sales_amount)  as total_sales,
  count(distinct customer_key) as total_customers,
  sum(quantity) as total_quantity
from gold.fact_sales
where order_date is not null
group by EXTRACT(year from order_date),EXTRACT(month from order_date),
TO_CHAR(order_date, 'FMMonth')
