select * from sales.customers;
select * from sales.employees;


insert into sales.employees values(6,'Manit','Adams','Sales','2005-11-24','M',90000,4)
 
------------------
--|	SET UNION  |--
------------------

SELECT 
	CONCAT_WS(' ',c.firstname,c.lastname) as FullName -- The column name alias should be defined in 1st query. 
	-- CONCAT should be done with the same datatype
FROM sales.customers as c
	
UNION -- NOTE : THE UNION ONLY RETURNS DISTINCT ROWS. LIKE HAVING COMMAN FIRST NAME 
	  -- 1. While doing UNION the number of columns must be same.
	  -- 2. The datatype of the columns must be same
	  -- 3. The ORDER BY command can only be used once and that is at the last of the whole query
	  -- 4. The order of the columns must be the same in each query. Like the first name in 1st query
	  -- So in the 2nd query the column should be first name too.
	  -- 5. Column name alias should be defined in the 1st query.
	  -- 6. Map the columns correct the mismatch of 1st query First name and the 2nd query last name
	  -- this will generate false results.
SELECT
	CONCAT_WS(' ',e.firstname,e.lastname) as FullName
FROM sales.employees as e

ORDER BY Fullname ASC



---------------------
--|	SET UNION ALL |--
---------------------

SELECT
	c.firstname,
	c.lastname
FROM sales.customers AS c

UNION ALL -- The only difference between Union and Union All is Union all doesn't remove the duplicates.
		  -- Rest every rule is same as UNION. 

SELECT
	e.firstname,
	e.lastname
FROM sales.employees AS e


------------------
--|	SET EXCEPT |--
------------------

-- Goal: To get a list of all customer names that are NOT also employee names.
-- This is useful for finding people who are exclusively customers.

-- Start by selecting the full names from the first set (customers).
-- Think of this as creating "List A".
SELECT
    c.firstname,
    c.lastname
FROM
    sales.customers AS c

-- Use the EXCEPT operator to subtract the second set from the first.
-- In simple terms, this means "take everything from List A, and then
-- remove anything that also appears in List B."
EXCEPT

-- Now, select the full names from the second set (employees).
-- This creates "List B".
SELECT
    e.firstname,
    e.lastname
FROM
    sales.employees AS e;

-- The final result will be a list of first and last names that appear in the
-- `customers` table but do NOT appear in the `employees` table.
-- Any name that exists in both tables will be excluded. For example here the customers who are
-- not employees are shown in the output, which means the right table data is not shown at all.




---------------------
--|	SET INTERSECT |--
---------------------


SELECT 
	c.firstname,
	c.lastname
FROM sales.customers AS c

INTERSECT -- The INTERSECT operator will return the rows which are common in the both the tables
		  -- So, here it'll return the customers who are in employees list at the same time.

SELECT 
	e.firstname,
	e.lastname
FROM sales.employees AS e

