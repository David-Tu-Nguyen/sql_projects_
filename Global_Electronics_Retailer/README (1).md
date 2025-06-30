# Global_Electronics_Retailer
Sales data for a fictitious global electronics retailer, including tables containing information about transactions, products, customers, stores and currency exchange rates.

# Main objective
Analyze the sales by individual store of a global electronics retailer.
The questions we will answer through this analysis are the following :
  - Analyze the total profit each month of each year based on unit USD; Note: Profit of one products = unit_price - unit_cost
  - Write a SQL query to see customer demographics meaning with format table Age_Group, Gender, Country, State, Count_Customer With Age_Group is 0-17, 18-25, 26,35, 36-45, 46-55, 56+
  - Write a SQL query to determine the months where the month-over-month growth in cumulative profit is significant (at least 10%). Based on unit USD
  - Write a SQL query to find pairs of different Subcategories that are purchased together in the same order. Only include unique pairs (e.g., "Desktops" and "Movie DVD", not both "Desktops"-"Movie DVD" and "Movie DVD"-"Desktops").
  - Create report of the top 2 selling products in each country, category, product name and ranking them accordingly.
  - Write a query to analyze the profitability efficiency of each store.
  - Analyze the total sales in local currency per product by country and category and ranking top 2 each product name of each category within each country
  - Check total quantity make by each day of each customer. Write the query to calcualte total quantity of each customer make in one day.
  - Write the query to calculate total order make by each country for each year.

## Data sources
The data source can be found on kaggle website at [this link](https://www.kaggle.com/datasets/bhavikjikadara/global-electronics-retailers/).

It consists in 6 csv files :

| Table | Description |
| ------------- |:-------------:|
| Data_Dictionary.csv    |In this table, you will find a description of every single column of the other tables. This is probably where you should start in order to have a better comprehension of the data.    |
| Customers.csv     | The customers Dataset. It consists in information about the customers, including their gender, geographic location and birth date.   |
| Exchange_Rates.csv     | A table of exchange rates for 5 currencies vs USD from Jan. 2015 to Feb. 2021. These 5 currencies are the onesin which the sales are expressed.   |
| Products.csv     | The products table. Here, you will find the brand, category, subcategory, color and unit price for each product.    |
| Sales.csv  | The sales dataset, where you will find the order date, the product key associated with the sale, the quantity sold and the store key for each sale. |
| Stores.csv    | The stores dataset. Here you will find the location, surface and opening date of each store.    |

## Methodology and tools used
Tables
| Step  | Used Tools |
| ------------- |:-------------:|
|First Exploratory Data Analysis & Joining Tables     | MS SQL Server    |
|Data Cleaning, Advanced Exploratory Data Analysis & First Visualizations  |     |
|Advanced Data Visualizations & Dashboard    |     |


# Analysis 

## QUESTION 1:
Analyze the total profit each month of each year based on unit USD; 

_**Note**: Profit of one products = unit_price - unit_cost_

### CODE:
    SELECT	
	    YEAR(s.Order_Date) as Year_Order,
	    MONTH(s.Order_Date) as Month_Order,
	    SUM(s.Quantity * (p.Unit_Price_USD - p.Unit_Cost_USD)) as Total_Profit 
    FROM [dbo].[Sales] s
    JOIN [dbo].[Products] p
	    ON s.ProductKey = p.ProductKey
    GROUP BY 
        YEAR(s.Order_Date),
        MONTH(s.Order_Date)
    ORDER BY 
        Year_Order,
        Month_Order;
    
### Output:
![](https://i.imgur.com/ygW8r4y.png)
---

## QUESTION 2:
Write a SQL query to see customer demographics meaning with format table
Age_Group, Gender, Country, State, Count_Customer

With Age_Group is 0-17, 18-25, 26,35, 36-45, 46-55, 56+

### CODE:
    WITH AgeGroup as(
    SELECT CustomerKey, Gender, Country, State,
        CASE
	        WHEN datediff(year,Birthday, getdate()) between 0 and 17 then '0  - 17'
	        WHEN datediff(year,Birthday, getdate()) between 18 and 25 then '18 - 25'
	        WHEN datediff(year,Birthday, getdate()) between 26 and 35 then '26 - 35'
	        WHEN datediff(year,Birthday, getdate()) between 36 and 45 then '36 - 45'
	        WHEN datediff(year,Birthday, getdate()) between 46 and 55 then '46 - 55'
	        Else '56+' 
        END AS AgeGroup
    FROM [dbo].[Customers]
    )
    SELECT
	    AgeGroup, 
	    Gender, 
	    Country, 
	    State,
	    Count (*) as CustomerCount
    FROM AgeGroup
    GROUP BY AgeGroup, Gender, Country, State
    ORDER BY AgeGroup DESC
    
### Output:
![](https://i.imgur.com/89OIac7.png)
---

## QUESTION 3:
Write a SQL query to determine the months where the month-over-month growth in cumulative profit is significant (at least 10%).
Based on unit USD
_**Note**:
 Phép tính phần trăm tăng trưởng (sale_diff): (t2.cumulative_sale - tháng_trước) / tháng_trước * 100
 Tháng trước: LAG(t2.cumulative_sale) OVER (ORDER BY t2.Year_Order, t2.Month_Order)_

### CODE:
    WITH CTE_1 AS (
        SELECT 
           YEAR(Order_Date) AS Year_Order,
          MONTH(Order_Date) AS Month_Order,
          SUM(Quantity * (Unit_Price_USD - Unit_Cost_USD)) AS Total_Profit
        FROM dbo.Sales s
        JOIN Products p 
            ON s.ProductKey = p.ProductKey
        GROUP BY YEAR(Order_Date), MONTH(Order_Date)
        ),

    CTE_2 AS (
        SELECT 
            Year_Order, 
            Month_Order,
            SUM(Total_Profit) OVER (ORDER BY Year_Order, Month_Order) AS cummulative_sale
        FROM CTE_1
    ),

    CTE_3 as (
        SELECT 
	        CTE_2.Year_Order, CTE_2.Month_Order, cummulative_sale,
	        ROUND (
	            ((CTE_2.cummulative_sale - LAG(CTE_2.cummulative_sale) OVER (ORDER BY CTE_2.Year_Order, CTE_2.Month_Order))/ (LAG(CTE_2.cummulative_sale) OVER (ORDER BY CTE_2.Year_Order, CTE_2.Month_Order)) * 100),0
	        ) AS Sale_diff
        FROM CTE_2)


SELECT * from CTE_3
Where sale_diff >= 10;
    
### Output:
![](https://i.imgur.com/BdLkXmf.png)
---

## QUESTION 4:
Write a SQL query to find pairs of different Subcategories that are purchased together in the same order. 
Only include unique pairs (e.g., "Desktops" and "Movie DVD", not both "Desktops"-"Movie DVD" and "Movie DVD"-"Desktops").

**Display the following columns:**
SubCategory_1
SubCategory_2
Count_Pair (number of times the two subcategories appear together in an order)
Rank_Pair (ranking based on highest Count_Pair)

Sort the result by Count_Pair in descending order.


### CODE:
    WITH SalesWithSubCategory AS (
        SELECT 
            s.Order_Number,
            p.SubCategory
        FROM Sales s
        JOIN Products p 
            ON s.ProductKey = p.ProductKey
        ),
    SubcategoryPairs AS (
        SELECT 
            a.Order_Number,
            a.SubCategory AS SubCategory_1,
            b.SubCategory AS SubCategory_2
        FROM SalesWithSubCategory a
        JOIN SalesWithSubCategory b
            ON a.Order_Number = b.Order_Number
        AND a.SubCategory < b.SubCategory  -- ensures unique and no self-pairs
        )
    SELECT 
        SubCategory_1,
        SubCategory_2,
        COUNT(*) AS Count_Pair,
        RANK() OVER (ORDER BY COUNT(*) DESC) AS Rank_Pair
    FROM SubcategoryPairs
    GROUP BY SubCategory_1, SubCategory_2
    ORDER BY Count_Pair DESC;
    
### Output:
![](https://i.imgur.com/zMjh9is.png)
---

## QUESTION 5:
Create report of the top 2 selling products in each country, category, product name and ranking them accordingly.

### CODE:
    With CTE_1 as (
        SELECT 
            p.Category,
	        c.Country,
	        p.Product_Name,
	        sum(s.quantity) as total_quantity,
	        row_number () over (PARTITION by p.Category, c.CountrY order by sum(s.quantity) desc) as ranking
	    FROM Sales s
        JOIN Products p 
            ON s.ProductKey = p.ProductKey
        JOIN Customers c 
            ON s.CustomerKey = c.CustomerKey
        GROUP BY c.Country, p.Category, p.Product_Name
        )
        
        SELECT *
        FROM CTE_1
        Where Ranking <= 2
    
### Output:
![](https://i.imgur.com/kmtYsY4.png)
---

## QUESTION 6:
Write a query to analyze the profitability efficiency of each store by calculating:

    The total profit in local currency (TotalProfitLocalCurrency)
    The profit per square meter (ProfitPerSquareMeter)
    A ranking of stores based on ProfitPerSquareMeter in descending order
    The final output should include: StoreKey, Country, State, Square_Meters, TotalProfitLocalCurrency, ProfitPerSquareMeter, and Ranking.


### CODE:
    WITH CTE_1 AS (
        SELECT
            st.StoreKey,
            st.Country,
            st.State,
            st.Square_Meters,
            ROUND(SUM(s.Quantity * p.Unit_Price_USD * er.Exchange),2) AS TotalProfitLocalCurrency
        FROM Sales s
        JOIN Stores st 
            ON s.StoreKey = st.StoreKey
        JOIN Products p 
            ON s.ProductKey = p.ProductKey
        JOIN Exchange_Rates er 
            ON s.Currency_Code = er.Currency 
        AND s.Order_Date = er.Date
        GROUP BY st.StoreKey, st.Country, st.State, st.Square_Meters
    ),
    CTE_2 AS (
        SELECT 
            StoreKey,
            Country,
            State,
            Square_Meters,
            TotalProfitLocalCurrency,
            ROUND(TotalProfitLocalCurrency / NULLIF(Square_Meters, 0), 2) AS ProfitPerSquareMeter
        FROM CTE_1
    )

    SELECT *,
    RANK() OVER (ORDER BY ProfitPerSquareMeter DESC) AS Ranking
    FROM CTE_2;
    
### Output:
![](https://i.imgur.com/CrIhgkU.png)
---

## QUESTION 7:
Same as QUESTION 5 output
Analyze the total sales in local currency per product by country and category and ranking top 2 each product name of each category within each country

### CODE:
    -- CTE to calculate total sales per product by country in local currency
    WITH ProductSalesByCountry AS (
        SELECT
            c.Country,
            p.Product_Name,
		    p.Category,
            SUM(s.Quantity * p.Unit_Price_USD * er.Exchange) AS TotalSalesLocalCurrency
        FROM Sales s
        JOIN Customers c 
            ON s.CustomerKey = c.CustomerKey
        JOIN Products p 
            ON s.ProductKey = p.ProductKey
        JOIN Exchange_Rates er 
            ON s.Currency_Code = er.Currency AND s.Order_Date = er.Date
        GROUP BY p.Category, c.Country, p.Product_Name
    ),

-- CTE to rank products within each country, category and  based on total sales in local currency
    RankedProductSales AS (
        SELECT
            Country,
            Product_Name,
		    Category,
            TotalSalesLocalCurrency,
            ROW_NUMBER() OVER (PARTITION BY Country, Category ORDER BY TotalSalesLocalCurrency DESC) AS CountryRank
        FROM ProductSalesByCountry
    )

-- Final query to select the top 2 products by total sales in local currency in each country
    SELECT 
	    Category,
        Country,
        Product_Name,
        CountryRank
    FROM 
        RankedProductSales
    WHERE 
        CountryRank <= 2
    ORDER BY 
        Category, Country, CountryRank;
    
### Output:
![](https://i.imgur.com/MXplkqi.png)
---

## QUESTION 8:
Check total quantity make by each day of each customer.
Write the query to calcualte total quantity of each customer make in one day

### CODE:
    -- Declare a specific order date for analysis
    DECLARE @TargetOrderDate DATE = '2016-01-01';

    -- Query: Total quantity purchased per customer on the target order date
    SELECT
        c.CustomerKey,
        c.Name,
        c.City,
        c.State,
        c.Country,
        COUNT(DISTINCT s.Order_Number) AS Total_Orders,
        SUM(s.Quantity) AS Total_Quantity,
        MIN(s.Order_Date) AS First_Order_Date,
        MAX(s.Delivery_Date) AS Last_Delivery_Date
    FROM Customers c
    JOIN Sales s 
        ON c.CustomerKey = s.CustomerKey
    WHERE
        s.Order_Date = @TargetOrderDate
    GROUP BY
        c.CustomerKey,
        c.Name,
        c.City,
        c.State,
        c.Country
    ORDER BY
        Total_Quantity DESC;
    
### Output:
![](https://i.imgur.com/YEhFGeZ.png)
---

## QUESTION 9:
Write the query to calculate total order make by each country for each year
Format table
Country, Year 1, Year 2, Year 3,...

### CODE:
    WITH SalesByCountryYear AS (
        SELECT 
            c.Country,
            YEAR(s.Order_Date) AS OrderYear,
            COUNT(DISTINCT s.Order_Number) AS TotalOrder
        FROM Sales s
        JOIN Customers c 
            ON s.CustomerKey = c.CustomerKey
        WHERE s.Order_Date IS NOT NULL
        GROUP BY c.Country, YEAR(s.Order_Date)
    )
    SELECT 
        Country,
        [2016], [2017]
    FROM SalesByCountryYear
    PIVOT (
        SUM(TotalOrder)
        FOR OrderYear IN ([2016], [2017])
    ) AS p
ORDER BY Country;
    
### Output:
![](https://i.imgur.com/eZ5Laao.png)

