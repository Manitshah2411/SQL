SELECT * FROM sales.orders;
SELECT * FROM sales.ordersarchive;
SELECT * FROM sales.customers;
SELECT * FROM sales.employees;
SELECT * FROM sales.products;

-- Categorize the total sales with High, low and medium
SELECT
	CASE
		WHEN sales >= 50 THEN 'High'
		WHEN sales >= 20 AND sales < 50 THEN 'Medium'
		WHEN sales < 20 THEN 'Low'
	END AS Category,
	SUM(sales) AS total_sales
FROM sales.orders 
GROUP BY Category
ORDER BY SUM(sales) ASC;

-- Another way
SELECT 
	Category,
	SUM(sales) AS total_sales
FROM (SELECT 
	sales,
	CASE    
		WHEN sales >= 50 THEN 'High' -- The THEN keyword statement should have the same datatypes
		WHEN sales >= 20 AND sales < 50 THEN 'Medium'
		WHEN sales < 20 THEN 'Low'
	END AS Category
FROM sales.orders
)t-- Temp name of the bracket statment table
GROUP BY Category
ORDER BY SUM(sales) DESC;


-- Data transformation for readability or vice versa for performance

SELECT 
	firstname,
	lastname,
	CASE 
		WHEN Gender = 'M' THEN 'Male'
		WHEN Gender = 'F' THEN 'Female'
		ELSE 'Unknown'
	END AS Genders
FROM sales.employees;


SELECT 
	CONCAT(firstname,' ',lastname) AS fullname,
	CASE country -- You can directly write the column name if you want to write all the WHEN THEN statment for that column only
		WHEN 'India' THEN 'IN'
		WHEN 'USA' THEN 'US'
		WHEN 'Germany' THEN 'DE'
		WHEN 'Pakistan' THEN 'Pak'
		ELSE 'N/A'
	END AS abb_country
FROM sales.customers;


-- Handling nulls in sales.customers table

SELECT 
	customerid,
	CONCAT(firstname,' ',lastname) AS fullname,
	CASE country 
		WHEN 'India' THEN 'IN'
		WHEN 'USA' THEN 'US'
		WHEN 'Germany' THEN 'DE'
		WHEN 'Pakistan' THEN 'Pak'
		ELSE 'N/A'
	END AS abb_country,
	CASE 
		WHEN score IS NULL THEN 0
	END AS Cleanscore,
	AVG( COALESCE(score,0)) OVER() -- Shorter way with COALESCE 
FROM sales.customers;


-- Using CASE statements with aggregations

SELECT 
    c.customerid,
    CONCAT(c.firstname,' ',c.lastname) AS Fullname,
    c.country,
    SUM(CASE WHEN o.sales >= 30 THEN 1 ELSE 0 END) AS greaterthan30,
	COUNT(*) AS total_orders
FROM sales.customers AS c
INNER JOIN sales.orders AS o
    ON c.customerid = o.customerid

GROUP BY c.customerid, Fullname, c.country;



