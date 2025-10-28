-- RANK FUNCTIONS
-- They don't have any expression except in the NTILE(n) 
-- ORDER BY clause is required, PARTITION BY is optional, FRAME clauses are not allowed

-- Rank the sales from + to - : ROW_NUMBER(), RANK(), DENSE_RANK(), NTILE(n)
SELECT
	orderid,
	sales,
	ROW_NUMBER() OVER(ORDER BY sales DESC)
	-- It leaves no gaps even with the same data and doesn't handle the ties. Eg. 20,20,10 Rank : 1,2,3
FROM sales.orders;

SELECT
	orderid,
	sales,
	RANK() OVER(ORDER BY sales DESC)
	-- It leaves gaps with the same data. Eg. 20,20,10 Rank : 1,1,3
FROM sales.orders;

SELECT
	orderid,
	sales,
	DENSE_RANK() OVER(ORDER BY sales DESC)
	-- It leaves no gaps even with the same data and also it handles the ties. Eg. 20,20,10,5 Rank : 1,1,2,3
FROM sales.orders;

SELECT
	orderid,
	sales,
	NTILE(2) OVER(ORDER BY sales DESC)
	-- NTILE(n) function divids the total_rows/no. of bukets 
	-- It than assign values with the same number inside a bucket, if the bukcet is full than another bucket
	-- starts getting fillied. If there is ODD number after dividing than the larger group comes first.
FROM sales.orders;


-- Find the top highest sales for each product
SELECT *
FROM (SELECT
	orderid,
	sales,
	ROW_NUMBER() OVER(PARTITION BY productid ORDER BY sales DESC) AS rank_products
FROM sales.orders)t
WHERE rank_products = 1
ORDER BY orderid;


-- Find the lowest 2 customers baswd on their total sales.
SELECT
*
FROM
(SELECT
 COALESCE(customerid,0) AS customerid,
 SUM(sales),
 ROW_NUMBER() OVER(ORDER BY SUM(sales)) rank_customers
FROM sales.orders
GROUP BY customerid
ORDER BY SUM(sales) ASC)t
WHERE rank_customers <= 2;



-- Assign unique IDs to the rows of the table OrdersArchive

SELECT
	ROW_NUMBER() OVER(ORDER BY orderid) AS unique_id,
	orderid,
	customerid,
	sales
FROM sales.ordersarchive;


-- Remove duplicates in ordersarchive table
SELECT
*
FROM
(SELECT
	ROW_NUMBER() OVER(PARTITION BY orderid ORDER BY creationtime DESC) AS ranked,
	orderid,
	customerid,
	sales,
	creationtime
FROM sales.ordersarchive)t
WHERE ranked = 1;


-- Segment all orders into 3 categories : hugh, medium and low

SELECT
	*,
	CASE buckets
	 	WHEN 1 THEN 'High'
		WHEN 2 THEN 'Medium' 
		WHEN 3 THEN 'Low' 
	END AS category
FROM
(SELECT
	orderid,
	sales,
	NTILE(3) OVER(ORDER BY sales DESC) AS buckets
FROM sales.orders)t
