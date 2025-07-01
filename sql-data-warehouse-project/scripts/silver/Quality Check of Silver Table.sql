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


--Data Standardization & Consistency
SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

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


--Data Standardization & Consistency
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

SELECT DISTINCT prd_line
FROM silver.crm_prd_info

--Check for Invalid Date Orders
SELECT * 
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt

SELECT * 
FROM silver.crm_prd_info
