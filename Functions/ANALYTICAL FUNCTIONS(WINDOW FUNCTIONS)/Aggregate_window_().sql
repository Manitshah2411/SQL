-- Aggregate window function


-- COUNT() : return number of rows in the window
SELECT
	customerid,
	productid,
	COUNT(productid) OVER(PARTITION BY productid)
FROM sales.orders;

SELECT
	orderid,
	customerid,
	productid,
	COUNT(1) OVER(),
	COUNT(*) OVER(PARTITION BY customerid)
FROM sales.orders;

-- Checking NULLS using COUNT()

SELECT
	customerid,
	COUNT(*) AS total_customers,
	COUNT(customerid) OVER() AS total_customers_cleaned 
	-- The count() will count customerid only when they are not null, so total_rows - total_customers_cleaned gives actual customers
FROM sales.orders;


-- Identifying duplicates
SELECT
	*
FROM(

SELECT
	orderid,
	COUNT(orderid) OVER(PARTITION BY orderid) AS clean_orderid
FROM sales.ordersarchive
)t -- temp name 
WHERE clean_orderid > 1



-- SUM() : return sum of values in each windows

SELECT
	orderid,
	orderdate,
	productid,
	SUM(sales) OVER() AS total_sales,
	SUM(sales) OVER(PARTITION BY productid) AS total_sales_products,
	ROUND((SUM(sales) OVER(PARTITION BY productid))::numeric / (SUM(sales) OVER()::numeric) * 100,2) AS contribution,
FROM sales.orders;

SELECT
	orderid,
	orderdate,
	productid,
	SUM(sales) OVER(ORDER BY orderdate) -- If the ORDER BY clause is specified than only the default frame clause is set
FROM sales.orders;


-- AVG() : average of each window

-- Find avg sales and also avg sales by each products 
SELECT 
	orderid,
	orderdate,
	sales,
	productid,
	ROUND(AVG(COALESCE(sales,0)) OVER()) AS avg_sales,
	ROUND(AVG(COALESCE(sales,0)) OVER(PARTITION BY productid)) AS avg_sales_products
FROM sales.orders;


-- Find where the order sale is greater than the average sales while keeping all the details
SELECT 
	*
FROM ( SELECT
	orderid,
	orderdate,
	sales,
	productid,
	ROUND(AVG(COALESCE(sales,0)) OVER()) AS avg_sales
FROM sales.orders
)t
WHERE sales > avg_sales;

-- Calculate the moving avg of sales for each product over time.
SELECT
	orderid,
	productid,
	orderdate,
	sales,
	ROUND(AVG(sales) OVER(PARTITION BY productid ORDER BY orderdate 
						  ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING )) AS moving_avg
FROM sales.orders

-- MIN() and MAX()

-- Find the highest and the lowest sales for each product

SELECT 
	productid,
	MIN(sales) OVER(PARTITION BY productid) AS min_sales,
	MAX(sales) OVER(PARTITION BY productid) AS max_sales
FROM sales.orders


-- Show employees who have the highest salaries
SELECT
*
FROM (SELECT 
	*,
	MAX(salary) OVER() AS highestsalary
FROM sales.employees)t
WHERE salary = highestsalary

-- Find deviation of sales from MIN and MAX

SELECT 
	productid,
	sales - MIN(sales) OVER() AS dev_from_min,
	MAX(sales) OVER() - sales AS dev_from_max
FROM sales.orders




