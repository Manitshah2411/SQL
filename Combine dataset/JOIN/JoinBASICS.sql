select * from customers
order by id asc; -- left table
select * from orders; -- right table


-------------------
--|	INNER JOIN  |--
-------------------
-- Returns only matching data


select 
	-- sometimes there are large number of columns so choose only the one you need it
	cu.id,
	cu.first_name,
	ord.order_id,
	ord.sales
	-- if the column names are same it's better to specify the column name with the table	
from customers as cu -- the "FROM" table is always treated as 'left table' and the other
					 -- as 'right table'
				-- naming alias so the specification of columns can be easy
inner join orders as ord 
				-- the default is always used as inner join but it is a good practice to
				-- define it
on cu.id = ord.customer_id; -- It links the primary key (customers.id) to the foreign key 
							--(orders.customer_id).
						 -- The result will only include rows 
						 -- where a customer's ID exists in both tables. 
					-- HERE IF THE CUSTOMERS.ID AND ORDERS.CUSTOMER_ID MATCHES
					-- IT'LL RETURN THAT ROW ELSE WILL SKIP IT.

------------------
--|	LEFT JOIN  |--
------------------

select 
	c.id,
	c.first_name,
	o.order_id,
	o.sales
from customers as c -- alias and also the left table
left join orders as o -- alias and also the right table
on c.id = o.customer_id; -- in the left join the result will show all the rows of the left
						 -- table and shows only the intersecting data of the specified
						 -- condition of the right table
						 -- NOTE : the sequence matters while specifying the side of the table 

-------------------
--|	RIGHT JOIN  |--
-------------------
select 
	c.id,
	c.first_name,
	o.order_id,
	o.sales
from customers as c  -- alias and also the left table
right join orders as o -- alias and also the right table
on c.id = o.customer_id;  -- in the right join the result will show all the rows of the right
						 -- table and shows only the intersecting data of the specified
						 -- condition of the left table
						 -- NOTE : the sequence matters while specifying the side of the table 
 -- you can skip the right join and can only use left join by changing the sides
 -- like making the orders table the left side table and the customers table the right side
 -- table. So, without using the right join you can still do that work.
 /* from orders as o
 	left join customers as c */ -- that's it.


------------------
--|	FULL JOIN  |--
------------------

select 
	c.id,
	c.first_name,
	o.order_id,
	o.sales
from customers as c  -- alias and also the left table
full join orders as o -- alias and also the right table
on c.id = o.customer_id; -- Here, the data from both table are shown in the result
						 -- on the match of ids 


	