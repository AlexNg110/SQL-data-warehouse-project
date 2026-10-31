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
-- crm_cust_info 
	INSERT INTO silver.crm_cust_info (
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_marital_status,
		cst_gndr,
		cst_create_date
	)
 
	SELECT
		cst_id,
		cst_key,
		TRIM(cst_firstname) AS cst_firstname,
		TRIM(cst_lastname) AS cst_lastname,
		CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single' --Apply UPPER() in case mixed-case values
			 WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
			 ELSE 'n/a'
		END cst_marital_status,
		CASE WHEN UPPER(cst_gndr) = 'F' THEN 'Female'
			 WHEN UPPER(cst_gndr) = 'M' THEN 'Male'
			 ELSE 'n/a'
		END cst_gndr,
		cst_create_date DATE
	FROM (
		SELECT
		*,
		ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
		FROM bronze.crm_cust_info
		WHERE cst_id IS NOT NULL
	)t
	WHERE flag_last = 1 -- Select the most recent record of each customer

-- crm_prd_info
	INSERT INTO silver.crm_prd_info (
		prd_id,
		cat_id,
		prd_key,
		prd_nm,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt
	)
	
	SELECT
	prd_id,
	REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, -- Extract category ID
	SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,        -- Extract product key
	prd_nm,
	ISNULL(prd_cost, 0) AS prd_cost,
	CASE UPPER(TRIM(prd_line))
		 WHEN 'M' THEN 'Mountain'
		 WHEN 'R' THEN 'Road'
		 WHEN 'S' THEN 'Other Sales'
		 WHEN 'T' THEN 'Touring'
		 ELSE 'n/a'
	END prd_line,
	CAST(prd_start_dt AS DATE) AS prd_start_dt,
	CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) -1 AS DATE) AS prd_end_dt  -- Access values from the next row within a window
	FROM bronze.crm_prd_info
