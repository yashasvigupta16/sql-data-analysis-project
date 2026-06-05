/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, product categorization, or regional analysis.

SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into segments.
===============================================================================
*/

/*Segment products into cost ranges and 
count how many products fall into each segment*/
SELECT
cost_range,
COUNT(product_key) AS no_of_products
FROM
    (SELECT
    product_key,
    product_name,
    product_cost,
    CASE
        WHEN product_cost < 100 THEN 'Below 100'
        WHEN product_cost BETWEEN 100 AND 500 THEN '200-500'
        WHEN product_cost BETWEEN 500 AND 1000 THEN '500-1000' 
        ELSE 'Above 1000'
    END AS cost_range
    FROM gold.dim_products)T
GROUP BY cost_range
ORDER BY no_of_products DESC

/* Group customers into three segments based on their spending behaviour:
- VIP: atleast 12 month of history and spending more than 5000.
- Regular: atleast 12 months of history but spending 5000 or less.
- New: lifespan less than 12 months
And find the total number of customers by each group */

SELECT
customer_segmentation,
COUNT(customer_key) AS no_of_customer
FROM 
    (SELECT 
    s.customer_key,
    c.first_name,
    c.last_name,
    SUM(sales_amount) AS spending,
    DATEDIFF(MONTH,MIN(s.order_date),MAX(s.order_date)) AS latest_order,
    CASE 
        WHEN DATEDIFF(MONTH,MIN(s.order_date),MAX(s.order_date)) >= 12 AND SUM(sales_amount) > 5000 THEN 'VIP'
        WHEN DATEDIFF(MONTH,MIN(s.order_date),MAX(s.order_date)) >= 12 AND SUM(sales_amount) <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_segmentation
    FROM gold.fact_sales AS s
    LEFT JOIN gold.dim_customers AS c
    ON s.customer_key = c.customer_key
    GROUP BY s.customer_key,
             c.first_name,
             c.last_name) t
GROUP BY customer_segmentation
ORDER BY no_of_customer DESC
