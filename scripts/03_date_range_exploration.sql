/*
===============================================================================
Date Range Exploration 
===============================================================================
Purpose:
    - To determine the temporal boundaries of key data points.
    - To understand the range of historical data.

SQL Functions Used:
    - MIN(), MAX(), DATEDIFF()
===============================================================================
*/

-- Determine the first and last order date and the total duration in months
SELECT
  MIN(order_date) AS first_order_date,
  MAX(order_date) AS last_order_date,
  DATEDIFF(YEAR,MIN(order_date),MAX(order_date)) AS order_range_years
FROM gold.fact_sales;

-- Find the youngest and oldest customer based on birthdate
SELECT
  MIN(birtdate) AS oldest_birtdate,
  DATEDIFF(YEAR,MIN(birtdate),GETDATE()) AS age_of_oldest_customer,
  MAX(birtdate) AS youngest_birtdate,
  DATEDIFF(YEAR,MAX(birtdate),GETDATE()) AS age_of_youngest_customer
FROM gold.dim_customers
