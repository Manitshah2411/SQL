insert into customers (id,first_name,country,score)
values (7,'Kashvi','India',750),
		(8,'Messi','Argentina',800); -- can insert multiple rows at the same time

insert into customers (first_name,country,score,id) -- can change the sequence of the column
													-- if changing the sequence the values 
													-- column should also match that sequence
values ('Kdb','Belgium',700,9);


insert into customers values (10,'Sam','USA',900); -- can directly add the rows without 
												   -- specifying the columns
												   -- but it should match the default sequence

insert into customers values (11,'Pichai',Null,850) -- can give the value null if not null
													-- is not constrained.
							-- (11,'Pichai') can directly leave that space for the other too
							-- the db will automatically put null in the other 2 columns

select * from customers
order by id asc;