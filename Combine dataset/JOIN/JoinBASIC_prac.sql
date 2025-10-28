select * from customers
order by id asc;

select * from orders;


-------------------
--|	INNER JOIN  |--
-------------------

select 
	c.first_name,
	c.country,
	o.order_id,
	o.sales
from customers as c
inner join orders as o
on c.id = o.customer_id


select 
	c.first_name,
	c.country,
	o.order_id,
	o.sales
from customers as c
inner join orders as o
on c.id = o.customer_id
where c.country = 'India'; 



------------------
--|	LEFT JOIN  |--
------------------

select 
	c.id,
	c.first_name,
	o.order_id,
	o.sales,
	o.customer_id
from customers as c
left join orders as o
on c.id = o.customer_id;


-- LEFT JOIN DOING THE WORK OF INNER JOIN

select * from customers as c
left join orders as o
on c.id = o.customer_id
where o.customer_id is not null;  


------------------
--|	RIGHT JOIN  |--
------------------

select 
	c.id,
	c.first_name,
	o.order_id,
	o.sales
from customers as c
right join orders as o
on c.id = o.customer_id;

------------------
--|	FULL JOIN  |--
------------------

select 
	c.id,
	c.first_name,
	o.order_id,
	o.sales
from customers as c
FULL join orders as o
on c.id = o.customer_id;


