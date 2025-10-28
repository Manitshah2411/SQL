select * from customers
order by id asc;

select * from orders;

insert into orders values(1007,11,'2025-11-24',30)
-----------------------
--|	LEFT ANTI JOIN  |--
-----------------------
SELECT 
    c.id,
    c.first_name,
    o.order_id,
    o.sales
FROM 
    customers AS c -- Start with the 'customers' table as the left table.
LEFT JOIN 
    orders AS o -- Join it with the 'orders' table.
ON 
    c.id = o.customer_id -- Define the rule for matching customers to orders.
WHERE 
    o.customer_id IS NULL; -- The key step: filter the results to keep only the rows
                          -- from the left table (customers) that had NO match in the right table (orders).


SELECT * 
FROM 
    customers AS c
LEFT JOIN 
    orders AS o 
ON 
    c.id = o.customer_id
WHERE 
    o.customer_id IS NULL -- First condition: find customers with no orders.
    AND c.score > 800;    -- Second condition: from that group, keep only those with a score > 800.



SELECT 
    country,
    COUNT(c.id) AS total_customers -- Count the customers for each group.
FROM 
    customers AS c
LEFT JOIN 
    orders AS o 
ON 
    c.id = o.customer_id
WHERE 
    o.customer_id IS NULL -- First, find the entire set of customers with no orders.
GROUP BY 
    country -- Then, group that resulting set by country.
ORDER BY 
    COUNT(id) ASC; -- Finally, sort the groups by the customer count.


------------------------
--|	RIGHT ANTI JOIN  |--
------------------------

-- Goal: Find all orders that do not have a matching customer.

SELECT
    * -- I want to see all the information for the orders that are found.
FROM
    customers AS c
RIGHT JOIN
    orders AS o -- Start with ALL rows from the 'orders' table...
ON
    c.id = o.customer_id -- ...and try to match a customer to each one using the customer ID.
WHERE
    c.id IS NULL; -- Filter this combined list to show only the orders where a matching
                  -- customer could NOT be found (i.e., the customer side is NULL).




-- Goal: Find orphan orders that also have sales greater than 25.

SELECT
    * -- Show me all the details...
FROM
    customers AS c
RIGHT JOIN
    orders AS o -- ...for all orders, trying to match a customer to each.
ON
    c.id = o.customer_id
WHERE
    c.id IS NULL          -- But I only want to see orders that meet two criteria:
    AND o.sales > 25;     -- 1. No matching customer was found, AND...
                          -- 2. The sales amount for that order was greater than 25.





-- Goal: Calculate the total sales amount from only the orphan orders.

SELECT
    SUM(sales) AS total_sales_of_orphan_orders -- The final result I want is a single number: the sum of the 'sales' column.
FROM
    customers AS c
RIGHT JOIN
    orders AS o -- To get this, first, take all orders and try to find their matching customers.
ON
    c.id = o.customer_id
WHERE
    c.id IS NULL; -- From that combined list, throw away all the orders that did find a customer,
                  -- leaving only the 'orphan' orders for the SUM() function to calculate.



-----------------------
--|	FULL ANTI JOIN  |--
-----------------------


select *
from customers as c
full join orders as o
on c.id = o.customer_id
where c.id is null or o.customer_id is null;


