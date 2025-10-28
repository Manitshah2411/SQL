select * from sales.orders;
-----------------------------
--|	SINGLE ROW FUNCTIONS  |--
-----------------------------

----DATE & TIME FUNCTIONS----

-- 1. NOW(), EXTRACT, YEAR, MONTH, DAY.

SELECT 
	orderid,
	orderdate,
	shipdate,
	creationtime,
	NOW(),
	'2025-8-15' as today,
	EXTRACT(YEAR FROM creationtime), 
	EXTRACT(MONTH FROM creationtime),
	EXTRACT(DAY FROM creationtime)
FROM sales.orders;


-- 2. DATE_PART 
-- another way to extract year, month, week, quarter, day, hour(h), minutes(mm), seconds(s), 
-- dow(day of the week (0=Sunday and 6=Saturday)), isodow(ISO day of the week (1=Monday and 7=Sunday)),
-- doy(day of the year(1-365/366)), epoch(total number of seconds since jan 1 1970)
SELECT
	creationtime,
	DATE_PART('year',creationtime) AS years,
	DATE_PART('month',creationtime) AS months,
	DATE_PART('week',creationtime)AS week,
	DATE_PART('quarter',creationtime)AS quarter,
	DATE_PART('day',creationtime)AS daya,
	DATE_PART('h',creationtime)AS hours,
	DATE_PART('mm',creationtime)AS minutes,
	DATE_PART('s',creationtime) AS seconds,
	DATE_PART('dow',creationtime) AS dow,
	DATE_PART('isodow',creationtime) AS isodow,
	DATE_PART('doy',creationtime) AS doy,
	DATE_PART('epoch',creationtime) AS epoch
FROM sales.orders;



-- 3. TO_CHAR() 
-- DD(Date INT), Day/Dy(Weekday STR), YYYY(Year INT), MM(Month INT), Month/Mon(Month STR)

SELECT
    creationtime,
	TO_CHAR(orderdate, 'Day, Dy') AS Days, -- Dy for abbreviation Day for full Dayname
	TO_CHAR(orderdate, 'Month, Mon') AS Days, -- Mon give abbreviation of months like Jan, feb...
	TO_CHAR(orderdate, 'DD Mon, YYYY') AS ind_format, 
    TO_CHAR(orderdate, 'YYYY-MM-DD') AS iso_format,
    TO_CHAR(orderdate, 'Mon DD, YYYY') AS usa_format, 
    TO_CHAR(orderdate, 'Dy, Month DD') AS friendly_format, 
    TO_CHAR(orderdate, 'hh:MI AM') AS time_format
	
FROM
    sales.orders;




-- 4. DATE_TRUNC

SELECT
	creationtime,
	NOW() - DATE_TRUNC('year',creationtime) AS total_time_tillnow, -- This gets the total time elaped till now in the current 
																-- year till current time NOW()
	DATE_TRUNC('minute',NOW() - DATE_TRUNC('year',creationtime)) AS total_time_DT, --This DATE_TRUNC resets the value till where
														-- Where we want and rest other is reseted.
	DATE_TRUNC('minute',creationtime), -- gets the data till minute and after that seconds are reset i.e 12:55:'00'
	DATE_TRUNC('day',creationtime) -- gets till date and rest the HH:MM:SS are reset to 00:00:00
FROM sales.orders;

---
SELECT 
	DATE_TRUNC('month',creationtime), -- here grouping by months can be done and analysis can be easier
	COUNT(DISTINCT orderid) -- so here all the order id is always distinct, while analysis if you want to narrow the details
							-- like a sales for X month or X year at that time grouping may not work properly
FROM sales.orders
GROUP BY DATE_TRUNC('month',creationtime);

---
SELECT (DATE_TRUNC('month', creationtime) + interval '1 month' - interval '1 day')::date -- ::date (CASTED the whole result 
																						 -- date, so all the extra hours, 
																						 -- minutes are filtered out)
		-- first the DATE_TRUNC gets the data till just the month so, the day and after all the things are reseted.
		-- Than to +,- any days or months interval keyword is used. So after adding one month to it,
		-- Than from the starting date of the next month, interval '1 day' is substracted so that we can get the
		-- previous month's last date.
FROM sales.orders 

---
SELECT 
	TO_CHAR(orderdate,'Mon'), -- To format the month from the orderdate 
	COUNT(DISTINCT orderid) -- Aggregated the orders by each month
FROM sales.orders 
GROUP BY TO_CHAR(orderdate,'Mon')

---
SELECT 
	TO_CHAR(orderdate,'Mon'), -- To format the month from the orderdate 
	* 
FROM sales.orders
WHERE TO_CHAR(orderdate,'Mon') = 'Feb' -- filtered out everything except feb month. 
									   -- TO_CHAR.. is used so that the formatted time period 
									   -- can be filtered out. You can also use 
									   -- EXTRACT(month FROM orderdate) = 2.  


