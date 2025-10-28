create table authors(
	author_id int primary key not null,
	author_name varchar(50) not null,
	author_nationality varchar(30)
);

create table books(
	book_id int primary key not null,
	title varchar(50) not null,
	publication_year int,
	author_id int,
	constraint fk_author 
		foreign key(author_id)
		references authors(author_id)
);


create table members(
	member_id int primary key not null,
	member_name varchar(50) not null,
	join_date varchar(30),
	email varchar(50) unique
);

alter table authors
add birth_year int;

alter table members
drop column email;

alter table books
rename column publication_year to pub_year;

select * from authors;
select * from books;
select * from members;

drop table if exists authors;
drop table if exists books;
drop table if exists members;


-- Step 1: Drop the 'library' schema
-- You must be connected to the 'library_db' database to run this command.
-- The CASCADE keyword is important: it automatically drops all objects
-- (like the tables you created) that are inside the schema.
-- :::: DROP SCHEMA IF EXISTS library CASCADE;

-- Step 2: Drop the 'library_db' database
-- IMPORTANT: You cannot be connected to the database you want to drop.
-- First, connect to a different database (like the default 'postgres' database).
-- Then, run this command.
-- :::: DROP DATABASE IF EXISTS library_db;
