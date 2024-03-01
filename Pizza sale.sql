USE PizzaDB;
SELECT * FROM pizza_sales;

-- Total Revenue

SELECT SUM(total_price) AS Total_Revenue FROM pizza_sales;

-- Average order value

SELECT SUM(total_price)/COUNT(DISTINCT order_id) AS AVG_Order_Value FROM pizza_sales;

-- Total Pizza Sold

SELECT SUM(quantity) AS Total_Pizza_Sold FROM pizza_sales;

-- Total Orders

SELECT COUNT(DISTINCT order_id) AS Total_Pizza_Order FROM pizza_sales;

-- Average Pizzas Per Order

SELECT CAST(CAST(SUM(quantity) AS DECIMAL(10,2))/
CAST(COUNT(DISTINCT order_id) AS DECIMAL(10,2)) AS DECIMAL(10,2)) AS Avg_Pizza_Per_Order FROM pizza_sales;


SELECT * FROM pizza_sales;

-- Daily Trend For Total Orders

SELECT DATENAME(DW, order_date) AS order_day, COUNT(DISTINCT order_id) as Total_Order 
FROM pizza_sales GROUP BY DATENAME(DW, order_date);

-- Monthly Trend For Total Orders

SELECT DATENAME(MONTH, order_date) AS Month_Name, COUNT(DISTINCT order_id) AS Total_Orders
FROM pizza_sales GROUP BY DATENAME(MONTH, order_date)
ORDER BY Total_Orders DESC;

-- Percentage Of Sales By Pizza Category:

SELECT pizza_category,SUM(total_price) AS Total_sale,SUM(total_price) * 100 / 
(SELECT SUM(total_price) FROM pizza_sales WHERE MONTH(order_date) = 1) AS Percentage_of_TS
FROM pizza_sales
WHERE MONTH(order_date) = 1
GROUP BY pizza_category;

-- Percentage Of Sales By Pizza Size:

SELECT pizza_size, CAST(SUM(total_price) AS DECIMAL(10,2)) AS Total_sale, CAST(SUM(total_price)*100/
(SELECT SUM(total_price) FROM pizza_sales WHERE DATEPART(quarter, order_date) = 1) AS DECIMAL(10,2)) AS Percentage_of_TS
FROM pizza_sales
WHERE DATEPART(quarter, order_date) = 1
GROUP BY pizza_size
ORDER BY Percentage_of_TS DESC;

-- Top 5 Pizzas By Revenue

SELECT TOP 5 pizza_name, SUM(total_price) AS Total_Revenue FROM pizza_sales
GROUP BY pizza_name 
ORDER BY Total_Revenue DESC;

-- Bottom 5 Pizzas By Revenue

SELECT TOP 5 pizza_name, SUM(total_price) AS Total_Revenue FROM pizza_sales
GROUP BY pizza_name 
ORDER BY Total_Revenue ASC;

-- Top 5 Pizzas By Quantity

SELECT TOP 5 pizza_name, SUM(quantity) AS Total_Quantity FROM pizza_sales
GROUP BY pizza_name
ORDER by Total_Quantity DESC;

-- Bottom 5 Pizzas By Quantity

SELECT TOP 5 pizza_name, SUM(quantity) AS Total_Quantity FROM pizza_sales
GROUP BY pizza_name
ORDER by Total_Quantity ASC;
