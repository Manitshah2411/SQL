-- CTE : Common Table Expression --
-- It is virtual table which can used multiple times in the main query unlike subquery. --
-- CTE is top to bottom flow, whereas SUBQUERY use bottom to top flow
-- CTE is stored in the cache so the execution is faster.
-- Types of CTEs : Recursive CTE and Non-Recursive CTE(Standalone and Nested)

-- Why to use CTE?
-- CTE help tackle the problem of the redundancy which was not possible while using SUBQUERY
-- CTE increases readability, reusability(Write Once and reuse it) and modularity.


---------------------------------------------
-- Non-Recursive : Standalone & NESTED CTE --
---------------------------------------------


-- Step 1 : Find the total sales Per customer
WITH CTE_total_sales AS
(SELECT 
	customerid,
	SUM(sales) AS total_sales
FROM sales.orders
GROUP BY customerid) -- A basic syntax for defining the CTE

-- Step 2 : Find the last orderdate for each customer
, CTE_last_orderdate AS
(
SELECT
	customerid,
	MAX(orderdate) AS last_orderdate
FROM sales.orders
GROUP BY customerid
)

-- Step 3 : Rank the customer based on their total sales per customers
, CTE_rank_customers AS -- This is a nested CTE bcoz it uses the table from another CTE
(
SELECT 
	cto.total_sales,
	cto.customerid,
	DENSE_RANK() OVER(ORDER BY cto.total_sales DESC) AS ranks
FROM CTE_total_sales AS cto
)

-- Step 4 : Segment customers based on their total sales
, CTE_segmented_total_sales AS  -- This is a nested CTE 
(
SELECT
	customerid,
	CASE 
		WHEN total_sales >= 100 THEN 'High'
		WHEN total_sales >= 60 THEN 'Medium'
		ELSE 'Low'
	END AS segment
FROM CTE_total_sales
)

-- Main Query
SELECT 
	c.*,
	cts.total_sales, -- CTE column
	clo.last_orderdate,
	crc.ranks,
	csts.segment
FROM sales.customers AS c

LEFT JOIN CTE_total_sales AS cts -- Used the CTE table for the JOIN
ON cts.customerid = c.customerid

LEFT JOIN CTE_last_orderdate AS clo
ON clo.customerid = c.customerid

LEFT JOIN CTE_rank_customers AS crc
ON  crc.customerid = c.customerid

LEFT JOIN CTE_segmented_total_sales AS csts
ON  csts.customerid = c.customerid;



-------------------
-- Recursive CTE --
-------------------

-- WITH cte_name AS (Anchor Query)
-- (
-- SELECT...
-- FROM...
-- WHERE...

-- UNION ALL

-- SELECT...
-- FROM...
-- WHERE...
-- )

WITH RECURSIVE sequence_ AS
(
SELECT 
	1 AS number
	
UNION ALL

SELECT 
	number + 1
FROM sequence_
WHERE number < 1000 -- Break statement where the recursion ends
)
SELECT * FROM sequence_;



-- Q : Show the employee hierarchy by displaying each employee's level within the organisation

WITH RECURSIVE anchor AS
(
SELECT 
	employeeid AS empid,
	firstname,
	managerid,
	1 AS level_
FROM sales.employees
WHERE managerid IS NULL 
UNION ALL -- From here the recursive set is executed until the condition is false
SELECT 
	e.employeeid AS empid, -- If the condition is true than the next iteration checks the 
	e.firstname,
	e.managerid,
	level_ + 1
FROM sales.employees AS e
INNER JOIN anchor AS an -- The join is bound to the current working set, not the entire result that means the most 
ON e.managerid = an.empid -- recent iteration will be checked and joined ON the condition
)
SELECT 
	*
FROM anchor;

-------------------------------------
---- Execution flow of the query ----
-------------------------------------

-- Anchor run (once)
-- Lines 04–10 produce W0 = {(1, Frank, NULL, level=1)}
-- R = W0
-- Iteration 1 (recursive)
-- Run lines 13–20 with an in W0 (an.empid = {1})
-- Find e.managerid = 1 → produce N1 = { (2,Bob,1,2), (3,Mary,1,2) }
-- Append N1 to R, set W = N1
-- Iteration 2
-- Run lines 13–20 with an.empid = {2,3}
-- Find e.managerid IN (2,3) → produce N2 = { (4,Dan,2,3), (5,Eve,2,3), (6,Joe,3,3) }
-- Append N2 to R, set W = N2
-- Iteration 3
-- Run lines 13–20 with an.empid = {4,5,6}
-- No employees have managerid in {4,5,6} → N3 = {} → W empty → stop.
-- Final SELECT
-- Lines 22–23 read R which now contains rows for empids {1..6}.

---------------------
-- Execution cycle --
---------------------

-- Run anchor member (the WHERE managerid IS NULL part).
-- Put those rows into both:
-- Result set (permanent data result)
-- Working set (temporary delta). working set is like a temporary in-memory buffer (delta table) maintained behind the scenes.

-- While Working set is not empty:
-- Take the rows in it.
-- Run the recursive member (the JOIN).
-- Produce new rows → append them to:
-- Result set (grows each time)
-- New Working set (replaces the old one).
-- Stop when the Working set becomes empty.






