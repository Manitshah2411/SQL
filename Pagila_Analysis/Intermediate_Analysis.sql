select * FROM rental
select * FROM film
select * FROM inventory
select * FROM payment
select * FROM customer
select * FROM country
select * FROM address
select * FROM city


/*
Challenge 1: Film Rental Performance Analysis
Scenario: The store manager wants to understand which films are performing well to make better inventory decisions.
They need a report on the rental performance of films released in 2006.

The Task: Write a single query that creates a performance report for all films with a release_year of 2006. 
The report should be grouped by the film's rating. For each rating category, it must show:
* The film rating.
* The total number of films in that rating category.
* The total number of times films in that category have been rented.
* The total revenue generated from those rentals.
* The average rental duration for films in that category, formatted as text with " Days" appended (e.g., "5.25 Days").

The final report should only include rating categories that have generated more than $1000 in total revenue, and 
it should be sorted by the total revenue in descending order.
*/

SELECT
	rating,
	COUNT(DISTINCT f.film_id) AS total_films,
	COUNT(r.rental_id) AS total_rental,
	ROUND(SUM(p.amount)) AS total_revenue,
	DATE_TRUNC('minute',AVG(return_date - r.rental_date))
	
FROM film AS f

INNER JOIN inventory AS i
	ON i.film_id = f.film_id
	
INNER JOIN rental AS r
	ON i.inventory_id = r.inventory_id
	
INNER JOIN payment AS p
	ON p.rental_id = r.rental_id
	
GROUP BY rating
HAVING ROUND(SUM(p.amount)) > 12000


/*
Challenge 2: Customer Segmentation and Cleanup
Scenario: The marketing team wants to identify "inactive" customers for a re-engagement campaign. 

They also want to create a permanent table of the most loyal customers from the USA.

Part 1: DML & DQL Task Write a single DELETE statement to remove all payment records from 
the payment table for customers whose last rental was before January 1, 2007.

Part 2: DDL & DML Task Create a new table named usa_loyal_customers. It should have columns for:
* customer_id (integer, primary key)
* full_name (varchar)
* email (varchar)
* total_rentals (integer)

Write a single command to populate this new table. A loyal customer from the United States is defined as someone who has rented more than 35 films.
*/

-- Part - 1 
DELETE FROM payment
WHERE customer_id IN -- The subquery should be the single column output so that the WHERE clause can search inside it
(SELECT
	customer_id
FROM rental
GROUP BY customer_id
HAVING MAX(rental_date) < '2022-05-01');


-- Part - 2
CREATE TABLE loyal_customer_USA(
	customer_id INTEGER NOT NULL PRIMARY KEY,
	customer_full_name VARCHAR(50),
	email VARCHAR(50),
	address VARCHAR(120),
	city VARCHAR(30),
	total_rentals INTEGER
)

INSERT INTO loyal_customer_USA(customer_id,customer_full_name,email,address,city,total_rentals)
(SELECT 
	c.customer_id,
	CONCAT(c.first_name,' ',c.last_name) AS CustomerFullName,
	c.email,
	a.address,
	ci.city,
	COUNT(r.rental_id) AS total_rentals
FROM customer AS c

INNER JOIN address AS a
ON a.address_id = c.address_id

INNER JOIN city AS ci
ON ci.city_id = a.city_id

INNER JOIN country AS co
ON ci.country_id = co.country_id

INNER JOIN rental AS r
ON r.customer_id = c.customer_id

WHERE co.country = 'United States'

GROUP BY c.customer_id,
	CustomerFullName,
	c.email,
	a.address,
	ci.city,
	co.country

HAVING COUNT(r.rental_id) > 25

ORDER BY c.customer_id)



/*
Challenge 3: Actor & Category Deep Dive
Scenario: The acquisitions team wants to know which actors are most popular in the 'Action' and 'Comedy' 
film categories to help them decide which new films to purchase.

The Task: Write a single query that identifies the top 5 actors who have appeared in the most films 
within the 'Action' and 'Comedy' categories combined. The final report must show:
* The actor's full name.
* The number of 'Action' films they have appeared in.
* The number of 'Comedy' films they have appeared in.
* The total count of films across both categories.
The list should be sorted by the total film count in descending order.
*/

SELECT 
	a.actor_id,
	CONCAT(a.first_name,' ',a.last_name) AS Actor_full_name,
	SUM(CASE
			WHEN c.name = 'Action' THEN 1 
			ELSE 0
			END) AS total_action_films,
	SUM(CASE
			WHEN c.name = 'Comedy' THEN 1 
			ELSE 0
			END) AS total_comedy_films,
	COUNT(*) AS total_films
	
FROM actor AS a
INNER JOIN film_actor fa
ON fa.actor_id = a.actor_id

INNER JOIN film_category AS fc
ON fc.film_id = fa.film_id

INNER JOIN category AS c
ON c.category_id  = fc.category_id

WHERE c.name IN ('Action','Comedy')
GROUP BY a.actor_id, Actor_full_name

ORDER BY total_films DESC
LIMIT 5;

