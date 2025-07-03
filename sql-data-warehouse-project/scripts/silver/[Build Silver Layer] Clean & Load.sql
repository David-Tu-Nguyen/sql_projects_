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
	WHEN UPPER(TRIM(cst_marital_Status)) = 'M' THEN 'Mariage' -- TRIM(cst_marital_Status)	Xóa khoảng trắng ở đầu và cuối chuỗi cst_marital_Status
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

-- [Build Silver Layer] Clean & Load crm_prd_info
	
INSERT INTO	silver.crm_prd_info(
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
REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, --Extract category ID 
SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,		--Extract product key 
prd_nm,
ISNULL (prd_cost, 0) AS prd_cost,
CASE 
	WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
	WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
	WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
	WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
	ELSE 'n/a'
END prd_line,		--Map product line codes to descriptive values 
CAST (prd_start_dt AS DATE) AS prd_start_dt,
/*Câu lệnh này dùng để xác định ngày kết thúc (prd_end_dt) của một khoảng thời gian hiện tại dựa trên ngày bắt đầu của bản ghi kế tiếp trong cùng nhóm prd_key. 
Ngày kết thúc sẽ là ngày liền trước ngày bắt đầu của bản ghi kế tiếp.*/
CAST (LEAD (prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) AS prd_end_dt  --Calculate end date as one day before the next start date
FROM bronze.crm_prd_info

-- [Build Silver Layer] Clean & Load crm_sales_details

INSERT INTO silver.crm_sales_details (
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,	
	sls_ship_dt,	
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
	)
SELECT 
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	CASE
		WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL 
		ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
	END AS sls_order_dt,	
	CASE
		WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL 
		ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
	END AS sls_ship_dt,	
	CASE
		WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL 
		ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
	END AS sls_due_dt,
	CASE 
		WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != sls_quantity * ABS(sls_price)
		THEN sls_quantity * ABS(sls_price)
		ELSE sls_sales
	END AS sls_sales, 
	sls_quantity,
	CASE
		WHEN sls_price IS NULL OR sls_price <=0
		THEN sls_sales/ NULLIF(sls_quantity,0) --Khi sls_quantity = 0 → KQ trả về NULL
		ELSE sls_price
	END AS sls_price 
FROM bronze.crm_sales_details



 


