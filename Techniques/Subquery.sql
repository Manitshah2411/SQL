-- SUBQUERY : NON-CORELATED --

-- RESULT TYPE SUBQUERY : SCALAR(returns a single value), ROW(returns a single column but multiple rows),
-- 						  TABLE(multiple rows and multiple columns)


-- 1. SCALAR --

SELECT 
	SUM(sales) AS total_sales -- this returns a single value so it is scalar query
FROM sales.orders;

-- 2. ROW --

SELECT 
	orderid
FROM sales.orders;

-- 3. TABLE --

SELECT 
	orderid,
	customerid
FROM sales.orders;



-----------------------------------
-- USING SUBQUERY IN FROM CLAUSE --
-----------------------------------

-- Find products that have a price higher price than the avg price of all products
SELECT
	*
FROM(SELECT 
	product,
	price,
	ROUND(AVG(price) OVER(),2) as avg_price
FROM sales.products)t
WHERE price > avg_price;



-- Rank customers based on the total amount of sales


SELECT
*,
RANK() OVER(ORDER BY total_sales DESC)
FROM (SELECT 
	c.customerid,
	SUM(o.sales) AS total_sales
FROM sales.customers AS c

INNER JOIN sales.orders AS o
ON o.customerid = c.customerid

GROUP BY c.customerid)t;



-------------------------------------
-- USING SUBQUERY IN SELECT CLAUSE --
-------------------------------------

SELECT 
	p.productid,
	p.product,
	p.price,
	(SELECT COUNT(*) FROM sales.orders) AS total_orders -- if you want to use a subquery inside a select clause
	-- only a scalar subquery is allowed(which returns a single value), that value output is like a static row data
FROM sales.products AS p;

-----------------------------------
-- USING SUBQUERY IN JOIN CLAUSE --
-----------------------------------

SELECT 
c.*,
tt.total_orders
FROM sales.customers AS c
LEFT JOIN
(SELECT 
	customerid,
	COUNT(*) total_orders
FROM sales.orders AS o
GROUP BY customerid) tt
ON tt.customerid = c.customerid

-- Antother way without subquery
SELECT 
	c.customerid,
	CONCAT(c.firstname,' ',c.lastname) AS fullname,
	c.country,
	c.score,
	COUNT(o.orderid)
FROM sales.customers AS c

INNER JOIN sales.orders AS o
ON o.customerid = c.customerid

GROUP BY c.customerid,
	fullname,
	c.country,
	c.score



------------------------------------
-- USING SUBQUERY IN WHERE CLAUSE --
------------------------------------

-- Find products that have a price higher price than the avg price of all products

SELECT 
*
FROM sales.products
WHERE price > (SELECT AVG(price) AS avg_price FROM sales.products) -- while using the comparison operator it should be 
																   -- only value



SELECT
	*
FROM sales.orders
WHERE customerid NOT IN(SELECT 
	customerid
FROM sales.customers
WHERE country = 'Germany') -- using logical operators rows can be multiple but columns should not be more than one


 
-- ANY & ALL operator used with comparison

SELECT 
	*
FROM sales.employees
WHERE gender = 'F' AND salary > ALL (SELECT  -- The ANY operator looks into the list and find that ATLEAST one thing fulfill
									salary	 -- the conditions
								FROM sales.employees	-- The ALL operator looks into the list and find that all the things
								WHERE gender = 'M' ) -- fullfills the condition



-- SUBQUERY : CORELATED --

-- Show all the customer details and find the total orders of each customers

SELECT 
	*,
	(SELECT COUNT(*) FROM sales.orders o WHERE o.customerid = c.customerid)
	-- When writing o.customerid = c.customerid the SQL knows it is corelated query and than 
	-- after each row of the outer query the sub query is executed, that mean n rows = n execution of subquery
	--
FROM sales.customers AS c


-- EXISTS keyword --

SELECT 
	*
FROM sales.orders AS o
WHERE EXISTS (SELECT  -- The EXISTS just check is the WHERE clause in corelated subquery is TRUE or FALSE if true only than
	c.customerid,	  -- it'll be shown in the result
	c.firstname
FROM sales.customers AS c
WHERE country IN ('Germany') AND c.customerid = o.customerid)










 