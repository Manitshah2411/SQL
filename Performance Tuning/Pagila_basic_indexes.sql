-------------------------
-- 1. Basic B-Tree Index
-- Find all rentals made by a specific customer_id = 42. Create an index that makes this fast.
-------------------------

EXPLAIN ANALYSE SELECT * FROM rental
WHERE customer_id = 42;

/*
"Seq Scan on rental  (cost=0.00..350.55 rows=25 width=40) (actual time=0.161..3.262 rows=30 loops=1)"
"Filter: (customer_id = 42)"
"Rows Removed by Filter: 16014"
"Planning Time: 0.190 ms"
"Execution Time: 3.296 ms"
*/

-- NON-clustered B-Tree Index
DROP INDEX idx_rental_customer_id
CREATE INDEX idx_rental_customer_id -- Create this normal index on PK or any unique columns when the columns
									-- are not fixed
ON rental (customer_id);

/*
"Bitmap Heap Scan on rental  (cost=4.48..71.99 rows=25 width=40) (actual time=0.078..0.147 rows=30 loops=1)"
"  Recheck Cond: (customer_id = 42)"
"  Heap Blocks: exact=27"
"  ->  Bitmap Index Scan on idx_rental_customer_id  (cost=0.00..4.47 rows=25 width=0) (actual time=0.057..0.057 rows=30 loops=1)"
"        Index Cond: (customer_id = 42)"
"Planning Time: 0.713 ms"
*/

-- NON-clustered covering Index
DROP INDEX idx_rental_covering;
CREATE INDEX idx_rental_covering -- Create this COVERING INDEX when the columns you are using are fixed and dont
								 -- change while analysis. But the trade offs are they consume more storage
ON rental (customer_id, rental_id, rental_date);

EXPLAIN ANALYSE SELECT customer_id, rental_id, rental_date FROM rental
WHERE customer_id = 42;

-- 2. Composite Index
-- List all customers with first_name = 'MARY' AND last_name = 'SMITH'. 
-- Try with separate indexes vs. a combined one.

DROP INDEX idx_customer_first_last_name
CREATE INDEX idx_customer_first_last_name -- In this index when the conditions are on multiple columns and 
										  -- repeatedly done on the 
ON customer (first_name, last_name);

EXPLAIN (ANALYSE,BUFFERS) SELECT * FROM customer WHERE first_name = 'MARY' AND last_name = 'SMITH';

------------------
-- 3. Unique Index
-- Prevent duplicate customer emails in the customer table. Add a unique index and test inserting a duplicate.
------------------
DROP INDEX idx_customer_email;
CREATE UNIQUE INDEX idx_customer_email -- The UNIQUE INDEX enforces unique data while inserting and also helps
									   -- while retrieving the data faster as the 
ON customer (email);

/*
"Seq Scan on customer  (cost=0.00..80.49 rows=1 width=83) (actual time=0.022..0.142 rows=1 loops=1)"
"Filter: (email = 'TRACY.COLE@sakilacustomer.org'::text)"
"Rows Removed by Filter: 598"
"Planning Time: 0.368 ms"
"Execution Time: 0.161 ms"
*/

EXPLAIN ANALYSE SELECT * FROM customer 
WHERE email = 'TRACY.COLE@sakilacustomer.org';

/*
"Index Scan using idx_customer_email on customer  (cost=0.28..8.29 rows=1 width=83) (actual time=0.019..0.019 rows=1 loops=1)"
"  Index Cond: (email = 'TRACY.COLE@sakilacustomer.org'::text)"
"Planning Time: 0.178 ms"
"Execution Time: 0.031 ms"
*/

/*
----------------
4. Partial Index
Get all active customers (active = true) in Canada. Create a partial index (WHERE active = true).
----------------
*/

SELECT * FROM customer;
SELECT * FROM address LIMIT 5;
SELECT * FROM country LIMIT 5;
SELECT * FROM city LIMIT 5;

DROP INDEX idx_partial_customer_active;
CREATE INDEX idx_partial_customer_active -- Partial Index is used when the index is needed to be created on the
										 -- basis of certain conditions.
ON customer(address_id)
WHERE active = 1;

EXPLAIN ANALYSE
SELECT 
	c.customer_id,
	CONCAT(c.first_name,' ',c.last_name) AS fullname,
	c.active
FROM customer AS c
WHERE active = 1 AND c.address_id IN(
	SELECT a.address_id 
	FROM address AS a
	JOIN city AS ci
	ON ci.city_id = a.city_id
	JOIN country AS co
	ON co.country_id = ci.city_id
	WHERE co.country = 'Canada'
)

