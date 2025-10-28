SELECT * FROM public.customers; -- Retrieves all the data from the customer table
SELECT * FROM orders; 			-- Retrieves all the data from the orders table

SELECT 
	first_name, 
	country, 
	score 			   -- no comma after the last specification
FROM public.customers; -- Retrieves specific columns from the customers's table
					   -- It also give results according to the columns are specified in the query

SELECT *
FROM customers 	  -- Retrieves the whole table
WHERE score != 0; -- WHERE filters the table give the results which fulfill are condition


SELECT *
FROM customers 
WHERE country = 'Germany';	-- Retrieves the rows only for the person who belongs to Germany
							-- In SQL equal to is written as "=" and not "==" and strings
							-- or chars are meant to be written is single quotes as 'xyz'.

SELECT * 
FROM customers
ORDER BY country ASC, -- Retrieves all the customers and sorting the result by countries in 
		 score DESC;  -- Ascending order(NOTE : whatever written after the ORDER BY is at priority)
		 			  -- That means the table will first sort according to the country and
					  -- than if same same country names found, it'll sort within the same 
					  -- country by score as mentioned in Descending order.

SELECT 
	country,
	SUM(score) AS total_score, -- Aggregating score
	COUNT(id) AS total_customers -- Couting ID(count of customers)
FROM customers 
GROUP BY country-- Retrieves the data from customers where country and SUM(score) that means
				-- sum of each country's score is done and that is grouped together 
				-- GROUP BY is only useful when the GROUPED column are not all unique.
				 
 ORDER BY total_score DESC; -- if you write this the database will be confused between the 
					  -- total score of country or individual so store the total score into
					  -- a new variable and than ORDER BY new_variable ASC/DESC


/* 4 */ SELECT 
			country, -- It gets the country name for the group.
			SUM(score) AS total_score,
			COUNT(id) AS total_customers
/* 1 */ FROM customers -- the database identifies the table it needs to work with: customers
/* 2 */ WHERE score > 400 --Next, it filters this table, keeping only the rows where the 
					--score is 0 or greater. Any rows with a negative score are discarded.
					
/* 3 */ GROUP BY country -- It then takes all the remaining rows and groups them into 
						-- separate "piles" based on the country column. All "USA" rows go 
						-- into one pile, all "Germany" rows into another, and so on.
/* 5 */ HAVING SUM(score) > 800; -- Last step it filters it where the total SUM of a country
								 -- is greater than 800
			-- NOTE : WHERE is used for individual columns
			-- 		  HAVING is used for Aggregated columns


SELECT 
	country,
	AVG(score) AS avg_score
FROM customers
WHERE score != 0
GROUP BY country
HAVING AVG(score) > 400



SELECT DISTINCT
	country
FROM customers;



SELECT 
	country,
	score
FROM customers
ORDER BY score DESC
LIMIT 3;

/*
The Correct SQL Order
SQL has a strict order for its main clauses. You must write them in this sequence:

SELECT
DISTINCT 
FROM
WHERE
GROUP BY
HAVING
ORDER BY
LIMIT

*/


