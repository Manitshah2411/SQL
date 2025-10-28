SELECT * FROM sales.customers
SELECT * FROM sales.orders
SELECT * FROM sales.ordersarchive

/*
Scenario: The marketing team wants to identify and create a dedicated table for "High-Value Customers" to target 
them with a special loyalty program.

Part 1: The Analytical Query
Write a single query to identify high-value customers from the sales.customers table. A high-value customer 
is defined as someone who has:
* Placed more than one order (across both sales.orders and sales.ordersarchive).
* Spent a total of more than $50.

The final report should contain the customer's customerid, their full name (CustomerFullName), their country, 
their total number of orders (order_count), and the total amount they've spent (total_spent). 
The list should be sorted by the total amount spent in descending order.

Part 2: Creating the Segmentation Table
1. DDL Task: Write a CREATE TABLE statement to create a new table named high_value_customers. 
The columns should match the output of your query from Part 1.
2. DML Task: Write an INSERT INTO ... SELECT command to take the results of your analytical query and populate 
the high_value_customers table.
*/


--PART 1:

WITH all_orders AS(
	SELECT orderid, customerid, quantity, sales FROM sales.orders
	UNION ALL
	SELECT orderid, customerid, quantity, sales FROM sales.ordersarchive
)
INSERT INTO high_value_customers (customerid, customerfullname,country,total_orders,total_spent)
SELECT 
	c.customerid,
	CONCAT_WS(' ',c.firstname,c.lastname) AS customerfullname,
	c.count>ry,
	COUNT(ao.orderid) AS total_orders, -- The count function only count rows which are not NULL so, it's always better
									   -- to give the parameter a PRIMARY KEY or NOT NULL values to it.
	SUM(ao.sales) AS total_spent
FROM sales.customers as c
INNER JOIN all_orders AS ao ON c.customerid = ao.customerid -- Filters out all the customers which doesn't have any order
															-- and also orders which doesn't have any customer's detailes
GROUP BY c.customerid, customerfullname, c.country
HAVING COUNT(ao.orderid) > 1 AND SUM(ao.sales) > 50
ORDER BY total_spent DESC;


--PART 2:
CREATE TABLE IF NOT EXISTS high_value_customers(
	customerid INT PRIMARY KEY NOT NULL,
	customerfullname VARCHAR(50) NOT NULL,
	country VARCHAR(30),
	total_orders INT,
	total_spent INT
);

DROP TABLE high_value_customers;

SELECT * FROM high_value_customers;


/*
Scenario: Management needs a performance report to identify the top-performing employees in the "Sales" department
based on their sales in the year 2024.

Part 1: The Analytical Query
Write a single query that calculates the performance of each employee in the 'Sales' department for all orders placed in the 
year 2024 (from both sales.orders and sales.ordersarchive).
The report must show the employee's full name (EmployeeFullName), the total number of unique products they sold 
(unique_products_sold), the total number of orders they handled (total_orders), and their total sales revenue (total_revenue).
Filter this report to only include employees who handled more than one order, and sort the results by the total_revenue 
in descending order.

Part 2: Creating and Populating the Performance Table
1. DDL Task: Write a CREATE TABLE statement to create a new table named sales_employee_performance_2024. The columns
should match the output of your query from Part 1.
2. DML Task: Write an INSERT INTO ... SELECT command to populate the sales_employee_performance_2024 table with 
the results from your analytical query.
*/

SELECT * FROM sales.employees;
SELECT * FROM sales.orders;
SELECT * FROM sales.ordersarchive;
SELECT * FROM sales.products;

WITH all_orders AS(
	SELECT orderid,productid,salespersonid,quantity,sales FROM sales.orders
	WHERE EXTRACT(YEAR FROM orderdate) >= 2024
	UNION ALL
	SELECT orderid,productid,salespersonid,quantity,sales FROM sales.ordersarchive
	WHERE EXTRACT(YEAR FROM orderdate) >= 2024
)
SELECT 
	e.employeeid,
	CONCAT_WS(' ',e.firstname,e.lastname) AS employeefullname,
	COUNT(DISTINCT ao.productid) AS total_unique_products,
	COUNT(ao.orderid) AS total_orders,
	SUM(ao.sales) AS total_revenue
FROM sales.employees AS e
INNER JOIN all_orders AS ao ON e.employeeid = ao.salespersonid
WHERE e.department = 'Sales'
GROUP BY e.employeeid,employeefullname
HAVING COUNT(ao.orderid) > 1
ORDER BY total_revenue DESC;


/*
Scenario: The sales manager needs a final summary report for a new marketing campaign. To create this, you must first 
consolidate historical data and then generate a targeted analysis.

Part 1: The Analytical Query
Write a single query that creates a sales performance report for all orders (from both sales.orders and sales.ordersarchive) 
that meet the following criteria:
* The order was placed in the year 2024 or later.
* The customer is from the 'USA', 'Germany', or 'India'.

The final report should be grouped by the customer's country and the product category. For each group, it must show:
* The customer country.
* The product category.
* The total number of orders, named order_count.
* The total sales amount, named total_revenue.
Finally, filter this report to only include groups where the total_revenue is greater than $60, and sort the entire 
result by total_revenue in descending order.

Part 2: Creating and Populating the Final Report Table
1. DDL Task: Write a CREATE TABLE statement to create a new table named sales_report_2024_plus. It should have four columns with appropriate data types to store the results from your query in Part 1 (country, category, order_count, total_revenue).
2. DML Task: Write a single INSERT INTO ... SELECT command that takes the entire complex query you built in Part 1 and inserts its final results directly into your new sales_report_2024_plus table.
*/


SELECT * FROM sales.employees;
SELECT * FROM sales.orders;
SELECT * FROM sales.ordersarchive;
SELECT * FROM sales.products;
SELECT * FROM sales.customers;

WITH all_orders AS(
	SELECT orderid, productid, customerid, sales FROM sales.orders
	WHERE EXTRACT(YEAR FROM orderdate) >= 2024
	UNION ALL 
	SELECT orderid, productid, customerid, sales FROM sales.ordersarchive
	WHERE EXTRACT(YEAR FROM orderdate) >= 2024
)

SELECT 
	c.customerid,
	c.country,
	p.category,
	COUNT(ao.orderid) AS total_order,
	SUM(ao.sales) AS total_revenue
FROM all_orders AS ao
INNER JOIN sales.customers AS c ON c.customerid = ao.customerid
INNER JOIN sales.products AS p ON p.productid = ao.productid
WHERE c.country IN('USA','Germany','India')
GROUP BY c.customerid, c.country, p.category
HAVING SUM(ao.sales) > 60 
ORDER BY total_revenue DESC

