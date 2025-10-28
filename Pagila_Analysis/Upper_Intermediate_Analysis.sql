/*
1. Customer Lifetime Value (CLV) Analysis
Task:Management wants to identify the top 10 highest value customers. For each customer:
* Show their total number of rentals, total revenue generated, and average payment amount.
* Add their ranking within their city based on revenue.
* Only include customers who have rented more than 20 films.
*/

SELECT * FROM customer;
SELECT * FROM rental;
SELECT * FROM payment;
SELECT * FROM city;
SELECT * FROM country;
SELECT * FROM address;
SELECT * FROM film;

SELECT
	t.customer_id,
	t.first_name,
	t.total_rentals,
	t.total_revenue,
	t.avg_payment,
	CONCAT(ad.address,', ',ci.city) AS city_address,
	RANK() OVER(PARTITION BY ci.city ORDER BY total_revenue DESC) AS rankings_based_on_revenue
FROM
(SELECT 
	customer_id,
	first_name,
	address_id,
	total_rentals,
	total_revenue,
	ROUND(total_revenue / total_rentals,2) AS avg_payment
FROM

(SELECT 
	c.customer_id,
	c.first_name,
	c.address_id,
	COUNT(DISTINCT r.rental_id) AS total_rentals,
	SUM(p.amount) AS total_revenue
FROM customer AS c
INNER JOIN rental AS r
ON c.customer_id = r.customer_id
INNER JOIN payment AS p
ON p.rental_id = r.rental_id
GROUP BY c.customer_id, c.first_name, c.address_id))t 


INNER JOIN address AS ad
ON ad.address_id = t.address_id

INNER JOIN city AS ci
ON ci.city_id = ad.city_id

WHERE total_rentals >= 20;


/*
2. Film Performance by Category
Task:The marketing team needs a report of the top 3 most rented films in each category. For each film:
* Show category name, film title, rental count, total revenue.
* Rank films within each category using rental count.
* Exclude categories with fewer than 1000 rentals total.
*/

SELECT * FROM rental;
SELECT * FROM film;
SELECT * FROM inventory;
SELECT * FROM category;
SELECT * FROM payment;
SELECT * FROM film_category;


SELECT 
	x.title,
	x.name,
	total_rentals,
	total_revenue,
	rankings,
	category_total	
FROM(SELECT 
	t.title,
	t.name,
	total_rentals,
	total_revenue,
	rankings,
	SUM(total_rentals) OVER(PARTITION BY t.name) AS category_total
FROM
(SELECT 
	f.title,
	ca.name,
	COUNT(DISTINCT r.rental_id) AS total_rentals,
	SUM(p.amount) AS total_revenue,
	DENSE_RANK() OVER(PARTITION BY ca.name ORDER BY COUNT(DISTINCT r.rental_id) DESC) AS rankings
FROM film AS f

INNER JOIN inventory AS i
ON f.film_id = i.film_id
INNER JOIN rental AS r
ON r.inventory_id = i.inventory_id
INNER JOIN payment AS p
ON p.rental_id = r.rental_id
INNER JOIN film_category AS fc
ON fc.film_id = f.film_id
INNER JOIN category AS ca
ON ca.category_id = fc.category_id
GROUP BY f.title, ca.name)t)x
WHERE category_total > 1000;



/*
3. Store Revenue vs Targets
Task:Management set a monthly target of $10,000 per store. Build a query to:
* Show store_id, month, total revenue, target_status (Above/Below Target).
* For each store, calculate the running total revenue across months.
* Highlight the first month when the store crossed $30,000 cumulative revenue.
*/




SELECT
	x.store_id,
	TO_CHAR(x.mon_date,'Mon YYYY') AS mon,
	x.total_revenue,
	x.target_status,
	x.running_total,
	CASE 
		WHEN x.running_total > 30000
		AND COALESCE(LAG(x.running_total) OVER(PARTITION BY x.store_id ORDER BY x.mon_date),0) < 30000 
		THEN 'Milestone Month'
		ELSE NULL
	END AS Milestone_month
FROM
(SELECT
	t.store_id,
	t.mon_date,
	t.total_revenue,
	t.target_status,
	SUM(t.total_revenue) OVER(PARTITION BY t.store_id ORDER BY t.mon_date) AS running_total
FROM
(SELECT 
	s.store_id,
	DATE_TRUNC('month', r.rental_date) AS mon_date,
	SUM(p.amount) AS total_revenue,
	CASE 
		WHEN SUM(p.amount) > 10000 THEN 'Above Target'
		ELSE 'Below Target'
	END AS target_status
FROM store AS s
INNER JOIN inventory AS i
ON i.store_id = s.store_id
INNER JOIN rental AS r
ON r.inventory_id = i.inventory_id
INNER JOIN payment AS p
ON p.rental_id = r.rental_id
GROUP BY s.store_id,
		 DATE_TRUNC('month', r.rental_date))t)x;

/* 4. Customer Retention Cohort Analysis
Task:The business wants to analyze customer retention by cohort:
* Define cohort month = month of first rental.
* For each cohort, show how many customers rented again in the 2nd, 3rd, and 6th month after joining.
* Present it as: cohort_month | month_offset | retained_customers.. */

SELECT * FROM customer;
SELECT * FROM rental;

WITH CTE_cohort_month AS
(
SELECT 
	customer_id,
	DATE_TRUNC('month',MIN(rental_date)) AS cohort_month
FROM rental
GROUP BY customer_id
),
CTE_month_offset AS
(
SELECT 
	r.customer_id,
	ccm.cohort_month,
	(EXTRACT(YEAR FROM r.rental_date) - EXTRACT(YEAR FROM ccm.cohort_month)) * 12 +
	(EXTRACT(MONTH FROM r.rental_date) - EXTRACT(MONTH FROM ccm.cohort_month)) AS month_offset
FROM CTE_cohort_month AS ccm
INNER JOIN rental AS r
ON r.customer_id = ccm.customer_id
)
SELECT 
	cohort_month,
	month_offset,
	COUNT(DISTINCT customer_id) AS customer_retention
FROM CTE_month_offset AS cmo
GROUP BY cohort_month, month_offset;


/*
5. Films Never Rented vs. Low Performers
Task:Management wants to clean up the catalog. Build a query that outputs:
* All films that were never rented.
* Films rented but earned less than $50 total revenue.
* Union these two sets together and flag them as never_rented or low_performer.
*/

SELECT * FROM rental;
SELECT * FROM film;
SELECT * FROM inventory;
SELECT * FROM payment;

SELECT 
	'never_rented' AS category,
	f.film_id,
	f.title
FROM film AS f
LEFT JOIN inventory AS i
ON i.film_id = f.film_id
LEFT JOIN rental AS r
ON r.inventory_id = i.inventory_id
WHERE r.rental_id IS NULL

UNION ALL

SELECT
	'low_performer' AS category,
	f.film_id,
	f.title
FROM film AS f
INNER JOIN inventory AS i
ON i.film_id = f.film_id
INNER JOIN rental AS r
ON r.inventory_id = i.inventory_id
INNER JOIN payment AS p
ON p.rental_id = r.rental_id
GROUP BY f.film_id,
		 f.title
HAVING SUM(p.amount) < 50;


/* 
6. Active vs Inactive Customers
Task: Build a query to classify customers as:
* Active if they rented within the last 6 months.
* Inactive otherwise.Then, show customer_id, name, last_rental_date, total_rentals, status.
Bonus: Update the active flag in the customer table accordingly.
*/


SELECT 
	c.customer_id,
	CONCAT(c.first_name,' ',c.last_name) AS FullName,
	TO_CHAR((MAX(r.rental_date)::DATE),'DD Mon YYYY') AS last_rental_date,
	COUNT(DISTINCT r.rental_id) AS total_rentals,
	CASE 
		WHEN MAX(r.rental_date) >= (CURRENT_DATE - INTERVAL '6 months') THEN 'Active'
		-- (EXTRACT(YEAR FROM r.rental_date) = 2025) AND (EXTRACT(MONTH FROM r.rental_date) > 6) THEN 'Active'
		ELSE 'Inactive'
	END AS status
FROM customer AS c
INNER JOIN rental AS r
ON c.customer_id = r.customer_id
GROUP BY c.customer_id, FullName;


/* 
7. Staff Performance & Store Insights
Task:For each staff member, generate a report:
* Total rentals handled, total revenue collected, average payment size.
* Show their rank within the store by revenue.
* Also show which store overall has the highest revenue.
*/

SELECT * FROM staff;
SELECT * FROM store;
SELECT * FROM rental;

WITH CTE_staff AS
(SELECT 
	s.staff_id,
	CONCAT(s.first_name,' ',s.last_name) AS Fullname,
	st.store_id,
	COUNT(DISTINCT r.rental_id) AS total_rental_handled
FROM staff AS s
INNER JOIN rental AS r
ON r.staff_id = s.staff_id
INNER JOIN store AS st
ON st.store_id = s.store_id
GROUP BY s.staff_id,
		 CONCAT(s.first_name,' ',s.last_name),
		 st.store_id
), CTE_aggre AS
(
SELECT 
	cs.staff_id,
	cs.Fullname,
	cs.store_id,
	cs.total_rental_handled,
	SUM(p.amount) AS total_revenue,
	ROUND(AVG(p.amount),2) AS avg_payment_size
FROM CTE_staff AS cs
INNER JOIN payment AS p 
ON p.staff_id = cs.staff_id
GROUP BY cs.staff_id,
	cs.Fullname,
	cs.store_id,
	cs.total_rental_handled
)
SELECT 
	ca.*,
	RANK() OVER(PARTITION BY ca.store_id ORDER BY ca.total_revenue DESC) AS ranked_on_total_revenue,
	CASE 
		WHEN MAX(total_revenue) OVER(PARTITION BY ca.store_id)= ca.total_revenue THEN 'Highest'
		ELSE NULL
	END AS max_store_revnue
FROM CTE_aggre ca;


/*
8. Longest Rental Streaks
Task:Find customers with the longest streak of consecutive days with at least one rental.
* Output customer_id, customer_name, streak_length, streak_start, streak_end.
* Ignore gaps larger than 1 day.
*/


WITH rental_dates AS
(
SELECT 
	DISTINCT 
	customer_id,
	rental_date::DATE AS rental_day
FROM rental AS r
), consecutive AS
(
SELECT 
	customer_id,
	rental_day,
	rental_day - ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY rental_day)::int AS grp
FROM rental_dates
), streak AS
(
SELECT 
	customer_id,
	MIN(rental_day) AS start_streak,
	MAX(rental_day) AS end_streak,
	COUNT(*) AS streak_length
FROM consecutive 
GROUP BY customer_id, grp
), ranked AS
(
SELECT 	
	st.*,
	RANK() OVER(PARTITION BY st.customer_id ORDER BY st.streak_length DESC) AS rnk
FROM streak AS st
)
SELECT 
	c.customer_id,
	CONCAT(c.first_name,' ',c.last_name) AS fullname,
	r.streak_length,
	r.start_streak,
	r.end_streak
FROM ranked AS r
INNER JOIN customer AS c
ON r.customer_id = c.customer_id
WHERE r.rnk = 1 
ORDER BY r.streak_length DESC, c.customer_id
	
