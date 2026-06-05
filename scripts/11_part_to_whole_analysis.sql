/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
    - To compare performance or metrics across dimensions or time periods.
    - To evaluate differences between categories.
    - Useful for A/B testing or regional comparisons.

SQL Functions Used:
    - SUM(), AVG(): Aggregates values for comparison.
    - Window Functions: SUM() OVER() for total calculations.
===============================================================================
*/
-- Which categories contribute the most to overall sales?
SELECT
  category,
  category_sales,
  SUM(category_sales) OVER () AS total_sales,
  CONCAT(ROUND(( CAST(category_sales AS FLOAT) /SUM(category_sales) OVER ()) * 100,2), '%') AS part_to_whole
FROM 
  (SELECT
  p.category AS category ,
  SUM(s.sales_amount) AS category_sales
  FROM gold.fact_sales AS s
  LEFT JOIN gold.dim_products AS p
  ON p.product_key = s.product_key
  GROUP BY p.category)t
ORDER BY category_sales DESC
