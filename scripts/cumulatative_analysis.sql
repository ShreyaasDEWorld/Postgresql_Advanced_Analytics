--total sales per month and running total sales 
SELECT 
    order_date,
    total_sales,
    SUM(total_sales) OVER (partition by order_date ORDER BY order_date) AS running_total_sales
FROM (
    SELECT 
        DATE_TRUNC('month', order_date) AS order_date,
		SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    GROUP BY DATE_TRUNC('month', order_date)
	   
) t
ORDER BY order_date;
