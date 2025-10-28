SELECT * FROM sales.orders;
SELECT * FROM sales.ordersarchive;
SELECT * FROM sales.customers;
SELECT * FROM sales.products;
SELECT * FROM sales.employees;

-- % based RANKING() : CUME_DIST() & PERCENT_RANK()
-- Ranged from 0 - 1. Eg. 0.25, 0.50, 0.75, 1
-- CUME_DIST() : Position NR / No. of rows;
-- PERCENT_RANK() : Position NR - 1/ No. of rows - 1;


SELECT
	orderid,
	sales,
	CUME_DIST() OVER(ORDER BY sales ASC), -- used for cumulative distrubution
	ROUND(PERCENT_RANK() OVER(ORDER BY sales ASC)::numeric,2) -- used for relative position
FROM sales.orders;


-- Find products that falls within the highest 40% price.
SELECT 
*
FROM
(SELECT
	product,
	price,
	CUME_DIST() OVER(ORDER BY price DESC) AS distribution_cume,
	PERCENT_RANK() OVER(ORDER BY price DESC) AS distribution_perc
FROM sales.products)t
WHERE distribution_cume <= 0.4 

