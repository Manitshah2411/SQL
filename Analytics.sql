SELECT * FROM sales.orders;
SELECT * FROM sales.ordersarchive;
SELECT * FROM sales.customers;
SELECT * FROM sales.products;
SELECT * FROM sales.employees;



-- CHALLENGE 1

-- (2)
INSERT INTO loyalty_customers
SELECT
	c.customerid,
	CONCAT(c.firstname,', ',lastname) AS Fullname,
	COUNT(DISTINCT o.productid) AS unique_products,
	SUM(o.sales) AS total_sales,
	(MAX(o.orderdate) - MIN(o.orderdate)) AS days_between_orders,
	CASE
		WHEN SUM(o.sales) > 50 THEN 'Gold'
		WHEN SUM(o.sales) BETWEEN 20 AND 50 THEN 'Silver'
		ELSE 'Bronze'
	END AS Customer_Tier

-- (1)
FROM sales.customers AS c
INNER JOIN sales.orders AS o
ON c.customerid = o.customerid
WHERE EXTRACT(YEAR FROM o.orderdate) = 2025
GROUP BY c.customerid
HAVING COUNT(DISTINCT o.productid) > 1

-- (3)
ORDER BY total_sales DESC;


CREATE TABLE IF NOT EXISTS loyalty_customers(
	customerid INT PRIMARY KEY NOT NULL,
	fullname VARCHAR,
	unique_products INT NOT NULL,
	total_sales INT NOT NULl,
	days_between_orders INT,
	customer_tier VARCHAR NOT NULL
);

SELECT * FROM loyalty_customers;

SELECT * FROM sales.customers -- To delete the customers who are inactive just write DELETE FROM sales.customers
WHERE customerid NOT IN(SELECT customerid FROM loyalty_customers);

DROP TABLE loyalty_customers;

-- CHALLENGE 2

WITH all_orders AS(
	SELECT * FROM sales.orders 
	UNION ALL
	SELECT * FROM sales.ordersarchive
)

SELECT 
	p.productid,
	p.category,
	p.product,
	SUM(o.sales) AS total_revenue,
	SUM(o.quantity) AS total_quantity,
	ROUND(AVG(p.price) * SUM(o.sales)) AS total_revenue

FROM all_orders AS o
INNER JOIN sales.products AS p
ON o.productid = p.productid
GROUP BY p.product, p.category, p.productid
HAVING ROUND(AVG(p.price) * SUM(o.sales)) > 100



-- CHALLENGE 3




WITH lapsed_customers AS(
	SELECT * FROM sales.ordersarchive
	EXCEPT 
	SELECT * FROM sales.orders)

SELECT 
	c.customerid,
	CONCAT(c.firstname,' ',c.lastname) AS customerfullname,
	c.country,
	SUM(ao.sales) AS total_sales
FROM sales.customers AS c
INNER JOIN	sales.ordersarchive AS ao
ON c.customerid = ao.customerid
WHERE c.customerid IN (SELECT customerid FROM lapsed_customers)
GROUP BY c.customerid, customerfullname, c.country;


SELECT 
	* 
FROM sales.customers
WHERE customerid NOT IN(SELECT customerid FROM sales.ordersarchive);



