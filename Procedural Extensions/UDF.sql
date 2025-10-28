CREATE OR REPLACE FUNCTION mid(a VARCHAR,b INT,c INT)
RETURNS VARCHAR
LANGUAGE plpgsql
AS $$
BEGIN
	return substring(a, b, c);
END;
$$;

SELECT * FROM mid('software',4,6)
SELECT * FROM substring('Manit Shah',3,6)

----

CREATE OR REPLACE FUNCTION concat_full_name(firstname VARCHAR,lastname VARCHAR)
RETURNS VARCHAR
LANGUAGE plpgsql
AS $$
BEGIN
	IF firstname IS NULL AND lastname IS NULL THEN
		RETURN NULL;
	ELSIF firstname IS NULL AND lastname IS NOT NULL THEN
		RETURN lastname;
	ELSIF firstname IS NOT NULL AND lastname IS NULL THEN
		RETURN firstname;
	ELSE 
		RETURN CONCAT(firstname,' ',lastname);
	END IF;
END;
$$;
SELECT concat_full_name('Manit','Shah')

----
DROP FUNCTION IF EXISTS out_para(inout c INT,OUT b INT, IN a INT);
CREATE OR REPLACE FUNCTION out_para(inout c INT,OUT b INT, IN a INT)
LANGUAGE plpgsql
AS $$
BEGIN
	a := a + a; -- IN(Default) is used just for taking inputs from the user
	c := c + a; -- The inout parameters are the one who are taken as an input and can be returned without actually
	-- returing
	b := c + a; -- The OUT parameter is not taken as an input but just for returning, it is declared as a
	-- variable internally.
END;
$$;

SELECT * FROM out_para(1,1)



-------------------------------------
-- PRACTICE USER_DEFINED FUNCTIONS --
-------------------------------------

-- Write a function square(num INT) that returns the square of a number.

CREATE OR REPLACE FUNCTION square(INOUT num INT)
LANGUAGE plpgsql
AS $$
BEGIN
	num := num * num;
END;
$$;

SELECT * FROM square(10)

--    * Write a function calculate(a INT, INOUT b INT, OUT sum INT) where:
--        * a is input
--        * b is incremented by a (INOUT)
--        * sum returns a + b (OUT)

CREATE OR REPLACE FUNCTION calculate(a INT, INOUT b INT, OUT sum INT)
LANGUAGE plpgsql
AS $$
BEGIN
	b := b + a;
	sum := a + b;
END;
$$;

SELECT * FROM calculate(5, 8);

-- * Write a function classify_number(num INT) that returns:
--        * 'Positive', 'Negative', or 'Zero'
DROP FUNCTION IF EXISTS classify_number(num INT);
CREATE OR REPLACE FUNCTION classify_number(num INT)
RETURNS VARCHAR
LANGUAGE plpgsql
AS $$
BEGIN
	IF num > 0 THEN
	RETURN 'Positive';
	ELSIF num < 0 THEN
	RETURN 'Negative';
	ELSE 
		RETURN 'Zero';
	END IF;
END;
$$;

SELECT * FROM classify_number(10)


-- * Write a function sum_even(arr INT[]) that returns the sum of all even numbers in the array.
DROP FUNCTION IF EXISTS sum_even(arr FLOAT[]);
CREATE OR REPLACE FUNCTION sum_even(arr FLOAT[])
RETURNS TABLE(total_sum NUMERIC, con INT, mean NUMERIC)
LANGUAGE plpgsql
AS $$ 
DECLARE 
	var FLOAT;
BEGIN
	total_sum := 0;
	con := 0;
	FOREACH var IN array arr LOOP
		IF var % 2 = 0 THEN
			total_sum := total_sum + var;
			con := con + 1;
		END IF;
	END LOOP;
	mean := total_sum / con;
	return NEXT;
END;
$$;

SELECT * FROM sum_even(ARRAY[10,20,30,40,50.2])


-- * Write a function get_customers_by_country(country TEXT) that returns a table of customer names and IDs
--   for the given country.

DROP FUNCTION IF EXISTS get_customer_by_country(p_country TEXT);
CREATE OR REPLACE FUNCTION get_customer_by_country(p_country TEXT)
RETURNS TABLE(customerid INT, customer_name TEXT)
LANGUAGE plpgsql
AS $$
BEGIN
	RETURN QUERY
	SELECT 
		c.customerid,
		CONCAT(c.firstname,' ',c.lastname) AS customer_name
	FROM sales.customers AS c
	WHERE LOWER(c.country) = LOWER(p_country);
END;
$$;

SELECT * FROM get_customer_by_country('USA'::TEXT);

-- * Write a function safe_divide(a INT, b INT) that returns a / b but raises a NOTICE and returns NULL 
--	 if division by zero occurs.

CREATE OR REPLACE FUNCTION safe_divide(a INT, b INT, OUT c INT)
RETURNS INT
LANGUAGE plpgsql
AS $$
BEGIN
	BEGIN 
		c := a/b;
		EXCEPTION
		WHEN division_by_zero THEN 
		RAISE NOTICE 'Cant divide the number by zero';
		c := 0;
	END;
END;
$$;

SELECT * FROM safe_divide(10,0);



