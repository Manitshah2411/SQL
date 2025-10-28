select * from sales.customers;


-----------------------------
--|	SINGLE ROW FUNCTIONS  |--
-----------------------------

----STRING FUNCTIONS----

-- 1. CONCAT

SELECT 
	CONCAT(firstname, ' ', lastname) as fullname,
	CONCAT_WS(' ',firstname,lastname) as namefull -- two ways of using concat
from sales.customers;


-- 2. UPPER & LOWER

SELECT
	LOWER(firstname), -- convert every char in lowercase
	UPPER(lastname)  -- convert every char in uppercase
FROM sales.customers;


-- 3. TRIM
SELECT
	firstname
FROM sales.customers
WHERE firstname != TRIM(firstname); -- Returns value having any extra spaces

SELECT
	TRIM(firstname)
FROM sales.customers;


-- 4. REPLACE

SELECT
	'8799-30-1204',
	REPLACE('8799-30-1204','-',''); -- REPLACE('Datayouwanttomanipulate','old_value','new_value')


-- 5. LENGTH

SELECT 
	firstname,
	LENGTH(TRIM(firstname)) as length_first_name,
	lastname,
	LENGTH(TRIM(lastname)) as length_last_name,
	score,
	LENGTH(score::TEXT) as length_score -- LENGTH() just counts the words not integers so, typecasting needs to be done
FROM sales.customers;


-- 6. LEFT & RIGHT

SELECT
	CASE -- considered it as IF-ELSE statement.
		WHEN customerid = 1 THEN LEFT(firstname,4) -- returns the number of chars specified from the LEFT
		ELSE firstname
	END AS mod_firstname, -- alias for the modified column

	RIGHT(lastname,3) -- returns the number of chars specified from the RIGHT 
FROM sales.customers


-- 7. SUBSTRING

SELECT
	SUBSTRING(TRIM(firstname),2,LENGTH(TRIM(firstname))-2+1) -- OR JUST LENTGH(firstname )
FROM sales.customers;