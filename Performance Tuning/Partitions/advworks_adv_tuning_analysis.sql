-- 1.
/*
Task:You are asked to analyze customer order behavior and optimize query performance.
Steps:
1. Create a summary table sales.customer_summary that stores:
    * customerid, total_orders, total_spent, last_order_date.
2. Populate it using data from sales.salesorderheader and sales.salesorderdetail.
3. Create an index on customerid and last_order_date to optimize lookups.
4. Write a query using CTE + window functions to find each customer’s rank based on total spending.
5. Display the top 10 customers per territory using ROW_NUMBER().
6. Analyze query performance before and after adding the index using EXPLAIN ANALYZE.
*/

----
CREATE TABLE IF NOT EXISTS practice.customer_summary(
	customer_id INT NOT NULL PRIMARY KEY,
	total_orders INT,
	total_spent INT,
	last_order_date DATE
)

----
INSERT INTO practice.customer_summary(customer_id, total_orders, total_spent, last_order_date)
SELECT 
	soh.customerid AS customer_id,
	COUNT(DISTINCT soh.id) AS total_orders,
	ROUND(SUM(sod.unitprice * sod.orderqty),2) AS total_spent,
	MAX(soh.orderdate) AS last_order_date
FROM sa.soh AS soh
JOIn sa.sod AS sod ON soh.salesorderid = sod.salesorderid
GROUP BY soh.customerid
ORDER BY total_spent DESC;

----
EXPLAIN ANALYSE SELECT customer_id FROM practice.customer_summary WHERE last_order_date > '2014-05-07';

CREATE INDEX idx_last_order_date 
ON practice.customer_summary(last_order_date);

----
WITH rankings AS
(
	SELECT *,
	RANK() OVER(ORDER BY total_spent DESC) AS ranks
	FROM practice.customer_summary
)
SELECT * FROM rankings WHERE ranks <= 10
	


-- 2.
/*
Task:Management wants a live dashboard that shows product profitability.
Steps:
1. Create a view sales.v_product_profitability that joins:
    * production.product
    * sales.salesorderdetail
    * sales.salesorderheader
    * Include: total revenue, total quantity sold, average discount, profit margin.
2. Create a scalar function sales.fn_profit_margin(unitprice, cost) that returns the profit %.
3. Add a trigger on salesorderdetail so when new rows are inserted, a sales_audit table logs:
    * productid, orderid, qty, timestamp, username.
4. Query the view to find top 5 profitable products in 2024 using a subquery.
*/

SELECT * FROM sa.sod
----
CREATE OR REPLACE VIEW practice.v_profitability AS
SELECT 
	p.productid,
	p.name,
	SUM(sod.unitprice * sod.orderqty) AS revenue,
	SUM(sod.unitprice * sod.orderqty) - SUM(sod.orderqty * p.standardcost) AS profit_margin,
	ROUND(practice.pro_margin(SUM(sod.unitprice * sod.orderqty) ,SUM(sod.orderqty * p.standardcost)),2) AS margin_perc
FROM pr.p AS p
JOIN sa.sod AS sod ON p.productid = sod.productid
GROUP BY p.productid, p.name

----
CREATE OR REPLACE FUNCTION practice.pro_margin(unit_price NUMERIC,cost NUMERIC)
RETURNS NUMERIC 
LANGUAGE plpgsql
AS $$
BEGIN
	IF cost <= 0 THEN RETURN 0;
	END IF;
	RETURN ((unit_price - cost) / cost) * 100;
END;
$$

----
CREATE TABLE sales_details_logs(
	productid INT,
	salesorderid INT,
	qty INT,
	added_time TIMESTAMP DEFAULT NOW()
) 

CREATE OR REPLACE FUNCTION sd_logs_fn()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
	INSERT INTO sales_details_logs(productid, salesorderid, qty, added_time)
	VALUES(NEW.productid,NEW.salesorderid,NEW.orderqty, NOW());
	RETURN NEW;
END;
$$;

CREATE TRIGGER trg_sd_logs
AFTER INSERT ON sales.salesorderdetail
FOR EACH ROW
EXECUTE FUNCTION sd_logs_fn();

SELECT * FROM sa.soh

INSERT INTO sales.salesorderdetail VALUES(75123,121319,NULL,1,712,1,339,0,uuid_generate_v1(),NOW());
SELECT * FROM sales_details_logs


-- 3.
/*
Task:You need to optimize storage for product inventory history.
Steps:
1. Create a partitioned table production.productinventory_history Partition by year(modifieddate).
2. Add CHECK constraints for each child partition (2019, 2020, 2021, MAXVALUE).
3. Insert data from production.productinventory using INSERT INTO ... SELECT ....
4. Use a CTE to compute running inventory count by product using SUM(quantity) OVER(PARTITION BY productid ORDER BY modifieddate).
5. Find the top 10 products with the most fluctuating inventory using STDDEV().
*/

----
SELECT * FROM sa.sod;
CREATE TABLE IF NOT EXISTS prt_sod
(
	id INT NOT NULL,
	salesorderid INT NOT NULL,
	salesorderdetailid INT NOT NULL,
	productid INT NOT NULL,
	orderqty INT,
	unitprice INT,
	modifieddate DATE NOT NULL,
	PRIMARY KEY (id, modifieddate)
) PARTITION BY RANGE(modifieddate)

INSERT INTO prt_sod(id,salesorderid,salesorderdetailid,productid,orderqty,unitprice,modifieddate)
SELECT id,salesorderid,salesorderdetailid,productid,orderqty,unitprice,modifieddate FROM sa.sod

CREATE TABLE prt_sod_2011
PARTITION OF prt_sod 
FOR VALUES FROM ('2011-01-01') TO ('2012-01-01');

CREATE TABLE prt_sod_2012
PARTITION of prt_sod
FOR VALUES FROM ('2012-01-01') TO ('2013-01-01');

CREATE TABLE prt_sod_2013
PARTITION OF prt_sod
FOR VALUES FROM ('2013-01-01') TO ('2014-01-01');

CREATE TABLE prt_sod_2014
PARTITION OF prt_sod
FOR VALUES FROM ('2014-01-01') TO (MAXVALUE);


SELECT *,
	SUM(quantity) OVER(PARTITION BY productid ORDER BY modifieddate
						ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
FROM pr.pi;


SELECT 
    productid,
    ROUND(STDDEV(quantity), 2) AS inventory_fluctuation
FROM pr.pi
GROUP BY productid
ORDER BY inventory_fluctuation 


-- 4.
/*
Task:HR wants an automated review and reward system.
Steps:
1. Create a stored procedure humanresources.sp_calculate_bonus(year) that:
    * Calculates bonus = 5% of total sales made by each salesperson.
    * Uses a CTE and SUM(sales) from sales.salesorderheader.
    * Inserts or updates the humanresources.employee_bonus table.
2. Create a trigger on that table to log every update in an employee_bonus_audit table.
3. Display top 10 employees with total sales, bonus, and rating.
*/

----
DROP TABLE hr.emp_bonus;
CREATE TABLE IF NOT EXISTS hr.emp_bonus
(
	id INT PRIMARY KEY,
	total_sales INT,
	bonus INT,
	updated TIMESTAMP DEFAULT NOW()
)

----
CREATE OR REPLACE PROCEDURE humanresources.sp_calc_bonus(targetyear INT)
LANGUAGE plpgsql
AS $$
BEGIN 
	INSERT INTO hr.emp_bonus(id, total_sales, bonus)
	(SELECT 
		salespersonid,
		SUM(totaldue),
		SUM(totaldue) * 0.05
	FROM sa.soh
	WHERE EXTRACT(YEAR FROM orderdate) = targetyear AND salespersonid IS NOT NULL
	GROUP BY salespersonid)
	ON CONFLICT(id)
		DO UPDATE
		SET total_sales = EXCLUDED.total_sales,
			bonus = EXCLUDED.bonus,
			updated = NOW();
END;
$$;

----
CALL humanresources.sp_calc_bonus(2011);
SELECT * FROM hr.emp_bonus;

CREATE TABLE IF NOT EXISTS hr.emp_bonus_logs
(
	id INT,
	total_sales INT,
	bonus INT,
	updated TIMESTAMP DEFAULT NOW()
);

----
CREATE OR REPLACE FUNCTION emp_bonus_fn()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
	INSERT INTO hr.emp_bonus_logs(id,total_sales,bonus)
	VALUES (OLD.id,OLD.total_sales,OLD.bonus);

	NEW.updated := NOW();
	RETURN NEW;
END;
$$;

----
CREATE OR REPLACE TRIGGER emp_bonus_trg
BEFORE UPDATE ON hr.emp_bonus
FOR EACH ROW
EXECUTE FUNCTION emp_bonus_fn();

UPDATE hr.emp_bonus
SET bonus = bonus + (bonus * 0.05)
WHERE id = 274

SELECT * FROM hr.emp_bonus_logs;

-- 5.
/*
Task:Finance wants a 5-year analysis with detailed breakdowns.
Steps:
1. Create a partitioned fact table finance.sales_fact_partitioned by orderdate.
2. Populate it using a CTE joining:
    * sales.salesorderheader, sales.salesorderdetail, production.product, sales.customer
3. Add calculated columns: total_amount, discount_amount, profit_amount.
*/

DROP TABLE IF EXISTS practice.sales_details;
CREATE TABLE IF NOT EXISTS practice.sales_details
(
	customerid INT NOT NULL,
	total_products INT,
	total_orders INT,
	total_order_qty INT,
	avg_cost INT,
	last_orderdate DATE,
	total_amount INT,
	profit_margin INT,
	PRIMARY KEY (customerid, last_orderdate)	
) PARTITION BY RANGE(last_orderdate);

SELECT * FROM sa.soh;
SELECT * FROM pr.p;

CREATE TABLE practice.sales_details_2011
PARTITION OF practice.sales_details
FOR VALUES FROM ('2011-01-01') TO ('2012-01-01');

CREATE TABLE practice.sales_details_2012
PARTITION OF practice.sales_details
FOR VALUES FROM ('2012-01-01') TO ('2013-01-01');

CREATE TABLE practice.sales_details_2013
PARTITION OF practice.sales_details
FOR VALUES FROM ('2013-01-01') TO ('2014-01-01');

CREATE TABLE practice.sales_details_2014
PARTITION OF practice.sales_details
FOR VALUES FROM ('2014-01-01') TO (MAXVALUE);

INSERT INTO practice.sales_details(customerid,total_products,total_orders,total_order_qty,avg_cost,last_orderdate,
								   total_amount,profit_margin)
SELECT 
	soh.customerid,
	COUNT(DISTINCT sod.productid) AS total_products,
	COUNT(DISTINCT soh.salesorderid) AS total_orders,
	SUM(sod.orderqty) AS total_order_qty,
	ROUND(AVG(p.standardcost),2) AS avg_cost,
	MAX(soh.orderdate) AS last_orderdate,
	SUM(sod.orderqty * sod.unitprice) AS total_amount,
	ROUND(SUM(sod.orderqty * sod.unitprice) - SUM(sod.orderqty * p.standardcost),2) AS profit_margin
FROM sa.soh AS soh
JOIN sa.sod AS sod ON sod.salesorderid = soh.salesorderid
JOIN pr.p AS p ON p.productid = sod.productid
GROUP BY soh.customerid

-- 4.
/*
Task:Build a simple alert system for unusually high sales.
Steps:
1. Create a table sales.sales_alert_log with columns: orderid, salespersonid, totaldue, alert_time, details (JSONB).
2. Write a trigger function sales.fn_check_high_value_order() that:
    * Activates on INSERT on salesorderheader.
    * If totaldue > 50000, insert a log in sales_alert_log.
    * Store order details in JSON format.
3. Test it by inserting a few orders and verifying alerts.
4. Query the alert log grouped by salesperson to find who gets the most high-value orders.
*/

CREATE TABLE IF NOT EXISTS practice.sales_alert_log(
	orderid INT NOT NULL,
	salespersonid INT NOT NULL,
	totaldue INT,
	alert_time TIMESTAMP DEFAULT NOW(),
	details JSONB
);

SELECT * FROM sa.soh;

CREATE OR REPLACE FUNCTION practice.high_value_emp()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
	IF NEW.totaldue >= 50000 THEN
		INSERT INTO practice.sales_alert_log(orderid, salespersonid, totaldue, details)
		VALUES(NEW.salesorderid, NEW.salespersonid, NEW.totaldue,
				json_build_object('customerid',NEW.customerid,
								  'orderdate',NEW.orderdate,
								  'status',NEW.status,
								  'comment',NEW.comment));
	END IF;
	RETURN NEW;	  
END;
$$;

CREATE OR REPLACE TRIGGER high_value_emp_trg
AFTER INSERT ON sales.salesorderheader
FOR EACH ROW
EXECUTE FUNCTION practice.high_value_emp();

INSERT INTO sales.salesorderheader VALUES(75124,8,'2014-7-8 00:00:00','2014-7-15 00:00:00', '2014-7-10 00:00:00',5,'true',
										  NULL,'10-4030-011981',18759,282,3,855,629,5,806,NULL,NULL,3587,286,40,50000,'Best');

SELECT * FROM practice.sales_alert_log;


-- 8.
/*
Task:Build a dataset for ML model training.
Steps:
1. Create a view ml.v_customer_sales_features that includes:
    * Customer demographics (join person.person, sales.customer)
    * Total orders, avg order value, recency (days since last order)
    * Frequency (orders per year)
    * Monetary value
2. Use window functions (AVG() OVER, COUNT() OVER) for aggregations.
3. Export the data for ML usage (using COPY TO or pgAdmin export).
*/

SELECT * FROM pe.p;
SELECT * FROM hr.e;
SELECT * FROM sa.c;
SELECT * FROM sa.sod;
SELECT * FROM sa.sp;
SELECT * FROM sa.soh;


CREATE OR REPLACE VIEW practice.v_c_sales AS
SELECT 
	CONCAT(p.firstname,' ',p.lastname) AS personefullname,
	COUNT(soh.salesorderid) OVER(PARTITION BY c.customerid) AS total_orders,
	ROUND(AVG(soh.totaldue)OVER(PARTITION BY c.customerid),2) AS avg_orders,
	ROUND(SUM(soh.totaldue) OVER(PARTITION BY c.customerid),2) AS total_spending,
	CURRENT_DATE - MAX(soh.orderdate) OVER(PARTITION BY c.customerid) AS last_orderdate
FROM pe.p AS p
JOIN sa.c AS c ON c.customerid = p.businessentityid
JOIN sa.soh AS soh ON soh.customerid = c.customerid

-- \copy (SELECT * FROM practice.v_c_sales) TO '/Users/manitkalpeshshah/Downloads/demo.csv' CSV HEADER;


