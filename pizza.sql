USE pizza_sales;

SELECT * FROM [dbo].[order_details];

SELECT * FROM [dbo].[orders];

SELECT * FROM [dbo].[pizza_types];

SELECT * FROM [dbo].[pizzas];

-- KPI 1 --  Retrieve the total number of orders placed.
SELECT SUM(quantity) AS Total_Orders FROM [dbo].[order_details]; 

-- KPI 2 -- Calculate the total revenue generated from pizza sales.
SELECT ROUND(SUM(quantity * price),2) AS Total_Revenue FROM [dbo].[order_details] AS a
JOIN [dbo].[pizzas] AS b
ON a.pizza_id=b.pizza_id; 

-- KPI 3 -- Identify the highest-priced pizza
SELECT MAX(price) AS Highest_Price_Pizza  from [dbo].[pizzas];

-- KPI 4 -- Identify the highest-priced pizza
SELECT MAX(price) AS Highest_Price_Pizza  FROM [dbo].[pizzas]
WHERE price < (SELECT MAX(price) AS Highest_Price_Pizza  FROM [dbo].[pizzas]);

-- KPI 5 -- Identify the most common pizza size ordered.
SELECT TOP 1 size,SUM(quantity) AS Total_Quantity FROM [dbo].[pizzas] AS a
JOIN [dbo].[order_details] AS b
ON a.pizza_id=b.pizza_id
GROUP BY size
ORDER BY Total_Quantity DESC;

 -- KPI 6 -- List the top 5 most ordered pizza types 
 -- along with their quantities.
 SELECT TOP 5 name,SUM(quantity) AS Total_Quantity FROM [dbo].[pizzas] AS a
 JOIN [dbo].[order_details] AS b
 ON a.pizza_id=b.pizza_id
 JOIN [dbo].[pizza_types] AS c
 ON a.pizza_type_id=c.pizza_type_id
 GROUP BY name
 ORDER BY Total_Quantity DESC;

 -- KPI 7 -- Join the necessary tables to find the 
-- total quantity of each pizza category ordered.
SELECT category,SUM(quantity) AS Total_Quantity FROM [dbo].[order_details] AS a
JOIN [dbo].[pizzas] AS b
ON a.pizza_id=b.pizza_id
JOIN [dbo].[pizza_types] AS c
ON b.pizza_type_id=c.pizza_type_id
GROUP BY category
ORDER BY Total_Quantity DESC;
 
-- KPI 8 -- Determine the distribution of orders by hour of the day
SELECT DATEPART(HOUR,time) AS Hour,count(order_id) AS Orders FROM [dbo].[orders]
GROUP BY DATEPART(HOUR,time)
ORDER BY Orders DESC

-- KPI 9 -- Join relevant tables to find the 
-- category-wise distribution of pizzas
SELECT category,SUM(quantity) AS Total_Quantity FROM [dbo].[pizza_types] AS a
JOIN [dbo].[pizzas] AS b
ON a.pizza_type_id=b.pizza_type_id
JOIN [dbo].[order_details] AS c
ON b.pizza_id=c.pizza_id
GROUP BY category
ORDER BY Total_Quantity DESC


-- KPI 10 -- Determine how many pizzas in each category
SELECT category,COUNT(pizza_id) AS Total_pizzas FROM [dbo].[pizza_types] AS a
join [dbo].[pizzas] AS b
ON a.pizza_type_id=b.pizza_type_id
GROUP BY category
ORDER BY Total_pizzas DESC

-- KPI 11 -- Group the orders by date and
--  calculate the average number of pizzas ordered per day.
SELECT AVG(Total_Quantity) AS Avg_Pizza_Per_Day FROM
(
SELECT SUM(quantity) AS Total_Quantity FROM [dbo].[order_details] 
join [dbo].[orders]
ON [dbo].[order_details].order_id=[dbo].[orders].order_id
GROUP by date) AS t

-- KPI 12 -- Determine the top 3 most ordered pizza types based on revenue.
SELECT TOP 3 name,SUM(quantity * price) AS Total_Revenue FROM [dbo].[order_details] AS a
JOIN [dbo].[pizzas] AS b
ON a.pizza_id=b.pizza_id
JOIN [dbo].[pizza_types] AS c
ON c.pizza_type_id=b.pizza_type_id
GROUP BY name
ORDER BY Total_Revenue DESC;

--  KPI 13 -- Calculate the percentage contribution of each pizza type to total revenue.
SELECT category,ROUND(SUM(quantity * price)/
(SELECT ROUND(SUM(quantity * price),2) FROM [dbo].[order_details] AS a
JOIN [dbo].[pizzas] AS b
ON a.pizza_id=b.pizza_id )* 100 ,2) AS Percentage
from [dbo].[order_details] AS a
JOIN [dbo].[pizzas] AS b
ON a.pizza_id=b.pizza_id
join [dbo].[pizza_types] as c
on c.pizza_type_id=b.pizza_type_id
group by category
ORDER BY percentage desc

-- KPI 14 -- Analyze the cumulative revenue generated over a period of time
SELECT date,sum(Revenue) over (order by date) as Cum_Revenue from
(SELECT date,ROUND(SUM(quantity * price),2) AS Revenue FROM [dbo].[order_details] AS a
JOIN [dbo].[pizzas] AS b
ON a.pizza_id=b.pizza_id
join orders as c
on a.order_id=c.order_id
group by date) as t

-- KPI 15 -- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT name,category,Revenue from
(SELECT name,category,Revenue,rank() over(partition by category order by Revenue desc) AS rank from 
(SELECT name,category,round(SUM(quantity * price),2) AS Revenue FROM [dbo].[order_details] AS a
JOIN [dbo].[pizzas] AS b
ON a.pizza_id=b.pizza_id
JOIN [dbo].[pizza_types] AS c
ON c.pizza_type_id=b.pizza_type_id
group by category,name)As t) AS d
where rank<=3



