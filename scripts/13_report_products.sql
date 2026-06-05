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
-- =============================================================================
-- Create Report: gold.report_products
-- =============================================================================
IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
    DROP VIEW gold.report_products;
GO

CREATE VIEW gold.report_products AS
WITH base_query AS
/* ---------------------------------------------------
1) Base Query: Retrieves core columns from tables
----------------------------------------------------*/
(SELECT
	s.order_number,
	s.customer_key,
	s.sales_amount,
	s.quantity,
	s.order_date,
	p.product_key,
	p.product_name,
	p.category,
	p.subcategory,
	p.product_cost
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_products AS p
ON p.product_key = s.product_key)

, product_aggregrations AS
/* ---------------------------------------------------
2) Product Aggregations: Summarize key metrics at the Product level
----------------------------------------------------*/
(SELECT 
	product_key,
	product_name,
	category,
	subcategory,
	product_cost,
	COUNT(DISTINCT order_number) AS total_orders,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	COUNT(DISTINCT customer_key) AS total_customers,
	MAX(order_date) AS last_order,
	DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS lifespan,
	ROUND(AVG(CAST(sales_amount AS FLOAT)/ NULLIF(quantity,0)),2) AS avg_selling_price
FROM base_query
GROUP BY product_key,
		product_name,
		category,
		subcategory,
		product_cost)

SELECT
		product_key,
		product_name,
		category,
		subcategory,
		product_cost,
		last_order,
		DATEDIFF(MONTH, last_order,GETDATE()) AS recency_in_months,
		CASE 
			WHEN total_sales > 50000 THEN 'High-Performer'
			WHEN total_sales >= 10000 THEN 'Mid_Range'
			ELSE 'Low-Performer'
		END AS product_segment,
	    lifespan
		total_orders,
		total_sales,
		total_quantity,
		total_customers,
		-- Calculate Average Order Revenue (AO
		CASE
			WHEN total_orders = 0 THEN 0                     
			ELSE total_sales/total_orders
		END AS average_order_revenue,

		--Calculate average monthly revenue
		CASE
			WHEN lifespan = 0 THEN total_sales
			ELSE total_sales/lifespan
		END AS average_monthly_revenue
FROM product_aggregrations
