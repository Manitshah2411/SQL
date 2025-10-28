select * from sales.customers; -- specifying the schema. So that we can get the output we want
select * from sales.employees;
select * from sales.orders;
select * from sales.products;
select * from sales.productsarchive;




-- Goal: Create a comprehensive report showing details for every order,
-- including the full name of the customer who placed it and the employee who sold it.

SELECT 
    o.orderid,
    o.sales,
    o.quantity,

    -- Use CONCAT_WS (Concatenate With Separator) to safely combine names.
    -- The first argument is the separator (' '). It will intelligently skip any NULL values
    -- (like a missing middle name), preventing the whole name from becoming NULL.
    CONCAT_WS(' ', c.firstname, c.lastname) AS CustomerFullName,

    p.product,
    p.price,

    CONCAT_WS(' ', e.firstname, e.lastname) AS EmployeeFullName

-- Start with the 'orders' table as the central point of our query, aliased as 'o'.
FROM 
    sales.orders AS o

-- Link the orders to the customers.
-- We use a LEFT JOIN to ensure that even if an order has an invalid customerid,
-- the order record will still be included in our result.
LEFT JOIN 
    sales.customers AS c ON o.customerid = c.customerid

-- Link the orders to the products that were sold.
LEFT JOIN 
    sales.products AS p ON o.productid = p.productid

-- Link the orders to the employees who made the sale.
LEFT JOIN 
    sales.employees AS e ON o.salespersonid = e.employeeid

-- Finally, sort the entire result set by the order ID to present the data in a logical sequence.
ORDER BY 
    o.orderid ASC; 