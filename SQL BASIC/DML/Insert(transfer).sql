create table person(
	id int not null, -- id int primary key not null  ___ another way of defining primary key
	person_name varchar(50) not null,
	phone_num varchar(10) not null,
	birthdate date,
	constraint pk_persons primary key (id)
	-- constraint is keyword that signals that you are definig a rule
	-- pk_persons is the name of that specific rule, it can help while errors.
	-- primary key is a keyword telling which type of constaint(rule) you want to create
	-- (id) telling to which the constraint should be applied.
);


select * from customers;
select * from person;

insert into person 
select
	id,
	first_name,
	'Unkown',
	null 
from customers; -- this query inserts all the data from customers to person
				-- the insert into clause should specify the targer table(in which data is 
				-- need to be transferred), after select clause the column name should match
				-- and is transferred in that specific sequence that the target table can 
				-- accept. If the target table doesn't have the extra columns and still needs
				-- a value you can either keep it null or give a static value.