/*
===============================================================================
Ranking Analysis
===============================================================================
Purpose:
    - To rank items (e.g., products, customers) based on performance or other metrics.
    - To identify top performers or laggards.

SQL Functions Used:
    - Window Ranking Functions: RANK(), DENSE_RANK(), ROW_NUMBER(), TOP
    - Clauses: GROUP BY, ORDER BY
===============================================================================
*/
-- Find average of Sales amount (order value)
SELECT
AVG(sales_amount) AS avg_order_value
FROM gold.fact_sales

-- Which 5 products generate the highest revenue?
SELECT TOP 5
p.product_name,
SUM(s.sales_amount) AS total_revenue
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_products AS p
ON p.product_key = s.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC

-- What are the 5 worst_performing products in term of sales?
SELECT TOP 5
p.product_name,
SUM(s.sales_amount) AS total_revenue
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_products AS p
ON p.product_key = s.product_key
GROUP BY p.product_name
ORDER BY total_revenue ASC

-- Which 5 products(subcategory) generate the highest revenue?
SELECT TOP 5
p.subcategory,
SUM(s.sales_amount) AS total_revenue
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_products AS p
ON p.product_key = s.product_key
GROUP BY p.subcategory
ORDER BY total_revenue DESC

-- What are the 5 worst_performing products(subcategory) in term of sales?
SELECT TOP 5
p.subcategory,
SUM(s.sales_amount) AS total_revenue
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_products AS p
ON p.product_key = s.product_key
GROUP BY p.subcategory
ORDER BY total_revenue ASC

-- Which 5 products generate the highest revenue? By Window Functions
SELECT
product_name,
total_revenue
FROM
   ( SELECT 
    p.product_name AS product_name,
    SUM(s.sales_amount) AS total_revenue,
    DENSE_RANK() OVER(ORDER BY SUM(s.sales_amount) DESC) AS RN
    FROM gold.fact_sales AS s
    LEFT JOIN gold.dim_products AS p
    ON p.product_key = s.product_key
    GROUP BY p.product_name) t
WHERE RN <=5

-- Find the Top-10 cistomers who have generated the highest revenue  
SELECT TOP 10
c.customer_id,
c.first_name,
c.last_name,
SUM(s.sales_amount) AS total_revenue
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_customers AS c
ON c.customer_key = s.customer_key
GROUP BY c.customer_id,
         c.first_name,
         c.last_name
ORDER BY total_revenue DESC

-- Find the 3 customers with the fewest orders placed
SELECT TOP 3
c.customer_id,
c.first_name,
c.last_name,
COUNT( DISTINCT s.order_number) AS total_order
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_customers AS c
ON c.customer_key = s.customer_key
GROUP BY c.customer_id,
         c.first_name,
         c.last_name
ORDER BY total_order ASC
