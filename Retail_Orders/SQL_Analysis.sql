--1.find top 10 highest revenue generating products 

SELECT TOP 10 
	product_id, 
	SUM(sale_price) as sales
FROM dbo.cleaned_orders
GROUP BY product_id
ORDER BY sales DESC

--2.Find top 5 highest selling products in each region 

WITH highest_region AS (
SELECT 
	region, 
	product_id, 
	SUM(sale_price) AS sales 
FROM dbo.cleaned_orders
GROUP BY region, product_id
)

SELECT * 
FROM(
	SELECT 
		*, 
		ROW_NUMBER() OVER(PARTITION BY region ORDER BY sales DESC) as rank
	FROM highest_region)t
WHERE rank<=5

--3. find month over month growth comparison for 2022 and 2023 sales eg: Jan 2022 vs JAN 2023
WITH sales_over_time AS (
    SELECT 
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        SUM(sale_price) AS sales 
    FROM [dbo].[cleaned_orders]
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT 
    order_month,
    SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
    SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM sales_over_time
GROUP BY order_month
ORDER BY order_month;

--4. For each category which month had highest sales 
WITH order_year_month AS (
    SELECT
        Category,
        DATETRUNC(month, order_date) AS order_year_month,
        SUM(sale_price) AS Sales 
    FROM [dbo].[cleaned_orders]
    GROUP BY Category, DATETRUNC(month, order_date)
),
ranked_sales AS (
    SELECT 
        Category,
        order_year_month,
        Sales,
        ROW_NUMBER() OVER (PARTITION BY Category ORDER BY Sales DESC) AS rn
    FROM order_year_month
)
SELECT *
FROM ranked_sales
WHERE rn = 1;

--5. Which sub-category had the highest growth by profit in 2023 compared to 2022
WITH yearly_sales AS (
    SELECT 
        sub_category,
        YEAR(order_date) AS order_year,
        SUM(sale_price) AS sales
    FROM [dbo].[cleaned_orders]
    GROUP BY sub_category, YEAR(order_date)
),
sales_by_year AS (
    SELECT 
        sub_category,
        SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
        SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
    FROM yearly_sales
    GROUP BY sub_category
)
SELECT TOP 1 
    sub_category,
    sales_2022,
    sales_2023,
    ((sales_2023 - sales_2022) * 100.0 / NULLIF(sales_2022, 0)) AS growth_percent
FROM sales_by_year
ORDER BY growth_percent DESC;
