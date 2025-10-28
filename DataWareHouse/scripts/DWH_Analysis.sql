
-- Analyse the yearly performance of products by comparing it to both the avg sales performance of the product
-- and the and the previous year's sales

SELECT 
	f.order_year,
	f.name,
	f.total_sales_product,
	f.avg_sales_product,
	f.total_sales_product - f.avg_sales_product AS diff_avg,
	CASE WHEN (f.total_sales_product - f.avg_sales_product) > 0 THEN 'Above Average'
	WHEN (f.total_sales_product - f.avg_sales_product) < 0 THEN 'Below Average'
	ELSE 'No change'
	END AS flag,
	LAG(f.total_sales_product) OVER(PARTITION BY f.name ORDER BY f.order_year) AS lag_sales,
	f.total_sales_product - LAG(f.total_sales_product) OVER(PARTITION BY f.name ORDER BY f.order_year) AS diff_lag_sales
FROM
(SELECT 
	t.order_year,
	t.name, 
	total_sales_product,
	ROUND(AVG(total_sales_product) OVER(PARTITION BY t.name),2) AS avg_sales_product
FROM
	(SELECT 
		EXTRACT(YEAR FROM fs.order_date) AS order_year,
		dp.name, 
		SUM(fs.sales) AS total_sales_product
	FROM gold.fs AS fs
	JOIN gold.dp AS dp ON fs.product_key = dp.product_key
	WHERE order_date IS NOT NULL
GROUP BY EXTRACT(YEAR FROM fs.order_date),dp.name)t)f;


-- Which categories contribute the most to the overall sales
SELECT 
	t.category,
	t.total_sales_product,
	t.total_sales,
	ROUND(((t.total_sales_product / t.total_sales) * 100),2) AS contribution
FROM
(SELECT 
	dp.category,
	SUM(fs.sales) total_sales_product,
	SUM(SUM(fs.sales)) OVER() AS total_sales
FROM gold.dp AS dp
JOIN gold.fs AS fs ON fs.product_key = dp.product_key
GROUP BY dp.category
ORDER BY dp.category
)t;

SELECT * FROM gold.dc;
SELECT * FROM gold.dp;
SELECT * FROM gold.fs;

WITH product_agg AS(
SELECT 
	p.product_key,
	p.name,
	p.category,
	p.sub_category,
	p.cost,
	COUNT(*) total_orders,
	COUNT(DISTINCT s.customer_id) AS total_customers,
	SUM(s.sales) total_sales,
	SUM(s.quantity) total_quantity,
	COUNT(s.customer_id) AS total_customer,
	MIN(s.order_date) AS least_order_date,
	MAX(s.order_date) AS max_order_date,
	AGE(MAX(s.order_date),MIN(s.order_date)) AS lifespan,
	CURRENT_DATE - MAX(s.order_date),
 	CASE WHEN SUM(s.sales) > 1000000 THEN 'Very High'
	WHEN SUM(s.sales) > 500000 THEN 'High'
	WHEN SUM(s.sales) > 200000 THEN 'Medium'
	WHEN SUM(s.sales) > 100000 THEN 'Average'
	WHEN SUM(s.sales) > 500000 THEN 'Low'
	ELSE 'Very Low'
	END AS product_segment
FROM gold.fs AS s
LEFT JOIN gold.dp AS p
ON s.product_key = p.product_key
GROUP BY p.name,
	p.product_key,
	p.category,
	p.sub_category,
	p.cost
)
SELECT 
	p.*,
	CASE WHEN p.total_orders = 0 THEN 0
	ELSE p.total_sales / p.total_orders 
	END AS avg_revenue_order
FROM product_agg AS p

	
	

