-- Question 1: Select All Data
SELECT * FROM customers;

-- Logic: The `SELECT *` command retrieves all columns from the specified table.
-- The semicolon `;` at the end marks the completion of the command.


-- Question 2: Find German Customers
SELECT 
    first_name, 
    score
FROM customers
WHERE country = 'Germany';

-- Logic: This query selects specific columns (`first_name`, `score`).
-- The `WHERE` clause filters the rows, keeping only those where the `country` column
-- has the exact text value 'Germany'. Text values must be in single quotes.


-- Question 3: Find High Scorers
SELECT 
    first_name, 
    country, 
    score
FROM customers
WHERE score > 600;

-- Logic: The `WHERE` clause can also use numerical operators. This query filters
-- for rows where the `score` is greater than 600.


-- Question 4: Sort by Name
SELECT 
    id, 
    first_name, 
    country
FROM customers
ORDER BY first_name ASC;

-- Logic: The `ORDER BY` clause sorts the final result set.
-- `ASC` specifies ascending order (A to Z). This is the default, so you could also
-- write `ORDER BY first_name;` for the same result.


-- Question 5: Lowest Score
SELECT *
FROM customers
ORDER BY score ASC
LIMIT 1;

-- Logic: To find the minimum or maximum, you first sort the entire table
-- by that value (`ORDER BY score ASC` for lowest to highest) and then use `LIMIT 1`
-- to retrieve only the very first row from that sorted list.


-- Question 6: Count Customers per Country
SELECT 
    country, 
    COUNT(id) AS total_customers
FROM customers
GROUP BY country
ORDER BY COUNT(id) DESC;

-- Logic: This is an aggregate query.
-- `GROUP BY country` creates a summary row for each unique country.
-- `COUNT(id)` then counts how many `id`s are in each of those country groups.
-- `AS total_customers` gives the result of the COUNT() function a clean column name.
-- `ORDER BY COUNT(id) DESC` sorts the final groups to show the most populated countries first.


-- Question 7: Total Score per Country
SELECT 
    country, 
    SUM(score) AS total_score
FROM customers
GROUP BY country
ORDER BY SUM(score) DESC;

-- Logic: Similar to COUNT, `SUM(score)` is an aggregate function that calculates
-- the total of the `score` column for each group created by `GROUP BY country`.


-- Question 8: Average Score per Country
SELECT 
    country, 
    AVG(score) AS avg_score
FROM customers
GROUP BY country
ORDER BY AVG(score) DESC;

-- Logic: `AVG(score)` is an aggregate function that calculates the average of the
-- `score` column for each group.


-- Question 9: Find "High-Scoring" Countries
SELECT 
    country, 
    SUM(score) AS total_score
FROM customers
WHERE score != 0 -- Optional: first, filter out individual rows if needed.
GROUP BY country
HAVING SUM(score) > 800 -- After grouping, filter the *groups* based on an aggregate condition.
ORDER BY SUM(score) DESC;

-- Logic: `HAVING` is like a `WHERE` clause, but it operates on the results of
-- aggregate functions *after* the `GROUP BY` has been performed.



-- Question 10: Countries with Multiple Customers
SELECT 
    country, 
    COUNT(id) AS total_customers
FROM customers
GROUP BY country
HAVING COUNT(id) > 1 -- Filters the groups to keep only those with a customer count greater than 1.
ORDER BY COUNT(id) ASC;

-- Logic: Another example of `HAVING`. It allows you to filter your results based on
-- the calculated aggregate values.