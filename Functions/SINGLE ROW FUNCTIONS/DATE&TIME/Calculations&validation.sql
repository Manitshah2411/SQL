-----------------------------
--|	SINGLE ROW FUNCTIONS  |--
-----------------------------

----DATE & TIME FUNCTIONS----

-- 1. INTERVAL & AGE()
-- INTERVAL returns DATETIME both

SELECT
	creationtime,
	(creationtime + interval '1 year')::DATE AS added_one_year, -- interval is used to add or sub any specific time period 
																-- to a date
	orderdate,
	(orderdate + interval '6 month')::DATE AS added_12_months,
	(creationtime + interval '3 hour 2 minute 1 second') AS added_time, -- you can also add precise time to the DATETIME
	(creationtime - interval '3 hour 2 minute 1 second') AS sub_time -- you can also sub precise time to the DATETIME
FROM sales.orders 


---

SELECT 
	creationtime,
	orderdate,
	shipdate,
	shipdate::DATE - orderdate::DATE  AS diff_order_ship, -- This is how you can find difference between dates. 
											 -- By substracting one from another
	AGE(shipdate,creationtime), -- By the AGE() you can get precise timestamp and date from the datetime
	EXTRACT(YEAR FROM AGE('2006-11-24','2005-11-24')) -- Can also use EXTRACT to get the specific thing like date or month
FROM sales.orders
	


---  


SELECT
	TO_CHAR(orderdate, 'Mon') AS order_month ,
	ROUND(AVG(EXTRACT(DAY FROM AGE(shipdate,orderdate)))) || ' Days' AS avg_shipping_duration
	-- 2nd way to find shipping duration : 'shipdate::DATE - orderdate::DATE'
	
FROM sales.orders
GROUP BY TO_CHAR(orderdate, 'Mon') 
ORDER BY order_month ASC;








