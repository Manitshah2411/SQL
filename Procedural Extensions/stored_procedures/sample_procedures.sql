-- SYNTAX FOR stored procedure
/*CREATE OR REPLACE PROCEDURE get_report(g_name VARCHAR, g_score INT)
LANGUAGE plpgsql
AS $$
DECLARE 
	variables
BEGIN
	body for all logics
END;
$$ */

CREATE OR REPLACE PROCEDURE get_customer_report()
LANGUAGE plpgsql
AS $$
DECLARE 
	v_total_customers int;
	v_avg_score int;
BEGIN
	SELECT 
		COUNT(*) total_customers,
		AVG(score) avg_score
	INTO v_total_customers, v_avg_score
	FROM sales.customers
	WHERE country = 'USA';
	RAISE NOTICE 'Total customer : %, Avg_score : %', v_total_customers,v_avg_score;
END;
$$

call get_customer_report() -- It does not return any rows or columns it is just used for updated, deleting or altering tables