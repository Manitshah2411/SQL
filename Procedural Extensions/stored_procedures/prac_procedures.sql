SELECT * FROM sales.customers


CREATE OR REPLACE PROCEDURE customer_summary(p_country VARCHAR DEFAULT 'USA')
LANGUAGE plpgsql
AS $$
BEGIN
	IF EXISTS(SELECT 1 FROM sales.customers WHERE score is NULL AND country = p_country) THEN
	UPDATE sales.customers
	SET score = 0
	WHERE score IS NULL and country = p_country;
	RAISE NOTICE 'Score updated successfully!!!';
	
	ELSE
	RAISE NOTICE 'No scores were 0 in : %',p_country;
	END IF; 
END;
$$;



CREATE OR REPLACE PROCEDURE customer_summary(p_country VARCHAR DEFAULT 'USA')
LANGUAGE plpgsql
AS $$
BEGIN
	IF EXISTS(SELECT 1 FROM sales.customers WHERE score is NULL AND country = p_country) THEN
	UPDATE sales.customers
	SET score = 0
	WHERE score IS NULL and country = p_country;
	RAISE NOTICE 'Score updated successfully!!!';
	
	ELSE
	RAISE NOTICE 'No scores were 0 in : %',p_country;
	END IF; 
END;
$$;



CREATE OR REPLACE PROCEDURE customer_summary(p_country VARCHAR DEFAULT 'USA')
LANGUAGE plpgsql
AS $$
BEGIN
	IF EXISTS(SELECT 1 FROM sales.customers WHERE score is NULL AND country = p_country) THEN
	UPDATE sales.customers
	SET score = 0
	WHERE score IS NULL and country = p_country;
	RAISE NOTICE 'Score updated successfully!!!';
	
	ELSE
	RAISE NOTICE 'No scores were 0 in : %',p_country;
	END IF; 
END;
$$;

CREATE OR REPLACE PROCEDURE demo(a INT, b INT)
LANGUAGE plpgsql
AS $$
DECLARE 
	c INT;
BEGIN
	BEGIN
	c := a/b;
	EXCEPTION
		WHEN division_by_zero THEN
		RAISE NOTICE 'Number cannot be divided by zero';
	END;
	RAISE NOTICE 'Answer : %',c;
END;
$$;

CALL demo(10,2)

