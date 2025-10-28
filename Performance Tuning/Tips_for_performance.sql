-- 1. SELECT only the necessary column for better execution plan selection 
❌✅
SELECT * FROM customer; -- ❌
SELECT first_name, last_name FROM customer; -- ✅

-- 2. Don't use DISTINCT and ORDER BY when not necessary, they are very expensive
SELECT DISTINCT firstname FROM customer ORDER BY first_name; -- ❌

-- 3. Use LIMIT x; when exploring the table for saving time
SELECT * FROM customer LIMIT 5; -- ✅

-- 4. Create an index on frequently used columns 
DROP INDEX idx_inventory_rental;
CREATE INDEX idx_inventory_rental ON rental(inventory_id) -- ✅
EXPLAIN ANALYSE SELECT * FROM rental WHERE inventory_id = 2079

-- 5. Avoiding using leading WILDCARD when having an index on that column
SELECT * FROM customer
WHERE first_name LIKE '%WEN%' -- ❌ Because using leading the planner will not use the index

SELECT * FROM customer
WHERE first_name LIKE 'WEN%' -- ✅ 

-- 6. Use IN instead of OR for the same bcoz OR is expensive
EXPLAIN ANALYSE SELECT * FROM customer WHERE customer_id = 108 OR customer_id = 109 -- ❌ 

EXPLAIN ANALYSE SELECT * FROM customer WHERE customer_id IN (108,109);

-- 7. Use Join don't join tables with WHERE clause 
CREATE INDEX idx_fk_customer_id ON rental(customer_id) 
EXPLAIN ANALYSE SELECT * FROM customer c, rental r WHERE c.customer_id = r.customer_id -- ❌

EXPLAIN ANALYSE SELECT * FROM customer c JOIN rental r ON c.customer_id = r.customer_id -- ✅

-- 8. Use UNION instead OR in the joins 
SELECT * FROM rental JOIN customer ON rental.customer_id = customer.customer_id -- OR ... ❌

SELECT * FROM rental JOIN customer ON rental.customer_id = customer.customer_id
-- UNION 
SELECT * FROM rental JOIN customer -- ON ... ✅

-- 9. Use pg_hints for big table for optimization
-- ... extension not yet added

-- 10. Use UNION ALL instead of UNION when duplicates are acceptable for better performance
SELECT customer_id FROM customer 
UNION
SELECT customer_id FROM rental -- ❌

SELECT customer_id FROM customer 
UNION ALL  
SELECT customer_id FROM rental -- ✅

-- 11. Use UNION ALL + DISTINCT when duplicates are not acceptable instead of UNION when the table is big.
SELECT DISTINCT customer_id
FROM (SELECT customer_id FROM customer 
	  UNION ALL 
	  SELECT customer_id FROM rental) -- ✅

