/*
  Pizza Hut Sales Analysis - SQL KPIs (SQL Server / T-SQL)

  Data    : pizza sales, 1 Jan 2015 - 31 Dec 2015 (358 trading days). Source CSVs are in /pizza_sales.
  Tables  : orders (21,350 rows), order_details (48,620 rows), pizzas (96 rows), pizza_types (32 rows)

  Definitions used in this file
    order        = one row in orders                (21,350)
    order line   = one row in order_details         (48,620)
    pizzas sold  = SUM(order_details.quantity)      (49,574)

  The data has no currency field, so revenue is shown without a currency symbol.
*/

USE pizza_sales;

/* ---------- 0. Data validation (run first) ---------- */

-- Row count per table. Expected: orders 21350, order_details 48620, pizzas 96, pizza_types 32
SELECT 'orders' AS table_name, COUNT(*) AS row_count FROM [dbo].[orders]
UNION ALL SELECT 'order_details', COUNT(*) FROM [dbo].[order_details]
UNION ALL SELECT 'pizzas',        COUNT(*) FROM [dbo].[pizzas]
UNION ALL SELECT 'pizza_types',   COUNT(*) FROM [dbo].[pizza_types];

-- Duplicate order IDs. Expected: 0
SELECT COUNT(*) - COUNT(DISTINCT order_id) AS duplicate_order_ids FROM [dbo].[orders];

-- Order lines with no matching pizza or order (orphans). Expected: 0 and 0
SELECT COUNT(*) AS orphan_pizza_ids
FROM [dbo].[order_details] AS od
LEFT JOIN [dbo].[pizzas] AS p ON od.pizza_id = p.pizza_id
WHERE p.pizza_id IS NULL;

SELECT COUNT(*) AS orphan_order_ids
FROM [dbo].[order_details] AS od
LEFT JOIN [dbo].[orders] AS o ON od.order_id = o.order_id
WHERE o.order_id IS NULL;

-- NULLs in the columns the KPIs depend on. Expected: 0 in every column
SELECT
    SUM(CASE WHEN od.order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN od.pizza_id IS NULL THEN 1 ELSE 0 END) AS null_pizza_id,
    SUM(CASE WHEN od.quantity IS NULL THEN 1 ELSE 0 END) AS null_quantity
FROM [dbo].[order_details] AS od;

/* ---------- KPIs ---------- */

-- KPI 1a -- Total pizzas sold (sum of quantity).   Result: 49574
SELECT SUM(quantity) AS Total_Pizzas_Sold FROM [dbo].[order_details];

-- KPI 1b -- Total orders placed.   Result: 21350
SELECT COUNT(DISTINCT order_id) AS Total_Orders FROM [dbo].[orders];

-- KPI 2 -- Calculate the total revenue generated from pizza sales.   Result: 817860.05
SELECT ROUND(SUM(quantity * price),2) AS Total_Revenue FROM [dbo].[order_details] AS a
JOIN [dbo].[pizzas] AS b
ON a.pizza_id=b.pizza_id;

-- KPI 3 -- Identify the highest-priced pizza.   Result: 35.95
SELECT MAX(price) AS Highest_Price_Pizza FROM [dbo].[pizzas];

-- KPI 4 -- Identify the second highest-priced pizza.   Result: 25.5
SELECT MAX(price) AS Second_Highest_Price FROM [dbo].[pizzas]
WHERE price < (SELECT MAX(price) FROM [dbo].[pizzas]);

-- KPI 5 -- Identify the most common pizza size ordered.   Result: L (18956)
SELECT TOP 1 size,SUM(quantity) AS Total_Quantity FROM [dbo].[pizzas] AS a
JOIN [dbo].[order_details] AS b
ON a.pizza_id=b.pizza_id
GROUP BY size
ORDER BY Total_Quantity DESC;

-- KPI 6 -- List the top 5 most ordered pizza types along with their quantities.
SELECT TOP 5 name,SUM(quantity) AS Total_Quantity FROM [dbo].[pizzas] AS a
JOIN [dbo].[order_details] AS b
ON a.pizza_id=b.pizza_id
JOIN [dbo].[pizza_types] AS c
ON a.pizza_type_id=c.pizza_type_id
GROUP BY name
ORDER BY Total_Quantity DESC;

-- KPI 7 -- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT category,SUM(quantity) AS Total_Quantity FROM [dbo].[order_details] AS a
JOIN [dbo].[pizzas] AS b
ON a.pizza_id=b.pizza_id
JOIN [dbo].[pizza_types] AS c
ON b.pizza_type_id=c.pizza_type_id
GROUP BY category
ORDER BY Total_Quantity DESC;

-- KPI 8 -- Determine the distribution of orders by hour of the day.
-- Result: hours 12, 13, 17 and 18 hold 9710 of 21350 orders (45.5%)
SELECT DATEPART(HOUR,time) AS Hour,COUNT(order_id) AS Orders FROM [dbo].[orders]
GROUP BY DATEPART(HOUR,time)
ORDER BY Orders DESC;

-- KPI 9 -- Category-wise distribution of pizzas sold (quantity and share of all pizzas sold).
SELECT category,
       SUM(quantity) AS Total_Quantity,
       ROUND(100.0 * SUM(quantity) / SUM(SUM(quantity)) OVER (), 2) AS Pct_Of_Pizzas_Sold
FROM [dbo].[pizza_types] AS a
JOIN [dbo].[pizzas] AS b
ON a.pizza_type_id=b.pizza_type_id
JOIN [dbo].[order_details] AS c
ON b.pizza_id=c.pizza_id
GROUP BY category
ORDER BY Total_Quantity DESC;

-- KPI 10 -- Determine how many pizzas (size variants) there are in each category.
SELECT category,COUNT(pizza_id) AS Total_pizzas FROM [dbo].[pizza_types] AS a
JOIN [dbo].[pizzas] AS b
ON a.pizza_type_id=b.pizza_type_id
GROUP BY category
ORDER BY Total_pizzas DESC;

-- KPI 11 -- Group the orders by date and calculate the average number of pizzas ordered per day.
-- CAST to DECIMAL: AVG over an integer column truncates (138); the real average is 138.47.
SELECT ROUND(AVG(CAST(Total_Quantity AS DECIMAL(10,2))),2) AS Avg_Pizza_Per_Day FROM
(
SELECT SUM(quantity) AS Total_Quantity FROM [dbo].[order_details]
JOIN [dbo].[orders]
ON [dbo].[order_details].order_id=[dbo].[orders].order_id
GROUP BY date) AS t;

-- KPI 12 -- Determine the top 3 pizza types based on revenue.
SELECT TOP 3 name,SUM(quantity * price) AS Total_Revenue FROM [dbo].[order_details] AS a
JOIN [dbo].[pizzas] AS b
ON a.pizza_id=b.pizza_id
JOIN [dbo].[pizza_types] AS c
ON c.pizza_type_id=b.pizza_type_id
GROUP BY name
ORDER BY Total_Revenue DESC;

-- KPI 13 -- Calculate the percentage contribution of each pizza category to total revenue.
SELECT category,ROUND(SUM(quantity * price)/
(SELECT ROUND(SUM(quantity * price),2) FROM [dbo].[order_details] AS a
JOIN [dbo].[pizzas] AS b
ON a.pizza_id=b.pizza_id )* 100 ,2) AS Percentage
FROM [dbo].[order_details] AS a
JOIN [dbo].[pizzas] AS b
ON a.pizza_id=b.pizza_id
JOIN [dbo].[pizza_types] AS c
ON c.pizza_type_id=b.pizza_type_id
GROUP BY category
ORDER BY percentage DESC;

-- KPI 14 -- Analyze the cumulative revenue generated over a period of time.
SELECT date,SUM(Revenue) OVER (ORDER BY date) AS Cum_Revenue FROM
(SELECT date,ROUND(SUM(quantity * price),2) AS Revenue FROM [dbo].[order_details] AS a
JOIN [dbo].[pizzas] AS b
ON a.pizza_id=b.pizza_id
JOIN [dbo].[orders] AS c
ON a.order_id=c.order_id
GROUP BY date) AS t;

-- KPI 15 -- Determine the top 3 pizza types by revenue within each pizza category.
SELECT name,category,Revenue FROM
(SELECT name,category,Revenue,RANK() OVER(PARTITION BY category ORDER BY Revenue DESC) AS rank FROM
(SELECT name,category,ROUND(SUM(quantity * price),2) AS Revenue FROM [dbo].[order_details] AS a
JOIN [dbo].[pizzas] AS b
ON a.pizza_id=b.pizza_id
JOIN [dbo].[pizza_types] AS c
ON c.pizza_type_id=b.pizza_type_id
GROUP BY category,name) AS t) AS d
WHERE rank<=3;

/* ---------- Supporting queries (back the weekday and month findings in the README) ---------- */

-- Support A -- Orders by day of the week.   Result: Friday highest (3538), Sunday lowest (2624)
SELECT DATENAME(WEEKDAY, [date]) AS Day_Name, COUNT(DISTINCT order_id) AS Orders
FROM [dbo].[orders]
GROUP BY DATENAME(WEEKDAY, [date])
ORDER BY Orders DESC;

-- Support B -- Revenue by month.   Result: July highest (72557.90), October lowest (64027.60)
SELECT MONTH(c.[date]) AS Month_No,
       DATENAME(MONTH, c.[date]) AS Month_Name,
       ROUND(SUM(a.quantity * b.price),2) AS Revenue
FROM [dbo].[order_details] AS a
JOIN [dbo].[pizzas] AS b ON a.pizza_id=b.pizza_id
JOIN [dbo].[orders] AS c ON a.order_id=c.order_id
GROUP BY MONTH(c.[date]), DATENAME(MONTH, c.[date])
ORDER BY Revenue DESC;
