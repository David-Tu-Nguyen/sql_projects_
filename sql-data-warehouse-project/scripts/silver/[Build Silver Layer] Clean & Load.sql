-- [Build Silver Layer] Clean & Load crm_cust_info.sql

INSERT INTO silver.crm_cust_info(
	cst_id, 
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_marital_Status,
	cst_gndr,
	cst_create_date)

SELECT 
cst_id, 
cst_key,
TRIM(cst_firstname) AS cst_firstname, 
TRIM(cst_lastname) AS cst_lastname,
CASE 
	WHEN UPPER(TRIM(cst_marital_Status)) = 'M' THEN 'Mariage'
	WHEN UPPER(TRIM(cst_marital_Status)) = 'S' THEN 'Single'
ELSE 'n/a'
END cst_marital_Status,
CASE 
	WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
	WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
ELSE 'n/a'
END cst_gndr,
cst_create_date
FROM (
	SELECT
	*, 
	ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
	FROM bronze.crm_cust_info
	WHERE cst_id IS NOT NULL
)t
WHERE flag_last = 1 

