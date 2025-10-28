-----------------------------
--|	SINGLE ROW FUNCTIONS  |--
-----------------------------

----NUMBER FUNCTIONS----

-- 1. ROUND
SELECT
	3.14159265359 as PI,
	ROUND(3.14159265359,3)  

-- 2. ABS

SELECT
	-10,
	ABS(-10), -- returns only positive integers even if they are negative.
	ABS(10) 