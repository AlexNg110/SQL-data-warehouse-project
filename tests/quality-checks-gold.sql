/*
Data quality check after loading gold layer
*/

-- Check if all dimension tables can successfully join the fact table
SELECT *
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
WHERE c.customer_key IS NULL

  
SELECT *
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
ON p.product key = f.product_key
WHERE c.product_key IS NULL
