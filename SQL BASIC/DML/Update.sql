-- Active: 1755420976047@@127.0.0.1@5432@postgres
select * from person
order by id asc;

select * from customers
order by id asc;


update person
set phone_num = '8799591310',
	birthdate = '2005-8-29'
where person_name = 'Kashvi'; -- very important clause. if the condition is not specified
							 -- the db will update the whole column which is very risky

update person
set birthdate = '2000-1-1' -- this command will update the birthdate of every person
						   -- which is not at all good and is very risky

select * from person
where person_name = 'Manit';


update person
set birthdate = '1999-12-31'
where birthdate = '2000-1-1'; -- in the update clause it'll update all the values that 
							  -- fulfills the conditions. So, it's better to specify the id
							  -- if you want to update the specific content. 


select *
from customers
where score is null; -- in null values we can't use '=' or '!=' we have to 'is' and 'is not'

update customers
set score = null
where id = 5; -- you can also update any content to null with specifying the where condition