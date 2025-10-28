select * from customers
order by id asc;
------------------------------
--|	CONDITIONAL OPERATORS  |--
------------------------------

select * from customers
where country = 'India' and score > 800;

select * from customers
where country = 'UK' or country = 'USA';


select * from customers
where country != 'Germany';

select * from customers
where country = 'Germany' and score = 550;


------------------------
--|	RANGE OPERATORS  |--
------------------------

select * from customers
where score between 700 and 850;


-----------------------------
--|	MEMBERSHIP OPERATORS  |--
-----------------------------

select * from customers
where  country in ('Japan','Argentina','UK');


------------------------------
--|    SEARCH OPERATORS    |--
------------------------------

select * from customers
where first_name like 'M%';

select * from customers
where first_name like '%a%';

select * from customers
where first_name like '_____'; 