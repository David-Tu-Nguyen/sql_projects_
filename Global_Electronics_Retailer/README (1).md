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

