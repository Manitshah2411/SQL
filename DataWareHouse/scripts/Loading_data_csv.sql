-- TRUNCATE TABLE <schema_name>.table_name
-- \copy bronze.crm_sales_details FROM '/Users/manitkalpeshshah/Downloads/SQL/dwh_docs/datasets/source_crm/sales_details.csv' DELIMITER ',' CSV HEADER;

SELECT * FROM bronze.crm_cust_info;
SELECT * FROM bronze.crm_prd_info;
SELECT * FROM bronze.crm_sales_details;
SELECT * FROM bronze.erp_cust_az12;
SELECT * FROM bronze.erp_loc_a101;
SELECT * FROM bronze.erp_px_cat_g1v2;




