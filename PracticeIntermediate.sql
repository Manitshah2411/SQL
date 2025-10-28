SELECT * FROM sales.ordersarchive;
SELECT * FROM sales.orders;
SELECT * FROM sales.customers;
SELECT * FROM sales.products;
SELECT * FROM sales.employees;

--- COMBINE DATASET(JOIN AND SET)

--- JOIN

-- 1. List all orders with customer name and product name.
SELECT 
	o.orderid,
	CONCAT(c.firstname,' ',c.lastname) AS customerfullname,
	p.product,
	p.price,
	o.sales
FROM sales.orders AS o
INNER JOIN sales.customers AS c
ON c.customerid = o.customerid
INNER JOIN sales.products AS p
ON p.productid = o.productid
ORDER BY o.orderid ASC;


-- 2. Show all employees with their managed orders (employees ↔ orders).

SELECT 
	o.salespersonid,
	o.orderid,
	CONCAT(e.firstname,' ',e.lastname) AS employeefullname,
	e.department,
	e.salary
FROM sales.orders AS o
INNER JOIN sales.employees AS e
ON e.employeeid = o.salespersonid;

	
-- 3. Find customers who have not placed any orders (LEFT JOIN).

SELECT 
	c.customerid,
	CONCAT(c.firstname,' ',lastname) AS customerfullname,
	c.country
FROM sales.customers AS c
LEFT JOIN sales.orders AS o
ON c.customerid = o.customerid
WHERE o.customerid IS NULL;



---- SET

-- 4. Combine data from orders and ordersarchive using UNION ALL.
SELECT * FROM sales.orders
UNION ALL
SELECT * FROM sales.ordersarchive
ORDER BY orderid;


-- 5. Retrieve products ordered in 2024 (from ordersarchive) but not in 2025 (EXCEPT).

SELECT * FROM sales.ordersarchive
EXCEPT
SELECT * FROM sales.orders
ORDER BY orderid;

-- 6. Find employees who belong to both Sales and Marketing departments (INTERSECT).

SELECT
	 *
FROM sales.employees
WHERE department IN('Marketing','Sales');


-- 7. Display customer names with their salespersons’ names (customers ↔ orders ↔ employees)

SELECT 
	c.customerid,
	o.orderid,
	o.salespersonid,
	CONCAT(c.firstname,' ',c.lastname) AS customerfullname,
	CONCAT(e.firstname,' ',e.lastname) AS employeefullname,
	e.department
FROM sales.customers AS c
INNER JOIN sales.orders AS o
ON c.customerid = o.customerid
INNER JOIN sales.employees AS e
ON e.employeeid = o.salespersonid;


--- Single Row Functions (Date, Number, String, NULL)

-- 8. Show order date, and also display month name and year from orders.orderdate.
SELECT 
 orderdate,
 TO_CHAR(orderdate,'Mon DD yyyy')
FROM sales.orders;

-- 9. Display employees’ full name in uppercase.
SELECT 
	UPPER(CONCAT(firstname,' ',lastname)) AS captialname
FROM sales.employees;

-- 10. Calculate employee age from birthdate.

SELECT 
    firstname,
    lastname,
    AGE(birthdate) AS age
FROM sales.employees;


-- 11. Round product prices to the nearest 10.

SELECT 
	ROUND(price,-1) -- will round off to the nearest 10s like 24 will be 20 and 25 will be 30
FROM sales.products;

-- 12. Replace all missing lastname in employees with 'Unknown'

SELECT 
	firstname,
	COALESCE(lastname::VARCHAR,'Unknown')
FROM sales.employees;


-- 13. Show customer names with only the first letter capitalized

SELECT 
	INITCAP(firstname),
	INITCAP(lastname)
FROM sales.customers;


-- 14. Find the number of days taken between order date and ship date (shipdate - orderdate).

SELECT 
	shipdate::DATE - orderdate::DATE
FROM sales.orders;


-- 15. Extract only the year from all ordersarchive.orderdate.

SELECT 
	EXTRACT(YEAR FROM orderdate),
	TO_CHAR(orderdate,'YYYY'),
	DATE_PART('year',orderdate)
FROM sales.ordersarchive;


---- Operators

-- 16. List employees with salary greater than 70,000.

SELECT
	* 
FROM sales.employees
WHERE salary >= 70000;

-- 17. Retrieve orders where status is either 'Shipped' or 'Delivered'.

SELECT
	*
FROM sales.orders
WHERE orderstatus IN ('Delivered','Shipped');


-- 18. Find all customers from USA or Germany.

SELECT 
	*
FROM sales.customers
WHERE country IN ('USA','Germany');

-- 19. Get products whose price is between 15 and 25.

SELECT 
	*
FROM sales.products
WHERE price BETWEEN 15 AND 25;


-- 20. Find employees whose department is not NULL

SELECT 
	* 
FROM sales.employees
WHERE department IS NOT NULL;


-- 21. Show orders where shipaddress contains 'Main'

SELECT 
	*
FROM sales.ordersarchive
WHERE shipaddress LIKE '%Main%';

-- 22. DML: Update the salary of employee Mary by 10%

UPDATE sales.employees
SET salary = salary + (salary * 0.1)
WHERE employeeid = 3;


-- 23. DML: Delete all orders with status 'Cancelled'

DELETE FROM sales.orders
WHERE orderstatus = 'Cancelled';


-- 24. DDL: Add a new column discount to the products table

ALTER TABLE sales.products
ADD COLUMN discount NUMERIC(5,2) DEFAULT 0; -- (5,2) allows upto 5 digits and 2 decimal digits



-- 25. Find the top 3 customers with the highest total sales.

SELECT
	c.customerid,
	CONCAT(c.firstname,' ',c.lastname) AS customerfullname,
	SUM(o.sales)
FROM sales.customers AS c
INNER JOIN sales.orders AS o
ON c.customerid = o.customerid
GROUP BY c.customerid, customerfullname
ORDER BY SUM(o.sales) DESC
LIMIT 3;


-- 26. Which product category (products.category) generated the most revenue?

SELECT
	p.category,
	SUM(o.sales) AS total_revenue
FROM sales.products AS p
INNER JOIN sales.orders AS o
ON p.productid = o.productid
GROUP BY p.category
ORDER BY SUM(o.sales) DESC
LIMIT 1;

-- 27. Find the average salary per department in employees

SELECT 
	department,
	ROUND(AVG(salary)) AS avg_salary
FROM sales.employees
GROUP BY department
ORDER BY AVG(salary) DESC;


-- 28. Which customer placed the most orders in 2025?

SELECT 
	c.customerid,
	CONCAT(c.firstname,' ',c.lastname) AS customerfullname,
	COUNT(o.orderid) AS total_orders
FROM sales.customers AS c
INNER JOIN sales.orders AS o
ON c.customerid = o.customerid
WHERE EXTRACT(year FROM orderdate) = 2025
GROUP BY c.customerid, customerfullname
ORDER BY COUNT(o.customerid) DESC
LIMIT 1;


-- 29. Compare total sales of orders (2025) vs ordersarchive (2024)
WITH all_orders AS(
	SELECT * FROM sales.orders
	UNION ALL
	SELECT * FROM sales.ordersarchive
)
SELECT
	EXTRACT(YEAR FROM ao.orderdate) AS "Year",
	SUM(ao.sales) AS total_sales
FROM all_orders AS ao
GROUP BY EXTRACT(YEAR FROM ao.orderdate)
ORDER BY SUM(ao.sales) DESC;


-- 30.Find the youngest and oldest employee.

(SELECT 
	'YOUNGEST' ,
	AGE(NOW(),birthdate) AS age
FROM sales.employees
ORDER BY birthdate DESC
LIMIT 1
)
UNION ALL
(
SELECT 
	'OLDEST',
	AGE(NOW(),birthdate) AS age
FROM sales.employees
ORDER BY birthdate 
LIMIT 1
);


-- 31. Which salesperson handled the maximum number of customers?

SELECT 
	e.employeeid,
	e.firstname || ' ' || e.lastname AS employeefullname,
	COUNT(o.customerid) total_customers_handled
FROM sales.orders AS o
INNER JOIN sales.employees AS e
ON e.employeeid = o.salespersonid
GROUP BY employeeid, employeefullname
ORDER BY COUNT(o.customerid) DESC
LIMIT 1;

-- 32. Show the monthly sales trend (sum of sales grouped by month from orders).
WITH all_order AS(
	SELECT orderdate, sales FROM sales.orders
	UNION ALL
	SELECT orderdate, sales FROM sales.ordersarchive
)
SELECT
	TO_CHAR(orderdate,'YYYY Month') AS "Month and year",
	SUM(sales)
FROM all_order
GROUP BY "Month and year", DATE_TRUNC('month', orderdate)
ORDER BY DATE_TRUNC('month', orderdate);


	
