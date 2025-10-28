-- Table 1.
DROP TABLE IF EXISTS bronze.crm_cust_info;
CREATE TABLE IF NOT EXISTS bronze.crm_cust_info
(
	cust_id INT,
	cust_key VARCHAR(30),
	cust_firstname VARCHAR(30),
	cust_lastname VARCHAR(30),
	cust_marital_status VARCHAR(20),
	
	cust_gender CHAR(1) CHECK
	(cust_gender IN ('M','F','O')),
	
	cust_create_date DATE
);

DROP INDEX IF EXISTS bronze.idx_cust_key;
CREATE INDEX IF NOT EXISTS idx_cust_key 
ON bronze.crm_cust_info(cust_key);

-- Table 2.
DROP TABLE IF EXISTS bronze.crm_prd_info;
CREATE TABLE IF NOT EXISTS bronze.crm_prd_info
(
	prd_id INT,
	prd_key VARCHAR(40),
	prd_nm VARCHAR(60),
	prd_cost INT,
	prd_line CHAR(1),
	prd_start_dt DATE,
	prd_end_dt DATE
);

CREATE INDEX IF NOT EXISTS idx_prd_key 
ON bronze.crm_prd_info(prd_key);

-- Table 3.

DROP TABLE IF EXISTS bronze.crm_sales_details;
CREATE TABLE IF NOT EXISTS bronze.crm_sales_details
(
	sls_ord_num VARCHAR(20),
	sls_prd_key	VARCHAR(20),
	sls_cust_id	INT,
	sls_order_dt INT,
	sls_ship_dt	INT,
	sls_due_dt INT,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT
);

-- Table 4.
DROP TABLE IF EXISTS bronze.erp_cust_az12;
CREATE TABLE IF NOT EXISTS bronze.erp_cust_az12
(
	cid VARCHAR(30),
	bdate DATE,
	gen VARCHAR(20)
);

-- Table 5.
DROP TABLE IF EXISTS bronze.erp_loc_a101;
CREATE TABLE IF NOT EXISTS bronze.erp_loc_a101
(
	cid VARCHAR(30),
	cntry VARCHAR(30) 
);

-- Table 6.
DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2;
CREATE TABLE IF NOT EXISTS bronze.erp_px_cat_g1v2
(
	id VARCHAR(10),
	cat VARCHAR(30),
	subcat VARCHAR(30),
	maintenance VARCHAR(20)
);


