SELECT * FROM sales.orders;
SELECT * FROM sales.customers;


-----------------------------
--|	SINGLE ROW FUNCTIONS  |--
-----------------------------     

----NULL FUNCTIONS----

-- 1. COALESCE

SELECT
	billaddress,
	shipaddress,
	COALESCE(billaddress::VARCHAR,shipaddress::VARCHAR, 'Manit') AS replacement
	-- COALESCE is used to replace null values. it accepts multiple values. 
	-- The 1st argument passed is the value if there is any null than that row will be
	-- replaced by the 2nd argument and if the 2nd argument value is also null than 
	-- it'll replaced by the 3rd and so on.
FROM sales.orders;


SELECT 
	country,
	ROUND(AVG(COALESCE(score,0)),2) AS avg_score
FROM sales.customers
GROUP BY country
ORDER BY avg_score DESC



SELECT
	CONCAT(firstname,' ', lastname) AS fullname,
	(COALESCE(score,0)) + 10  
FROM sales.customers
ORDER BY customerid;

---
SELECT 
	o.orderid,
	o.customerid,
	o.sales,
	CONCAT(c.firstname,' ',c.lastname) AS customerfullname,
	c.score
FROM sales.orders AS o
INNER JOIN sales.customers AS c
ON COALESCE(c.customerid,'0') = COALESCE(o.customerid,'0')
ORDER BY o.orderid

---
SELECT
	customerid,
	score
FROM sales.customers
ORDER BY COALESCE(score,99999)

---
SELECT
	customerid,
	score
FROM sales.customers
ORDER BY CASE WHEN score IS NULL THEN 1 ELSE 0 END, score;



-- 2. NULLIF
-- Is used to return NULL if the 2 expressions are same NULLIF(exp1,exp2), if both the expressions are same
-- than the NULLIF() function will return a NULL


SELECT 
	orderid,
	sales,
	quantity,
	sales / NULLIF(quantity,0) AS price -- if the quantity is zero than it'll be replaced by NULL and will cause no 
										-- no ZERO DIVISION errors.
FROM sales.orders;



-- 3. IS NULL & IS NOT NULL

SELECT
	firstname,
	score
FROM sales.customers
WHERE score IS NULL; -- Here IS NULL is used to check whether the score IS NULL if yess only than the score will be shown 
					-- in the result

---
SELECT
	firstname,z
	score
FROM sales.customers
WHERE score IS NOT NULL; -- Here it is totally opposite of IS NULL



SELECT 
	c.customerid,
	CONCAT(firstname,' ',lastname) AS customerfullname,
	o.orderid,
	o.sales
FROM sales.customers AS c
LEFT JOIN sales.orders AS o
ON c.customerid = o.customerid
WHERE o.customerid IS NULL 


SELECT
	c.customerid,
	o.orderid,
	c.firstname
FROM sales.customers AS c
RIGHT JOIN sales.orders AS o
ON c.customerid = o.customerid
where o.customerid IS NULL;


WITH all_orders AS(
	SELECT orderid, customerid, quantity, sales FROM sales.orders
	UNION ALL
	SELECT orderid, customerid, quantity, sales FROM sales.ordersarchive
)
INSERT INTO high_value_customers (customerid, customerfullname,country,total_orders,total_spent)
SELECT 
	c.customerid,
	CONCAT_WS(' ',c.firstname,c.lastname) AS customerfullname,
	c.country,
	COUNT(ao.orderid) AS total_orders, -- The count function only count rows which are not NULL so, it's always better
									   -- to give the parameter a PRIMARY KEY or NOT NULL values to it.
	SUM(ao.sales) AS total_spent
FROM sales.customers as c
INNER JOIN all_orders AS ao ON c.customerid = ao.customerid -- Filters out all the customers which doesn't have any order
															-- and also orders which doesn't have any customer's detailes
GROUP BY c.customerid, customerfullname, c.country
HAVING COUNT(ao.orderid) > 1 AND SUM(ao.sales) > 50
ORDER BY total_spent DESC;

CREATE TABLE IF NOT EXISTS high_value_customers(
	customerid INT PRIMARY KEY NOT NULL,
	customerfullname VARCHAR(50) NOT NULL,
	country VARCHAR(30),
	total_orders INT,
	total_spent INT
);

SELECT * FROM high_value_customers;
DROP table high_value_customers