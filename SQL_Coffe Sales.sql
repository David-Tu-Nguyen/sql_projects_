SELECT * FROM [dbo].[Coffee Shop Salescsv]
/*
===============================================
0.Step 0: Add computed columns (run once if needed)
================================================
*/

ALTER TABLE [dbo].[Coffee Shop Salescsv]
ADD total_sales AS ROUND(transaction_qty * unit_price, 2),
    transaction_month AS MONTH(CAST(transaction_date AS DATE)),
    transaction_year AS YEAR(CAST(transaction_date AS DATE));

ALTER TABLE [dbo].[Coffee Shop Salescsv]
DROP COLUMN total_sales, transaction_month, transaction_year;
/*
===============================================
1. Step 1: Database Exploration 
================================================
*/

SELECT * 
FROM INFORMATION_SCHEMA.TABLES

SELECT * FROM INFORMATION_SCHEMA.COLUMNS

-- Total number of rows
SELECT COUNT(*) AS total_rows FROM [dbo].[Coffee Shop Salescsv]



/*
===============================================================================
2. Step 2: Dimensions Exploration
===============================================================================
*/
SELECT DISTINCT store_id
FROM [dbo].[Coffee Shop Salescsv]

-- Unique store locations
SELECT DISTINCT store_location FROM [dbo].[Coffee Shop Salescsv];

-- Unique product categories
SELECT DISTINCT product_category FROM [dbo].[Coffee Shop Salescsv];

-- Unique product types
SELECT DISTINCT product_type FROM [dbo].[Coffee Shop Salescsv];

SELECT DISTINCT transaction_date 
FROM [dbo].[Coffee Shop Salescsv]



/*
===============================================================================
3. Step 3: Date Range Exploration 
===============================================================================
*/
-- Find the date of the first and last order 
SELECT 
	MIN(transaction_date) first_order_date,  
	MAX(transaction_date) first_order_date  
FROM [dbo].[Coffee Shop Salescsv]

-- How many years/months of sales are available 
SELECT 
	MIN(transaction_date) first_order_date,  
	MAX(transaction_date) first_order_date,  	
	DATEDIFF(year, MIN(transaction_date), MAX(transaction_date)) AS order_range_years, 
	DATEDIFF(month, MIN(transaction_date), MAX(transaction_date)) AS order_range_years
FROM [dbo].[Coffee Shop Salescsv]

-- Count transactions by year and month
SELECT 
    YEAR(CAST(transaction_date AS DATE)) AS year,
    MONTH(CAST(transaction_date AS DATE)) AS month,
    COUNT(*) AS transaction_count
FROM [dbo].[Coffee Shop Salescsv]
GROUP BY YEAR(CAST(transaction_date AS DATE)), MONTH(CAST(transaction_date AS DATE))
ORDER BY year, month;

/*
===============================================================================
4. Step 4: Measures Exploration (Key Metrics)
===============================================================================
*/
-- Total revenue (sales = qty × unit_price)
SELECT 
	ROUND(SUM(transaction_qty * unit_price),2) AS total_sales
FROM [dbo].[Coffee Shop Salescsv];

-- Total quantity sold
SELECT 
    SUM(transaction_qty) AS total_quantity
FROM [dbo].[Coffee Shop Salescsv];

-- Average unit price
SELECT 
    AVG(unit_price) AS avg_unit_price
FROM [dbo].[Coffee Shop Salescsv];

-- Average basket value (average sale)
SELECT 
    AVG(transaction_qty * unit_price) AS avg_transaction_value
FROM [dbo].[Coffee Shop Salescsv];	

/*
===============================================================================
5. Step 5: Magnitude Analysis
===============================================================================
*/
-- Sales by category
SELECT 
    product_category,
    ROUND(SUM(transaction_qty * unit_price),2) AS total_sales
FROM [dbo].[Coffee Shop Salescsv]
GROUP BY product_category
ORDER BY total_sales DESC;

-- Sales by store location
SELECT 
    store_location,
    ROUND(SUM(transaction_qty * unit_price),2) AS total_sales
FROM [dbo].[Coffee Shop Salescsv]
GROUP BY store_location
ORDER BY total_sales DESC;

/*
===============================================================================
6. Step 6: Ranking Analysis
===============================================================================
*/

-- Top 5 products by revenue
SELECT TOP 5 
    product_detail,
    SUM(transaction_qty * unit_price) AS revenue
FROM [dbo].[Coffee Shop Salescsv]
GROUP BY product_detail
ORDER BY revenue DESC;

-- Top 5 product categories by volume
SELECT TOP 5 
    product_category,
    SUM(transaction_qty) AS quantity_sold
FROM [dbo].[Coffee Shop Salescsv]
GROUP BY product_category
ORDER BY quantity_sold DESC;

/*
===============================================================================
7. Step 7: Change Over Time Analysis
===============================================================================
*/

-- Monthly revenue trend
SELECT 
    YEAR(CAST(transaction_date AS DATE)) AS year,
    MONTH(CAST(transaction_date AS DATE)) AS month,
	DATETRUNC(month, transaction_date) AS month_trunc,
    ROUND(SUM(transaction_qty * unit_price),2) AS total_sales
FROM [dbo].[Coffee Shop Salescsv]
GROUP BY YEAR(CAST(transaction_date AS DATE)), MONTH(CAST(transaction_date AS DATE)),DATETRUNC(month, transaction_date)
ORDER BY YEAR(CAST(transaction_date AS DATE)), MONTH(CAST(transaction_date AS DATE)),DATETRUNC(month, transaction_date);
/*
===============================================================================
8. Step 8: Cumulative Analysis
===============================================================================
*/
-- Cumulative Monthly Sales
WITH monthly_sales AS (
    SELECT 
        YEAR(CAST(transaction_date AS DATE)) AS transaction_year,
        MONTH(CAST(transaction_date AS DATE)) AS transaction_month,
        SUM(transaction_qty * unit_price) AS monthly_sales
    FROM [dbo].[Coffee Shop Salescsv]
    GROUP BY YEAR(CAST(transaction_date AS DATE)), MONTH(CAST(transaction_date AS DATE))
)
SELECT *,
       SUM(monthly_sales) OVER (
           PARTITION BY transaction_year 
           ORDER BY transaction_month
        
       ) AS cumulative_sales
FROM monthly_sales
ORDER BY transaction_year, transaction_month;

/*
===============================================================================
9. Step 9: Performance Analysis
===============================================================================
*/
-- Month-over-Month Growth
WITH monthly_sales AS (
    SELECT 
        YEAR(CAST(transaction_date AS DATE)) AS transaction_year,
        MONTH(CAST(transaction_date AS DATE)) AS transaction_month,
        ROUND(SUM(transaction_qty * unit_price),2) AS total_sales
    FROM [dbo].[Coffee Shop Salescsv]
    GROUP BY YEAR(CAST(transaction_date AS DATE)), MONTH(CAST(transaction_date AS DATE))
),
sales_with_lag AS (
    SELECT *,
           ROUND(
		   LAG(total_sales) OVER (ORDER BY transaction_year, transaction_month),2) AS prev_month_sales
    FROM monthly_sales
)
SELECT *,
       
	ROUND((1.0 * (total_sales - prev_month_sales)) / NULLIF(prev_month_sales, 0) * 100, 2) AS mom_growth_pct,
	CASE 
		WHEN total_sales - LAG(total_sales) OVER (ORDER BY transaction_year, transaction_month) > 0 THEN 'Increase'
		WHEN total_sales - LAG(total_sales) OVER (ORDER BY transaction_year, transaction_month) < 0 THEN 'Decrease'
		ELSE 'No Change'
	END AS prev_change
FROM sales_with_lag;

 -- Year-over-Year Growth

/*
===============================================================================
10. Step 10: Part-to-Whole Analysis 
===============================================================================
*/
-- By Category
SELECT 
    product_category,
    SUM(transaction_qty * unit_price) AS total_sales,
    ROUND(
		CAST(SUM(transaction_qty * unit_price) AS FLOAT)  / SUM(SUM(transaction_qty * unit_price)) OVER () *100
		, 2) AS percentage_of_total_sales
FROM [dbo].[Coffee Shop Salescsv]
GROUP BY product_category
ORDER BY percentage_of_total_sales DESC;

-- By Product Type
SELECT 
    product_type,
    SUM(transaction_qty * unit_price) AS product_type_sales,
    ROUND(SUM(transaction_qty * unit_price) * 100.0 / SUM(SUM(transaction_qty * unit_price)) OVER (), 2) AS pct_of_total_sales
FROM [dbo].[Coffee Shop Salescsv]
GROUP BY product_type
ORDER BY pct_of_total_sales DESC;
/*
===============================================================================
11. Step 11: Data Segmentation Analysis
===============================================================================
*/

-- Optional: Add time of day column
-- Morning: 5–11, Afternoon: 12–17, Evening: 18–23, Night: 0–4

ALTER TABLE [dbo].[Coffee Shop Salescsv]
ADD transaction_hour AS DATEPART(HOUR, CAST(transaction_time AS time));

-- Segmentation
SELECT 
    store_location,
    CASE 
        WHEN transaction_hour BETWEEN 5 AND 11 THEN 'Morning'
        WHEN transaction_hour BETWEEN 12 AND 17 THEN 'Afternoon'
        WHEN transaction_hour BETWEEN 18 AND 23 THEN 'Evening'
        ELSE 'Night'
    END AS time_of_day,
    ROUND(
	SUM(transaction_qty * unit_price),2) AS total_sales
FROM [dbo].[Coffee Shop Salescsv]
GROUP BY store_location,
         CASE 
             WHEN transaction_hour BETWEEN 5 AND 11 THEN 'Morning'
             WHEN transaction_hour BETWEEN 12 AND 17 THEN 'Afternoon'
             WHEN transaction_hour BETWEEN 18 AND 23 THEN 'Evening'
             ELSE 'Night'
         END
ORDER BY store_location, total_sales DESC;

--

WITH hourly_sales AS (
    SELECT 
        transaction_hour, 
        ROUND(SUM(transaction_qty * unit_price), 2) AS total_sales
    FROM [dbo].[Coffee Shop Salescsv]
    GROUP BY transaction_hour
)
SELECT *,
       DENSE_RANK() OVER (ORDER BY total_sales DESC) AS sales_rank
FROM hourly_sales
ORDER BY sales_rank;