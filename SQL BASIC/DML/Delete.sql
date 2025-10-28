select * from person
order by id asc;

delete from person
where id > 8; -- delete command is very risky. Test before executing. Also always give
			 -- condition before executing the command
select * from person -- testing before using delete command
where id > 8;

create table person1(
	id int not null, -- id int primary key not null  ___ another way of defining primary key
	person_name varchar(50) not null,
	phone_num varchar(10) not null,
	birthdate date,
	constraint pk_person1 primary key (id)
	-- constraint is keyword that signals that you are definig a rule
	-- pk_persons is the name of that specific rule, it can help while errors.
	-- primary key is a keyword telling which type of constaint(rule) you want to create
	-- (id) telling to which the constraint should be applied.
);

insert into person1
select 
	id,
	person_name,
	phone_num,
	birthdate
from person; -- tranferring data from person to person1

select * from person1
order by id asc;

-- delete from person1 : this will delete the whole data of person1. But this command is 
-- 						 very slow for enormous data so here we can use 'TRUNCATE'

truncate table person1; -- this will delete all the data smoothly skipping the bts unlike
						-- delete command (logs and protocolling)
	