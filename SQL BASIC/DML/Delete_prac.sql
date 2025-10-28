select * from customers
order by id asc;

insert into customers values (5,'Peter','USA',550);
insert into customers values (10,'Aniket','India');


update customers
set first_name = 'George'
where id = 3; 

update customers
set score = 450
where id = 1; 

update customers
set score = score + 50;

delete from customers
where id = 5;
select * from customers
where id = 10; -- writing select statement with same condition for update and delete is a 
			   -- good pratice and less risky



