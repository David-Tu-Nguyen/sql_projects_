/*
===============================================================================
Quality Check of Bronze Table: crm_cust_info
===============================================================================
*/
-- Check For Nulls or Duplicates in Primary 
-- Expectation: No Result

SELECT
cst_id,
COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL 

--Check for unwanted Spaces 
-- Expectation: No Results 
SELECT cst_firstname 
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)


--Data Standardization & Consistency
SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info
  
/*
===============================================================================
Quality Check of Silver Table: crm_cust_info
===============================================================================
*/

-- Check For Nulls or Duplicates in Primary 
-- Expectation: No Result

SELECT
cst_id,
COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL 

--Check for unwanted Spaces 
-- Expectation: No Results 
SELECT cst_firstname 
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)


--Data Standardization & Consistency
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info

SELECT * FROM silver.crm_cust_info

/*
===============================================================================
Quality Check of Bronze Table: crm_prd_info
===============================================================================
*/
-- Check For Nulls or Duplicates in Primary 
-- Expectation: No Result

SELECT
prd_id,
COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL 

--Check for unwanted Spaces 
-- Expectation: No Results 
SELECT prd_nm 
FROM bronze.crm_prd_info
WHERE prd_nm  != TRIM(prd_nm )

-- Check for NULLs or Negative Numbers
-- Expectation: No Results 
SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL
  
--Data Standardization & Consistency
SELECT DISTINCT prd_line
FROM bronze.crm_prd_info

--Check for Invalid Date Orders
SELECT * 
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt

/*
===============================================================================
Quality Check of Silver Table: crm_prd_info
===============================================================================
*/
-- Check For Nulls or Duplicates in Primary 
-- Expectation: No Result

SELECT
prd_id,
COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL 

--Check for unwanted Spaces 
-- Expectation: No Results 
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm  != TRIM(prd_nm )

-- Check for NULLs or Negative Numbers
-- Expectation: No Results 
Select prd_cost
FROM silver.crm_prd_info
WHERE prd_cost <0 OR prd_cost IS NULL

--Data Standardization & Consistency
SELECT DISTINCT prd_line
FROM silver.crm_prd_info

--Check for Invalid Date Orders
SELECT * 
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt

SELECT * 
FROM silver.crm_prd_info
/*
===============================================================================
Quality Check of Bronze Table: crm_sales_details
===============================================================================
*/
--Check for unwanted Spaces 
-- Expectation: No Results 
SELECT sls_ord_num
FROM bronze.crm_sales_details
WHERE sls_ord_num  != TRIM(sls_ord_num)
  
--Check for Invalid Dates 
SELECT 
NULLIF(sls_order_dt,0) sls_order_dt 
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 -- Negative numbers or zeros can not be cast to a date 
OR LEN(sls_order_dt) != 8 
OR sls_order_dt > 20500101
OR sls_order_dt < 19000101

SELECT 
NULLIF(sls_ship_dt,0) sls_ship_dt 
FROM bronze.crm_sales_details
WHERE sls_ship_dt <= 0 -- Negative numbers or zeros can not be cast to a date 
OR LEN(sls_ship_dt) != 8 
OR sls_ship_dt > 20500101
OR sls_ship_dt < 19000101

SELECT 
NULLIF(sls_due_dt,0)sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0 -- Negative numbers or zeros can not be cast to a date 
OR LEN(sls_due_dt) != 8 
OR sls_due_dt > 20500101
OR sls_due_dt < 19000101
  
/*
===============================================================================
Quality Check of Silver Table: crm_sales_details
===============================================================================
*/

--Check for unwanted Spaces 
-- Expectation: No Results 
SELECT sls_ord_num
FROM silver.crm_sales_details
WHERE sls_ord_num  != TRIM(sls_ord_num)

--Check for connected
-- Expectation: No Results 
SELECT sls_prd_key 
FROM silver.crm_sales_details
WHERE sls_prd_key  NOT IN (SELECT prd_key FROM silver.crm_prd_info)

SELECT  sls_cust_id
FROM silver.crm_sales_details
WHERE  sls_cust_id  NOT IN (SELECT cst_id FROM silver.crm_cust_info)

--Check for Invalid Dates 
SELECT 
NULLIF(sls_order_dt,0) sls_order_dt 
FROM silver.crm_sales_details
WHERE sls_order_dt <= 0 -- Negative numbers or zeros can not be cast to a date 
OR LEN(sls_order_dt) != 8 
OR sls_order_dt > 20500101
OR sls_order_dt < 19000101

SELECT 
NULLIF(sls_ship_dt,0) sls_ship_dt 
FROM silver.crm_sales_details
WHERE sls_ship_dt <= 0 -- Negative numbers or zeros can not be cast to a date 
OR LEN(sls_ship_dt) != 8 
OR sls_ship_dt > 20500101
OR sls_ship_dt < 19000101

SELECT 
NULLIF(sls_due_dt,0)sls_due_dt
FROM silversilver.crm_sales_details
WHERE sls_due_dt <= 0 -- Negative numbers or zeros can not be cast to a date 
OR LEN(sls_due_dt) != 8 
OR sls_due_dt > 20500101
OR sls_due_dt < 19000101

-- Check for Invalid Date Orders
SELECT * 
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

-- Check Data Consistency: Between Sales, Quantity, and Price 
-- >> Sales = Quantity * Price
-- >> Values must not be NULL, zero, or negative.

SELECT DISTINCT 
sls_sales,
sls_quantity,
sls_price 
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price 
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL 
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales,
sls_quantity,
sls_price 

SELECT * 
FROM silver.crm_sales_details

/*
===============================================================================
Quality Check of Broze Table: erp_cust_az12
===============================================================================
*/


-- Identify Out-of-Range Dates

SELECT DISTINCT 
bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()

-- Data Standardization & Consistency 
SELECT DISTINCT 
CASE 
	WHEN UPPER(TRIM(gen)) IN ('F', 'Female') THEN 'Female'
	WHEN UPPER(TRIM(gen)) IN ('M', 'Male') THEN 'Male'
	ELSE 'n/a'
END AS gen
FROM bronze.erp_cust_az12
/*
===============================================================================
Quality Check of Silver Table: silver.erp_cust_az12
===============================================================================
*/
-- Identify Out-of-Range Dates

SELECT DISTINCT 
bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()

-- Data Standardization & Consistency 
SELECT DISTINCT  gen
FROM silver.erp_cust_az12

SELECT * 
FROM silver.erp_cust_az12
