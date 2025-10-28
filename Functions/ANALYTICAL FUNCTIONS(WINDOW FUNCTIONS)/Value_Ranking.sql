-- Ranking Functions : LAG(), LEAD(), FIRST_VALUE(), LAST_VALUE()


-- Analyze MoM performance by finding the % change in sales between current and the previous month
SELECT
    *,
    current_sales - lag_sales AS MoM_change,
    ROUND(((current_sales - lag_sales) / NULLIF(lag_sales,0)::numeric) * 100, 2) AS MoM_percent_change
FROM (
    SELECT
        EXTRACT(MONTH FROM orderdate) AS month,
        SUM(sales) AS current_sales,
        LAG(SUM(sales)) OVER(ORDER BY EXTRACT(MONTH FROM orderdate)) AS lag_sales
    FROM sales.orders
    GROUP BY EXTRACT(MONTH FROM orderdate)
) t;



-- Find loyal customers based on the avg of days between their orders
SELECT
	*,
	RANK() OVER(ORDER BY avg_days)
FROM 
(SELECT 
	orderid,
	customerid,
	orderdate,
	diff_days,
	ROUND(AVG(diff_days) OVER(PARTITION BY customerid)::numeric,2) AS avg_days
FROM 
(SELECT
	orderid,
	customerid,
	orderdate,
	COALESCE(orderdate - LAG(orderdate,1) OVER(PARTITION BY customerid ORDER BY orderdate),null) AS diff_days
FROM sales.orders
ORDER BY customerid)t)f;



-- FIRST_VALUE() & LAST_VALUE()

SELECT
	orderid,
	customerid,
	sales,
	orderdate,
	FIRST_VALUE(sales) OVER(ORDER BY EXTRACT(MONTH FROM orderdate)),
	-- First_value() gets the first value of the window.
	-- DEFAULT frame clause : RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
	LAST_VALUE(sales) OVER(ORDER BY EXTRACT(MONTH FROM orderdate) 
						   ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
FROM sales.orders;


-- Find the lowest and the highest sales.

SELECT
	orderid,
	productid,
	sales,
	FIRST_VALUE(sales) OVER(PARTITION BY productid ORDER BY sales ASC),
	FIRST_VALUE(sales) OVER(PARTITION BY productid ORDER BY sales DESC),
	LAST_VALUE(sales) OVER(PARTITION BY productid ORDER BY sales
						ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
FROM sales.orders;