select * from customers
order by id asc;


------------------------------
--|	CONDITIONAL OPERATORS  |--
------------------------------
select * 
from customers
where country = 'Germany'

select * from customers
where country != 'Germany' -- '!=' == '<>'


select * from customers 
where score >= 500; -- only '>' will exclude 500

select * from customers
where score <= 500; -- only '<' will exclude 500


-------------------------------
--|    LOGICAL OPERATORS    |--
-------------------------------

select * from customers
where country = 'Germany' and score > 500; -- both the conditions should be true

select * from customers
where country = 'Germany' or score > 700; -- atleast one condition should be true

select * from customers
where not country = 'Germany'; -- will only show results who are 'not' fulfilling the
							   -- conditions 

select * from customers
where score between 500 and 800; -- the upper and lower boundry are inclusive
								 -- so it is better to use comparison operator
								 -- where score >= 100 and score <= 500 (more control)


----------------------------------
--|    MEMBERSHIP OPERATORS    |--
----------------------------------

select * from customers
where country = 'Germany' or country = 'USA'; -- using the same condition for the same 
											  -- column is not efficient

select * from customers
where country in('Germany','USA'); -- more compact and time saving way.
								   -- TIP : 'IN' should be used only when the columns are 
								   -- same.

select * from customers
where country not in('Germany','USA'); -- gives results where the country is 'not in' the
									   -- given list


------------------------------
--|    SEARCH OPERATORS    |--
------------------------------

select * from customers
order by id asc;

select * from customers
where first_name like '%r%'; -- %(0,1,many chars)

select * from customers
where first_name like '__r%'; -- _(exactly 1 char)





