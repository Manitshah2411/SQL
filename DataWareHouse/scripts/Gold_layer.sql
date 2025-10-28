-- 1. This is dimension of customer (Dimension is something which is descriptive and not a Fact)
-- In gold layer VIEWS are created not tables 


-- CREATE OR REPLACE VIEW  gold.dim_customer AS
CREATE TABLE IF NOT EXISTS gold.dc AS
SELECT 
	ROW_NUMBER() OVER(ORDER BY ci.cust_id) AS customer_id,
	ci.cust_id AS customer_number,
	ci.cust_key AS customer_key,
	ci.cust_firstname AS firstname,
	ci.cust_lastname AS lastname,
	ci.cust_marital_status AS marital_status,
	CASE WHEN ci.cust_gender IS NULL THEN cb.gen
	ELSE ci.cust_gender
	END AS gender,
	cb.bdate AS birthdate,
	la.cntry AS country,
	ci.cust_create_date AS created_date,
	ci.last_updated AS last_modified_date
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS cb
ON cb.cid = ci.cust_key
LEFT JOIN silver.erp_loc_a101 AS la
ON la.cid = ci.cust_key;


-- 2. Product Dimension
-- CREATE OR REPLACE VIEW gold.dim_product AS
CREATE TABLE IF NOT EXISTS gold.dp AS
SELECT 
	ROW_NUMBER() OVER(ORDER BY pi.prd_key) AS product_key,
	pi.prd_id AS product_id,
	pi.prd_key AS product_number,
	pi.cat_id AS category_id,
	pi.prd_nm AS name,
	pc.cat AS category,
	pc.subcat AS sub_category,
	pi.prd_cost AS cost,
	pi.prd_line AS product_line,
	pi.prd_start_dt AS start_date,
	pc.maintenance,
	pi.last_updated
FROM silver.crm_prd_info AS pi
LEFT JOIN silver.erp_px_cat_g1v2 AS pc
ON pc.id = pi.cat_id
WHERE prd_end_dt IS NULL;


-- 3. Sales Facts

-- CREATE OR REPLACE VIEW gold.fact_sales AS
CREATE TABLE IF NOT EXISTS gold.fs AS
SELECT 
	sd.sls_ord_num AS order_number,
	dp.product_key,
	dc.customer_id,
	sd.sls_order_dt AS order_date,
	sd.sls_ship_dt AS ship_date,
	sd.sls_due_dt AS due_date,
	sd.sls_sales AS sales,
	sd.sls_quantity AS quantity,
	sd.sls_price AS price,
	sd.last_updated 
FROM silver.crm_sales_details AS sd
LEFT JOIN gold.dim_customer AS dc
ON dc.customer_number = sd.sls_cust_id
LEFT JOIN gold.dim_product AS dp
ON dp.product_number = sd.sls_prd_key;









