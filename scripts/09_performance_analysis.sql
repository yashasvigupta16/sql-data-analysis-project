/*
===============================================================================
Performance Analysis (Year-over-Year, Month-over-Month)
===============================================================================
Purpose:
    - To measure the performance of products, customers, or regions over time.
    - For benchmarking and identifying high-performing entities.
    - To track yearly trends and growth.

SQL Functions Used:
    - LAG(): Accesses data from previous rows.
    - AVG() OVER(): Computes average values within partitions.
    - CASE: Defines conditional logic for trend analysis.
===============================================================================
*/

/* Analyze the yearly performance of products by comparing their sales 
to both the average sales performance of the product and the previous year's sales */
SELECT
product_name,
order_year,
products_sales,
AVG(products_sales) OVER(PARTITION BY product_name) AS avg_sales ,
products_sales - AVG(products_sales) OVER(PARTITION BY product_name) AS diff_avg,
CASE 
    WHEN products_sales - AVG(products_sales) OVER(PARTITION BY product_name) >0 THEN 'Above Average'
    WHEN products_sales - AVG(products_sales) OVER(PARTITION BY product_name) = 0 THEN 'Equal to Average'
    ELSE 'Below Average'
END AS flag,
LAG(products_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS previous_sales,
products_sales - LAG(products_sales) OVER(PARTITION BY product_name ORDER BY order_year)  diff_prev_sales,
CASE 
     WHEN products_sales - LAG(products_sales) OVER(PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
     WHEN products_sales - LAG(products_sales) OVER(PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
     ELSE 'No Change' 
END AS flag
FROM
    (SELECT
    p.product_name AS product_name,
    DATETRUNC(YEAR,s.order_date) AS order_year,
    SUM(s.sales_amount) AS products_sales
    FROM gold.fact_sales AS s
    LEFT JOIN gold.dim_products AS p
    ON p.product_key = s.product_key
    WHERE DATETRUNC(YEAR,s.order_date) IS NOT NULL
    GROUP BY p.product_name,DATETRUNC(YEAR,s.order_date))t
ORDER BY product_name,
order_year
