
----------
-- CTAS --
----------

DROP TABLE IF EXISTS sales.customer_details;
CREATE TABLE sales.customer_details AS -- Create a physical table for analysis unline VIEW which is virtual
(SELECT 							   -- This CTAS is used when you want performance and the data is too large
									   -- But it won’t auto-update if underlying data changes (unlike a view)
	CONCAT(c.firstname,' ',c.lastname) AS CustomerName,
	c.country,
	SUM(o.sales) AS total_sales
FROM sales.customers AS c
INNER JOIN sales.orders AS o
ON c.customerid = o.customerid
GROUP BY CONCAT(c.firstname,' ',c.lastname),
	c.country);

SELECT * FROM sales.customer_details
-- DROP TABLE customer_details

-----------------
-- TEMP TABLES --
-----------------

CREATE TEMP TABLE sales.temp_orders AS -- This tables are session bound means after disconnecting from the server they are dropped
(
SELECT
	*
FROM sales.customers
)

-- This query is used to see what and how many temp tables are there currently
SELECT tablename 
FROM pg_tables 
WHERE tablename LIKE 'temp_orders';


DROP  TABLE temp_orders
