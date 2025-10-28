
-- 1. Customer Information table loaded into silver from bronze after transformation

TRUNCATE TABLE silver.crm_cust_info;
INSERT INTO silver.crm_cust_info(
-- Checking Unwanted spaces --
SELECT
	cust_id,
	cust_key,
	TRIM(cust_firstname) AS cust_firstname,
	TRIM(cust_lastname) AS cust_lastname,
	CASE WHEN cust_marital_status = 'S' THEN 'Single'
	WHEN cust_marital_status = 'M' THEN 'Married'
	ELSE NULL
	END as cust_marital_status,
	CASE WHEN TRIM(cust_gender) = 'F' THEN 'Female'
	WHEN TRIM(cust_gender) = 'M' THEN 'Male'
	WHEN TRIM(cust_gender) = 'O' THEN 'Others'
	ELSE NULL
	END AS cust_gender,
	cust_create_date
FROM(

-- Checking duplicate primary key --
SELECT 
cust_id,
cust_key,
cust_firstname,
cust_lastname,
cust_marital_status,
cust_gender,
cust_create_date
FROM(
SELECT 
*,
ROW_NUMBER() OVER(PARTITION BY cust_id ORDER BY cust_create_date DESC) AS flag_
FROM bronze.crm_cust_info)t
WHERE flag_ = 1 AND cust_id IS NOT NULL

UNION ALL

SELECT * FROM bronze.crm_cust_info WHERE cust_id IS NULL -- Keeping the nulls by UNION ALL
ORDER BY cust_id)
-- WHERE cust_firstname != TRIM(cust_firstname) : Condition to find which row has spaces
);



-- 2. Product Information table loaded into the silver

TRUNCATE TABLE silver.crm_prd_info;
INSERT INTO silver.crm_prd_info(
SELECT 
	prd_id,
	SUBSTRING(prd_key FROM 7) AS prd_key,
	REPLACE(SUBSTRING(prd_key,1,5), '-', '_') AS cat_id,
	prd_nm,
	COALESCE(prd_cost,0) AS prd_cost,
	prd_line,
	prd_start_dt,
	(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) - interval '1 day')::DATE AS prd_end_dt
FROM bronze.crm_prd_info
);


-- 3. Sales Details

TRUNCATE TABLE silver.crm_sales_details; 
INSERT INTO silver.crm_sales_details
SELECT 
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	CASE WHEN (sls_order_dt::TEXT)::INT = 0 OR LENGTH(sls_order_dt::TEXT) < 8 THEN NULL::DATE
		ELSE (sls_order_dt::TEXT)::DATE
	END AS sls_order_dt,
	CASE WHEN (sls_ship_dt::TEXT)::INT = 0 OR LENGTH(sls_ship_dt::TEXT) < 8 THEN NULL::DATE
		ELSE TO_DATE(sls_ship_dt::TEXT,'YYYYMMDD') 
	END AS sls_ship_dt,
	CASE WHEN (sls_due_dt::TEXT)::INT = 0 OR LENGTH(sls_due_dt::TEXT) < 8 THEN NULL::DATE
		ELSE TO_DATE(sls_due_dt::TEXT,'YYYYMMDD')
	END AS sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
FROM bronze.crm_sales_details
WHERE sls_sales > 0 AND sls_quantity > 0  AND sls_price > 0
	AND sls_sales IS NOT NULL AND sls_quantity IS NOT NULL  AND sls_price IS NOT NULL
	AND sls_sales = (sls_quantity * sls_price)
ORDER BY sls_sales,sls_quantity,sls_price;


-- 4. Customer Birthdate
TRUNCATE TABLE silver.erp_cust_az12;
INSERT INTO silver.erp_cust_az12
SELECT 
	CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid FROM 4)
	ELSE cid
	END AS cid,
	CASE WHEN bdate > CURRENT_DATE THEN NULL
	ELSE bdate 
	END AS bdate,
	CASE WHEN gen IS NULL THEN NULL
	WHEN TRIM(gen) = 'M' THEN 'Male'
	WHEN TRIM(gen) = 'F' THEN 'Female'
	WHEN TRIM(gen) = '' THEN NULL
	ELSE TRIM(gen)
	END AS gen
FROM bronze.erp_cust_az12;


-- 5. Customer's Location

TRUNCATE TABLE silver.erp_loc_a101;
INSERT INTO silver.erp_loc_a101
WITH cleaned_cid AS
(
	SELECT 
		SUBSTRING(cid,1,2) AS p1,
		SUBSTRING(cid FROM 4) AS p2,
		cntry
	FROM bronze.erp_loc_a101
)
SELECT 
	CONCAT(p1,'',p2) AS cid,
	CASE 
		WHEN TRIM(cntry) IN ('US','USA','United States') THEN 'United States'
		WHEN TRIM(cntry) IN ('DE','Germany') THEN 'Germany'
		WHEN TRIM(cntry) IS NULL OR TRIM(cntry) = '' THEN NULL
		ELSE cntry
	END
FROM cleaned_cid;

	
-- 6. Products Category
TRUNCATE TABLE silver.erp_px_cat_g1v2;
INSERT INTO silver.erp_px_cat_g1v2
SELECT *  FROM bronze.erp_px_cat_g1v2