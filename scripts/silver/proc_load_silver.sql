/*


Script from data quality check for bronze layer can be used to verify the quality of data in the silver layer
*/


/*----------------------------------------
Data Quality Check (example crm_cust_info, crm_prd_info)
----------------------------------------*/
-- Check for NULLs or duplicates in PK
SELECT
cst_id,
COUNT (*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL

-- Check for unwanted spaces in string values
SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname) -- Remove leading and trailing spaces from strings
-- Continue for all columns with string values

-- Check the consistency of values in low cardinality columns / Data standardization
SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info
-- Continue for all columns with values in low cardinality

-- Check for negative values or NULL
SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL 

-- Check for invalid date orders
SELECT *
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt

/*----------------------------------------
End of Quality Check
----------------------------------------*/

-- Main script
SELECT
*
FROM (
	SELECT
	*,
	ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
	FROM bronze.crm_cust_info
	WHERE cst_id IS NOT NULL
)t
WHERE flag_last = 1 -- Select the most recent record of each customer
