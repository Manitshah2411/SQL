-- What is VIEW?
-- Unlike a normal table, it does not store data physically unless it is materialized VIEWS

-- USE CASE :
-- Security : Allow only the specific data to the interns and analyst for security reasons.
-- Redundancy : If multiple analyst write the same 1st step queries for the analysis you can create a view for that specific 
--				query
-- Complexity wrapper : If you want a clean query to show without the complex joins and aggregation, you can first create a 
-- 						view and can than do the analysis on that.


WITH CTE_mon_summary AS -- CTE is only useful when you want to use the logic multiple times in the same query 	
(						-- But multiple data engineers using the same logic and writing the same query every time
SELECT 					-- It is better to make a view which acts a mediator to the main query and generates intermediate result
						-- which is than can be used by the engineers to do the analysis easily with redundancy
	TO_CHAR(orderdate,'Mon YYYY') AS month_year,
	SUM(sales) AS total_sales,
	COUNT(orderid) AS total_orders,
	SUM(quantity) AS total_quantity
FROM sales.orders
GROUP BY TO_CHAR(orderdate,'Mon YYYY')
)
SELECT 
	month_year,
	total_sales,
	total_orders,
	total_quantity,
	SUM(total_sales) OVER(ORDER BY total_sales)
FROM CTE_mon_summary


-- Creating view

CREATE OR REPLACE VIEW sales.v_monthly_summary AS
(
SELECT 					
	TO_CHAR(orderdate,'Mon YYYY') AS month_year,
	SUM(sales) AS total_sales,
	COUNT(orderid) AS total_orders,
	SUM(quantity) AS total_quantity
FROM sales.orders
GROUP BY TO_CHAR(orderdate,'Mon YYYY')
)

-- Now Multiple user can directly write queries for the same logic without the CTE 
-- The trade off the VIEW is performance. 
SELECT 
	month_year,
	total_sales,
	total_orders,
	total_quantity,
	SUM(total_sales) OVER(ORDER BY total_sales)
FROM v_monthly_summary


-- Task : Provide a combine detailed VIEW for all the countries except the USA for the EU sales Team


CREATE OR REPLACE VIEW sales.v_summary_table AS
(SELECT 
	o.orderid,
	CONCAT(c.firstname,' ',c.lastname) AS CustomerName,
	c.country,
	p.product,
	CONCAT(e.firstname,' ',e.lastname) AS EmployeeName,
	e.salary,
	o.sales,
	o.quantity
FROM sales.customers AS c
INNER JOIN sales.orders AS o
ON c.customerid = o.customerid
INNER JOIN sales.employees  AS e
ON e.employeeid = o.salespersonid
INNER JOIN sales.products AS p
ON p.productid = o.productid)



