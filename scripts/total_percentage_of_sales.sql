/* report for % of each customer_segment */
SELECT 
    customer_segment,
    COUNT(*) AS total_customer,
    SUM(total_sales) AS total_sales,
    
    ROUND(
        SUM(total_sales) * 100.0 
        / SUM(SUM(total_sales)) OVER (),
    2) AS percentage_of_total_sales

FROM gold.report_customer
GROUP BY customer_segment
ORDER BY SUM(total_sales) DESC;
