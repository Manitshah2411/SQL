SELECT * FROM sales.orders;
SELECT * FROM sales.ordersarchive;
SELECT * FROM sales.customers;
SELECT * FROM sales.employees;
SELECT * FROM sales.products;

/* 1. Customer Segmentation
Your marketing team wants to classify customers into value groups based on their score in customers.
High-value, medium-value, or low-value customers. 
Return: customerid, fullname, country, score, and the assigned group.
*/

SELECT
	c.customerid,
	CONCAT(c.firstname,' ',c.lastname) AS fullname,
	c.country,
	score,
	SUM(o.sales) AS total_sales,
	CASE 
		WHEN SUM(o.sales) <= 50 THEN 'LOW'
		WHEN SUM(o.sales) <= 100 THEN 'MEDIUM'
		ELSE 'HIGH'
	END AS category
FROM sales.customers AS c
INNER JOIN sales.orders AS o
ON c.customerid = o.customerid
GROUP BY c.customerid, fullname, c.country, score

/* 2. Order Fulfillment Status
From orders, management wants a simplified shipping status report where multiple existing statuses are grouped into broader categories like Completed, In Progress, or Pending.
Return: orderid, orderstatus, shipping_status. */


SELECT 
	orderid,
	orderstatus,
	CASE 
		WHEN orderstatus IN ('Delivered','Shipped') THEN 'Completed'
		WHEN orderstatus IN ('Processing','Packed','Awaiting Shipment') THEN 'In Process'
		WHEN orderstatus IN ('On Hold','Awaiting Payment') THEN 'Pending'
		ELSE 'N/A'
	END AS Status
FROM sales.orders;


/* 3. Product Discount Assignment
The pricing team wants to set up default discounts for each product based on its category.
Return: productid, product, category, price, and the discount percentage. */

SELECT 
	productid,
	product,
	category,
	price,
	CASE category
		WHEN 'Accessories' THEN price - (price * 0.1)
		WHEN 'Clothing' THEN price - (price * 0.05)
		ELSE price
	END AS Finalprice
FROM sales.products;


/* 4. Address Verification Report
Some orders have missing billaddress or shipaddress. Create a report that classifies each order as either Billing Missing, Shipping Missing, or Complete.
Return: orderid, billaddress, shipaddress, address_status. */

SELECT 
	orderid,
	shipaddress,
	billaddress,
	CASE 
		WHEN shipaddress IS NULL THEN '----Shipping address Missing----'
		ELSE shipaddress
	END AS shipaddressstatuts,
	CASE
		WHEN billaddress IS NULL THEN '----Billing address Missing----'
		ELSE billaddress
	END AS billaddressstatus
	
FROM sales.orders;


/* 5. Customer Loyalty Classification
The marketing team wants to label customers as Old Customers or New Customers depending on when they placed their first order (orderdate).
Return: orderid, customerid, orderdate, customer_type. */

SELECT
	c.customerid,
	CONCAT(c.firstname,' ',c.lastname) AS fullname,
	MIN(o.orderdate),
	CASE 
		WHEN MIN(orderdate) > '2025-02-01'::DATE THEN 'New customer'
		ELSE 'Old customer'
	END AS customertype
FROM sales.customers AS c
INNER JOIN sales.orders AS o
ON c.customerid = o.customerid
GROUP BY c.customerid, fullname
ORDER BY c.customerid ASC;

/* 6. Salesperson Assignment Check
For each order in orders, classify whether the order was:
Unassigned, Handled by a Key Account Manager, or Handled by a Regular Salesperson.
Return: orderid, salespersonid, and assigned_role. */


SELECT 
	o.orderid,
	o.salespersonid,
	CASE 
		WHEN o.salespersonid IS NULL THEN 'Unassigned'
		ELSE 'Regular Sales person'
	END AS Employeetype
FROM sales.orders AS o
LEFT JOIN sales.employees AS e
ON e.employeeid = o.salespersonid


/* 7. Free Shipping Eligibility
The logistics team wants to see which orders qualify for free shipping based on sales amount. Add a column for shipping fee (0 if eligible, otherwise fixed fee).
Return: orderid, sales, shipping_fee. */


SELECT 
	orderid,
	sales,
	CASE 
		WHEN sales < 50 THEN '40'
		ELSE 'Free'
	END AS ShippingFee
FROM sales.orders;

/* 8. Customer Score Cleaning
Some customers have missing score. Replace all null values with 0 in your report.
Return: customerid, fullname, score, and clean_score. */

SELECT 
	COALESCE(score,0) AS Cleanscore
FROM sales.customers;


/* 9. Customer Spending Category
Join customers and orders. For each customer, calculate their total spending and classify them into categories like Big Spender, Moderate Spender, Low Spender.
Return: customerid, fullname, total_spending, spending_category. */


SELECT
	c.customerid,
	CONCAT(c.firstname,' ',c.lastname) AS fullname,
	COALESCE(SUM(o.sales),0) AS total_spending,
	CASE 	
		WHEN SUM(o.sales) <= 50 THEN 'Low Spender'
		WHEN SUM(o.sales) <= 100 THEN 'Moderate Spender'
		WHEN SUM(o.sales) > 100 THEN 'High Spender'
		ELSE 'N/A'
	END AS spendingcategory
FROM sales.customers AS c
LEFT JOIN sales.orders AS o
ON c.customerid = o.customerid
GROUP BY c.customerid, fullname;

/* 10. Employee Workload Classification
Join orders with employees. Classify employees into Highly Active, Active, or Low Activity depending on how many orders they are assigned to.
Return: employeeid, fullname, num_orders, and workload. */


SELECT
    e.employeeid,
    CONCAT(e.firstname, ' ', e.lastname) AS fullname,
    COUNT(o.orderid) AS num_orders,
    CASE
        WHEN COUNT(o.orderid) >= 3 THEN 'Highly Active'
        WHEN COUNT(o.orderid) BETWEEN 1 AND 2 THEN 'Active'
        ELSE 'Low Activity'
    END AS workload
FROM sales.employees AS e
LEFT JOIN sales.orders AS o
    ON e.employeeid = o.salespersonid
GROUP BY e.employeeid, fullname;

