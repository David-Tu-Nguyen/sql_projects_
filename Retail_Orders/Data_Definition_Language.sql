EXEC sp_rename 'dbo.cleaned_orders', 'cleaned_orders_old';

CREATE TABLE [dbo].[cleaned_orders] (
	[order_id] int primary key, 
	[order_date] date,
	[ship_mode] varchar(20),
	[segment] varchar(20),
	[country]	varchar(20),
	[city] varchar(20),
	[state] varchar(20),
	[postal_code] varchar(20),
	[region] varchar(20),
	[category] varchar(20),
	[sub_category] varchar(20),
	[product_id] varchar(50),
	[quantity] int,
	[discount] decimal(7,2),
	[sale_price] decimal(7,2),
	[profit] decimal(7,2)
);
GO

INSERT INTO dbo.cleaned_orders (
	order_id, 
	order_date, 
	ship_mode, 
	segment, 
	country, 
	city, 
	state, 
	postal_code, 
	region, 
	category, 
	sub_category, 
	product_id, 
	quantity, 
	discount, 
	sale_price, 
	profit
)
SELECT
	CAST(order_id AS INT),
	order_date,
	CAST(ship_mode AS VARCHAR(20)),
	CAST(segment AS VARCHAR(20)),
	CAST(country AS VARCHAR(20)),
	CAST(city AS VARCHAR(20)),
	CAST(state AS VARCHAR(20)),
	CAST(postal_code AS VARCHAR(20)),
	CAST(region AS VARCHAR(20)),
	CAST(category AS VARCHAR(20)),
	CAST(sub_category AS VARCHAR(20)),
	CAST(product_id AS VARCHAR(50)),
	CAST(quantity AS INT),
	CAST(discount AS DECIMAL(7,2)),
	CAST(sale_price AS DECIMAL(7,2)),
	CAST(profit AS DECIMAL(7,2))
FROM dbo.cleaned_orders_old;

SELECT * FROM cleaned_orders