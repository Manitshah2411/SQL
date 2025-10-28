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


alter table person
add email varchar(50) not null; 

alter table person 
drop column birthdate;

select * from person;

drop table person;