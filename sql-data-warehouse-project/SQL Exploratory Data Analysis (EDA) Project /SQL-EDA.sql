/*
===============================================
1. Step 1: Database Exploration 
================================================
Purpose:
    - To explore the structure of the database, including the list of tables and their schemas.
    - To inspect the columns and metadata for specific tables.

Table Used:
    - INFORMATION_SCHEMA.TABLES
    - INFORMATION_SCHEMA.COLUMNS
===============================================================================
*/
-- Explore All Object in the Database
SELECT * 
FROM INFORMATION_SCHEMA.TABLES

-- Explore All coulums in the Database
SELECT * FROM INFORMATION_SCHEMA.COLUMNS

/*
===============================================================================
2. Step 2: Dimensions Exploration
===============================================================================
Purpose:
    - To explore the structure of dimension tables.
	
SQL Functions Used:
    - DISTINCT
    - ORDER BY
===============================================================================
*/

-- Explore All countries our customers come from. '
SELECT DISTINCT country FROM gold.dim_customers

-- Explore All Categories "The major Divisions"
SELECT DISTINCT category, subcategory, product_name  FROM gold.dim_products 
ORDER BY 1,2,3

/*
===============================================================================
3. Step 3: Date Range Exploration 
===============================================================================
Purpose:
    - To determine the temporal boundaries of key data points.
    - To understand the range of historical data.

SQL Functions Used:
    - MIN(), MAX(), DATEDIFF()
===============================================================================
*/

-- Find the date of the first and last order 
SELECT 
	MIN(order_date) first_order_date,  
	MAX(order_date) first_order_date  
FROM gold.fact_sales 

-- How many years/months of sales are available 
SELECT 
	MIN(order_date) first_order_date,  
	MAX(order_date) first_order_date,  
	DATEDIFF(year, MIN(order_date), MAX(order_date)) AS order_range_years, 
	DATEDIFF(month, MIN(order_date), MAX(order_date)) AS order_range_years 
FROM gold.fact_sales 

-- Find the youngest and the oldest customer 
SELECT 
	MIN(birthdate) AS oldest_birthdate,
	DATEDIFF(year, MIN(birthdate), GETDATE()) AS oldest_age,
	MAX(birthdate) AS youngest_birthdate,
	DATEDIFF(year, MAX(birthdate), GETDATE()) AS youngest_age
FROM gold.dim_customers 

/*
===============================================================================
4. Step 4: Measures Exploration (Key Metrics)
===============================================================================
Purpose:
    - To calculate aggregated metrics (e.g., totals, averages) for quick insights.
    - To identify overall trends or spot anomalies.

SQL Functions Used:
    - COUNT(), SUM(), AVG()
===============================================================================
*/

SELECT 
	SUM(sales_amount) As total_sales, -- Find the Total Sales
	SUM(quantity) As total_quantity, -- Find how many items are sold 
	AVG(price) AS avg_price, -- Find the average selling price
	COUNT(DISTINCT order_number) AS total_orders, -- Find the Total number of Orders
	COUNT(product_key) AS total_products,
	COUNT(DISTINCT product_key) AS total_products, -- Find the total number of products 
	COUNT(customer_key) AS total_customers, -- Find the total number of customers 
	COUNT(DISTINCT customer_key) AS total_customers -- Find the total number of customers that has placed an order 
FROM gold.fact_sales 

--Generate a Report that shows all key metrics of the business 
SELECT 'Total Sales' as measure_name, SUM (sales_amount) AS measure_Value FROM gold.fact_sales 
UNION ALL 
SELECT 'Total Quantity' as measure_name, SUM (quantity) AS measure_Value FROM gold.fact_sales
UNION ALL 
SELECT 'Average Price', AVG(price) FROM gold.fact_sales
UNION ALL 
SELECT 'Total Nr.Orders', COUNT(DISTINCT order_number) FROM gold.fact_sales
UNION ALL 
SELECT 'Total Nr.Products', COUNT(product_name) FROM gold.dim_products
UNION ALL 
SELECT 'Total Nr.Customers', COUNT(customer_key) FROM gold.dim_customers

/*
===============================================================================
5. Step 5: Magnitude Analysis
===============================================================================
Purpose:
    - To quantify data and group results by specific dimensions.
    - For understanding data distribution across categories.

SQL Functions Used:
    - Aggregate Functions: SUM(), COUNT(), AVG()
    - GROUP BY, ORDER BY
===============================================================================
*/

-- Find total customers by countries 
SELECT 
	country,
	COUNT(customer_key) AS total_Customers
FROM gold.dim_customers
GROUP BY country 
ORDER BY total_customers DESC 

-- Find total customers by gender
SELECT 
	gender,
	COUNT(customer_key) AS total_Customers
FROM gold.dim_customers
GROUP BY gender 
ORDER BY total_customers DESC 

-- Find total products by category 
SELECT 
	category, 
	COUNT(product_key) AS total_products
FROM gold.dim_products
GROUP BY category 
ORDER BY total_products DESC 

-- What is the average costs in each category?
SELECT 
	category, 
	AVG(cost) AS avg_costs
FROM gold.dim_products
GROUP BY category
ORDER BY avg_costs DESC 

-- What is the total revenue generated for each category?
SELECT 
	p.category, 
	SUM(f.sales_amount) total_revenue 
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
	ON p.product_key = f.product_key 
GROUP BY p.category 
ORDER BY total_revenue DESC 

-- What is the total revenue generated by each customer?
SELECT 
	c.customer_key,
	c.first_name,
	c.last_name,
	SUM(f.sales_amount) AS total_revenue 
FROM gold.fact_sales f 
LEFT JOIN gold.dim_customers c 
	ON c.customer_key = f.customer_key
GROUP BY 
c.customer_key, 
c.first_name, 
c.last_name
ORDER BY total_revenue DESC

-- What is the distribution of sold items across countries?
SELECT 
	c.country,
	SUM(f.quantity) AS total_sold_items 
FROM gold.fact_sales f 
LEFT JOIN gold.dim_customers c 
	ON c.customer_key = f.customer_key
GROUP BY 
c.country 
ORDER BY total_sold_items  DESC

/*
===============================================================================
Step 6: Ranking Analysis
===============================================================================
Purpose:
    - To rank items (e.g., products, customers) based on performance or other metrics.
    - To identify top performers or laggards.

SQL Functions Used:
    - Window Ranking Functions: RANK(), DENSE_RANK(), ROW_NUMBER(), TOP
    - Clauses: GROUP BY, ORDER BY
===============================================================================
*/

-- Which 5 products generate the highest revenue?
SELECT TOP 5 
	p.product_name, 
	SUM(f.sales_amount) total_revenue 
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
	ON p.product_key = f.product_key 
GROUP BY p.product_name 
ORDER BY total_revenue DESC 

-- What are the 5 worst-performing products in terms of sales?

SELECT TOP 5 
	p.product_name, 
	SUM(f.sales_amount) total_revenue 
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
	ON p.product_key = f.product_key 
GROUP BY p.product_name 
ORDER BY total_revenue ASC

--- Option 2: Complex but Flexibly Ranking Using Window Functions
SELECT * 
FROM (
SELECT 
	p.product_name, 
	SUM(f.sales_amount) total_revenue, 
	ROW_NUMBER() OVER(ORDER BY SUM(f.sales_amount) DESC) AS rank_products 
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
	ON p.product_key = f.product_key 
GROUP BY p.product_name)t
WHERE rank_products <=5


-- Find the top 10 customers who have generated the highest revenue 
SELECT TOP 10
	c.customer_key,
	c.first_name,
	c.last_name,
	SUM(f.sales_amount) AS total_revenue 
FROM gold.fact_sales f 
LEFT JOIN gold.dim_customers c 
	ON c.customer_key = f.customer_key
GROUP BY 
c.customer_key, 
c.first_name, 
c.last_name
ORDER BY total_revenue DESC

-- The 3 customers with the fewest orders placed 
SELECT TOP 3
	c.customer_key,
	c.first_name,
	c.last_name,
	COUNT(DISTINCT order_number) AS total_orders 
FROM gold.fact_sales f 
LEFT JOIN gold.dim_customers c 
	ON c.customer_key = f.customer_key
GROUP BY 
c.customer_key, 
c.first_name, 
c.last_name
ORDER BY total_orders
