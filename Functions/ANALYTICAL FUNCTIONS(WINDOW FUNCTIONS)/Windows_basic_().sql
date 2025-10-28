select * from sales.customers;
select * from sales.orders;
select * from sales.employees;
select * from sales.ordersarchive;
select * from sales.products;


-- WINDOW FUNCTIONS are only allowed in SELECT and ORDER BY clause.
-- Nesting of WINDOW Functions is not allowed
-- You can use Window functions with the group by clause only when you use the same columns


-- OVER() and PARTITION BY 
-- OVER() : it is used to specify that it is a window function and also it can help define the window or subset you want
--			just like GROUP BY.
-- The empty OVER() clause : this empty clause tells the SQL that treat all the row as single window and do all the calculation
-- on all the rows
-- The OVER(PARTITION BY Category) : This clause tells the SQL that treat all the  row as categorised windows as defined.
								--	 eg. Product1 = window1, Product2 = window2.
SELECT 
	productid,
	orderid,
	orderdate,
	SUM(sales) OVER(PARTITION BY productid) AS total_sales -- The over funtion tells the sql that this is the window function and than give all the row
									 -- in details as we ask for.
								-- The PARTITION BY is just like GROUP BY keyword which uses aggregate function for the give the 
								-- data with all the details which we were not able to fetch with GROUP BY.
FROM sales.orders;



SELECT
	orderid,
	orderdate,
	sales,
	customerid,
	SUM(sales) OVER() AS total_sales,
	SUM(sales) OVER(PARTITION BY customerid ORDER BY sales DESC ) AS total_sales_customers,
	SUM(sales) OVER(PARTITION BY productid, orderstatus) AS total_sales_products_orderstatus
	-- You can use multiple category in PARITION BY clause. It'll work as combining the 2 category and use the
	-- aggregate function. Like Product1, shipped and Product1, shipped only these 2 will be stacked together, if
	-- Product1, delivered this product1 will be treated separately and stacked differently.
FROM sales.orders;




-- FRAME clause
-- Frame clause is used to set the Frame of subset in the window.

-- The frame is defined using either:
-- ROWS → count rows physically
-- RANGE → based on the ordering value
-- GROUPS → (Postgres ≥ 11) group equal values together

-- You define a frame with boundaries like:
-- UNBOUNDED PRECEDING → start from the first row in the partition
-- N PRECEDING → start N rows before current row
-- CURRENT ROW → include the current row
-- N FOLLOWING → include N rows after current row
-- UNBOUNDED FOLLOWING → go until the last row in the partition


---- USING ROWS ----
SELECT 
	orderid,
	productid,
	customerid,
	orderstatus,
	sales,
	-- The lower Boundry should always be defined before the higher boundry
	-- You can only use the fram clause after the order by clause
	SUM(sales) OVER(PARTITION BY customerid ORDER BY sales ASC 
					ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING ) AS totalsales1,
					-- Here the Window is PARTITTON BY customerid Mean each customerid sales is SUMMED up
					-- and after that using the frame clause we defined a subset.
					-- CURRENT ROW which is the ongoing rows and 2 following
					-- The 2 following will only go up till the parition by clause it cannot exceed it.
					-- customer1, sales : 10,20,30  CR : 10, 1F : 20, 2F : 30 
					-- So, here in the 1st row it'll be 60 and after that it won't exceed the limit so it'll just be 50.

	SUM(sales) OVER(PARTITION BY productid ORDER BY sales 
					ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS totalsales2
					-- UNBOUNDED PRECEDING/FOLLOWING : always from/till the start/end
	
	
FROM sales.orders;

SELECT 
	orderid,
	productid,
	customerid,
	orderstatus,
	sales,
	SUM(sales) OVER(PARTITION BY productid ORDER BY sales 
					ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS totalsales2
					-- UNBOUNDED PRECEDING/FOLLOWING : always from/till the start/end
FROM sales.orders;


SELECT 
	orderid,
	productid,
	customerid,
	orderstatus,
	sales,
	SUM(sales) OVER(PARTITION BY productid ORDER BY sales 
					) AS totalsales2 
					-- If now Frame clause written the default is 
					-- RANGE BETWEEN UNBOUNDES PRECEDING AND CURRENT ROW
					-- UNBOUNDED PRECEDING/FOLLOWING : always from/till the start/end
FROM sales.orders;


SELECT 
	orderid,
	productid,
	customerid,
	orderstatus,
	sales,
	SUM(sales) OVER(PARTITION BY productid ORDER BY sales 
					ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING) AS totalsales2
					-- -1,-1,CR,+1,+1 (Should fall inside the window if not that till the last value in the window)	
					
FROM sales.orders;


-- RANGE

SELECT 
	orderid,
	orderdate,
	productid,
	customerid,
	orderstatus,
	sales,
	SUM(sales) OVER(ORDER BY orderdate
					RANGE BETWEEN INTERVAL '7 days' PRECEDING AND CURRENT ROW) AS totalsales2
					-- RANGE can be used with time intervals too and also with numeric values
					-- If the there same data in that window the Frame clause includes that automatically while using RANGE
FROM sales.orders;


-- GROUPS
SELECT 
	orderid,
	orderdate,
	productid,
	customerid,
	orderstatus,
	sales,
	SUM(sales) OVER(PARTITION BY productid ORDER BY sales
					GROUPS BETWEEN 1 PRECEDING AND CURRENT ROW) AS totalsales2
					-- Groups create a group of peers of same value like 20,20,20 = 1 group 
					-- 30,30 = 2 group
FROM sales.orders;


-- Q: Find the total sales for each order status, only for two products 101 and 102

SELECT
	productid,
	sales,
	SUM(sales) OVER(PARTITION BY productid ORDER BY sales ASC)
FROM sales.orders
WHERE productid IN (101,102);

-- Q: Rank customers based on their total sales
SELECT
	COALESCE(customerid,0),
	SUM(sales) AS total_sales,
	RANK() OVER(ORDER BY SUM(sales) DESC)
FROM sales.orders
GROUP BY customerid






