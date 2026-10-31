/*

*/

/*----------------------------------------
Data Quality Check
----------------------------------------*/
-- Check for NULLs or duplicates in PK
SELECT
cst_id,
COUNT (*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) >1 OR cst_id IS NULL

-- Check for unwanted spaces in string values


/*----------------------------------------
End of Quality Check
----------------------------------------*/

-- Main 
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
