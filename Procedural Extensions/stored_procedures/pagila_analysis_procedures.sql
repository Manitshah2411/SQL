/*
Customer Summary Procedure
Task:Create a procedure get_customer_summary() that calculates:
* Total number of customers
* Average rental payment per customer
* Only for a given country (pass as a parameter)
Requirements:
* Use a procedure, not a function.
* Print the summary using RAISE NOTICE.
* Optional: use a temporary table to store results.
Advanced Twist:
* Include a total_rentals per customer and flag customers with more than 5 rentals as 'Loyal'.
*/

SELECT * FROM country;
SELECT * FROM address;
SELECT * FROM city;


CREATE OR REPLACE PROCEDURE get_customer_summary(p_country VARCHAR(20), p_loyalty_rentals int)
LANGUAGE plpgsql
AS $$	
BEGIN
DROP TABLE IF EXISTS active_table;
CREATE TEMP TABLE active_table AS
	SELECT 
		t.*,
		CASE 
			WHEN t.total_rentals >= p_loyalty_rentals THEN 'LOYAL'
			ELSE 'NOT LOYAL'
		END AS Flags,
		RANK() OVER(ORDER BY t.total_rentals DESC) AS rankings
	FROM
	(SELECT 
		c.customer_id,
		CONCAT(c.first_name,' ',c.last_name) AS customer_full_name,
		CONCAT(a.address,' ',a.district) AS full_address,
		ci.city,
		co.country,
		COUNT(DISTINCT r.rental_id) AS total_rentals
	FROM customer AS c
	JOIN rental AS r
	ON r.customer_id = c.customer_id
	JOIN address AS a
	ON a.address_id = c.address_id
	JOIN city AS ci
	ON ci.city_id = a.city_id
	JOIN country AS co
	ON co.country_id = ci.country_id
	WHERE country = p_country
	GROUP BY c.customer_id,
			 CONCAT(c.first_name,' ',c.last_name),
		 	 CONCAT(a.address,' ',a.district),
			 ci.city,
			 co.country)t;
RAISE NOTICE 'Temp created for country %',p_country;
END;
$$;

CALL get_customer_summary('India',30);
SELECT * FROM active_table;


/*
Staff Performance Procedure
Task:Create a procedure get_staff_performance() that outputs, for each staff member:
* Staff name
* Total rentals handled
* Total revenue generated
* Average payment size
* Rank them within their store by total revenue
Requirements:
* Use a procedure
* Print results using RAISE NOTICE for each staff member
* Include optional parameters: store_id to filter by store
*/

SELECT * FROM staff
SELECT * FROM rental
SELECT * FROM payment

CREATE OR REPLACE PROCEDURE get_staff_performance(p_store_id int DEFAULT NULL)
LANGUAGE plpgsql
AS $$
DECLARE 
	rec RECORD;
BEGIN
	DROP TABLE IF EXISTS active_table1;
	CREATE TABLE active_table1 AS
	SELECT 
		t.*,
		RANK() OVER(PARTITION BY t.store_id ORDER BY total_revenue DESC) AS ranking_per_store
	FROM
	(SELECT 
		s.store_id,
		s.staff_id,
		CONCAT(s.first_name,' ',s.last_name) AS full_name,
		COUNT(DISTINCT r.rental_id) AS total_rentals,
		SUM(p.amount) AS total_revenue,
		AVG(p.amount) AS avg_payment
	FROM staff AS s
	JOIN rental AS r
	ON r.staff_id = s.staff_id
	JOIN payment AS p
	ON p.rental_id = r.rental_id
	GROUP BY s.store_id, s.staff_id, CONCAT(s.first_name,' ',s.last_name))t;

	-- LOOP
	FOR rec IN SELECT * FROM active_table1 LOOP
		RAISE NOTICE 'store : %, staff : %, rentals : %, total revenue : %, average payment : %, rankings : %',
		rec.store_id, rec.full_name, rec.total_rentals, rec.total_revenue, rec.avg_payment, rec.ranking_per_store;
	END LOOP;
END;
$$;

CALL get_staff_performance(1)
SELECT * FROM active_table1


/*
Active vs Inactive Customers Procedure
Task:Create a procedure classify_customers_activity() to classify customers as:
* 'Active' if they rented within the last 6 months
* 'Inactive' otherwise
Requirements:
* Update a column active_flag in the customer table
* Also print the total number of active and inactive customers using RAISE NOTICE
Advanced Twist:
* Accept a parameter for number of months to define “active” dynamically
*/


SELECT * FROM customer
SELECT * FROM rental

ALTER TABLE customer
ADD COLUMN active_flag VARCHAR(15);

CREATE OR REPLACE PROCEDURE classify_customer_activity(p_active_threshold INT DEFAULT 6) 
LANGUAGE plpgsql
AS $$
DECLARE 
	v_active_count INT;
	v_inactive_count INT;
BEGIN
	UPDATE customer c 
	SET active_flag = CASE
	WHEN EXISTS 
	(
		SELECT 1
		FROM rental AS r
		WHERE r.customer_id  = c.customer_id
		AND r.rental_date >= CURRENT_DATE - (p_active_threshold || ' months')::INTERVAL
	)
		THEN 'Active'
		ELSE 'Inactive'
	END;

	SELECT COUNT(*) INTO v_active_count FROM customer WHERE active_flag = 'Active';
	SELECT COUNT(*) INTO v_inactive_count FROM customer WHERE active_flag = 'Inactive';

	RAISE NOTICE 'Total active customers(within % months) : %', p_active_threshold, v_active_count;
	RAISE NOTICE 'Total inactive customers : %', v_inactive_count;
END;
$$;


SELECT * FROM customer
CALL classify_customer_activity(36);


/*
 Film Revenue Procedure
Task:Create a procedure film_revenue_report() that outputs:
* Film title
* Number of times rented
* Total revenue
* Average rental amount
Requirements:
* Include only films with revenue above a threshold (pass as a parameter)
* Print results using RAISE NOTICE or store in a temp table
Advanced Twist:
* Rank films by revenue per category
*/

SELECT * FROM film
SELECT * FROM inventory
SELECT * FROM payment
SELECT * FROM film_category
SELECT * FROM category
SELECT * FROM country

CREATE OR REPLACE PROCEDURE film_revenue_report(p_revenue_threshold INT DEFAULT 50)
LANGUAGE plpgsql
AS $$
BEGIN
DROP TABLE IF EXISTS film_report;
CREATE TEMP TABLE film_report AS
(
	SELECT
		t.*,
		RANK() OVER(PARTITION BY t.category_id ORDER BY t.total_revenue DESC) AS rankings
	FROM 
	(SELECT 
		f.film_id,
		fc.category_id,
		f.title,
		COUNT(DISTINCT r.rental_id) AS total_rentals,
		SUM(p.amount) AS total_revenue,
		ROUND(AVG(p.amount),2) AS avg_revenue
	FROM rental AS r
	JOIN inventory AS i
	ON i.inventory_id = r.inventory_id
	JOIN film AS f
	ON f.film_id = i.film_id
	JOIN payment AS p
	ON p.rental_id = r.rental_id
	JOIN film_category AS fc
	ON fc.film_id = f.film_id
	GROUP BY f.title, fc.category_id, f.film_id)t
	WHERE t.total_revenue >= p_revenue_threshold);
END;
$$;

CALL film_revenue_report(100)
SELECT * FROM film_report

/*
Longest Rental Streak Procedure
Task:Create a procedure customer_longest_streak() to find for each customer:
* The longest streak of consecutive rental days
* Start and end dates of the streak
* Streak length
Requirements:
* Use ROW_NUMBER() and date arithmetic inside the procedure
* Print the top 5 longest streaks across all customers
*/

CREATE OR REPLACE PROCEDURE customer_longest_streak()
LANGUAGE plpgsql
AS $$
DECLARE
	rec RECORD;
BEGIN
	DROP TABLE IF EXISTS customer_streak;
	CREATE TEMP TABLE customer_streak AS
	(
	SELECT 
		q.customer_id,
		q.start_streak,
		q.end_streak,
		q.streak_length,
		ROW_NUMBER() OVER(ORDER BY q.streak_length DESC) AS rankings
	FROM
	(SELECT 
	t.customer_id,
	t.grp,
	MIN(t.rental_day) AS start_streak,
	MAX(t.rental_day) AS end_streak,
	COUNT(*) AS streak_length
	FROM
	(SELECT 
		r.customer_id,
		rental_date::DATE as rental_day,
		rental_date::DATE - (ROW_NUMBER() OVER(PARTITION BY r.customer_id ORDER BY rental_date::DATE) * INTERVAL '1 day') AS grp
	FROM rental AS r)t
	GROUP BY t.customer_id, t.grp
	ORDER BY t.customer_id, t.grp
	)q
	ORDER BY q.streak_length DESC
	LIMIT 5);

	FOR rec IN SELECT * FROM customer_streak LOOP
	RAISE NOTICE 'Customer id : %, Start Streat : %, End Streak : %, Streak Length : %, Ranking : %',
	rec.customer_id, rec.start_streak, rec.end_streak, rec.streak_length, rec.rankings;
	END LOOP;
END;
$$;

CALL customer_longest_streak()
SELECT * FROM customer_streak



/*
 Payments Summary Procedure
Task:Create a procedure payments_summary() that outputs:
* Total payments per month
* Average payment per month
* Highest payment in the month
Requirements:
* Accept start_date and end_date as parameters
* Use a temporary table to store results
* Print a summary using RAISE NOTICE
*/

SELECT * FROM payment;

CREATE OR REPLACE PROCEDURE payment_summary(p_start_date DATE, p_end_date DATE DEFAULT CURRENT_DATE)
LANGUAGE plpgsql
AS $$
DECLARE 
	rec RECORD;
BEGIN 
	DROP TABLE IF EXISTS payment_reports;
	CREATE TEMP TABLE payment_reports AS
	(
	SELECT 
		DATE_TRUNC('MONTH',payment_date)::DATE AS month_start,
		SUM(amount) AS total_payment_per_month,
		ROUND(AVG(amount),2) AS avg_payment_per_month,
		MAX(amount) highest_payment
	FROM payment
	WHERE payment_date BETWEEN p_start_date AND p_end_date
	GROUP BY DATE_TRUNC('MONTH',payment_date)
	ORDER BY month_start
	);
	FOR rec IN SELECT * FROM payment_reports LOOP
	RAISE NOTICE 'Month Start : %, Total Payments : %, Average Payment : %, Highest Payment : %',
	rec.month_start, rec.total_payment_per_month, rec.avg_payment_per_month, rec.highest_payment;
	END LOOP;
END;
$$;

CALL payment_summary('2022-01-01');
SELECT * FROM payment_reports;

/*
Customer Cohort Retention Procedure
Task:Create a procedure customer_retention_report() that calculates:
* Number of customers retained in 2nd, 3rd, and 6th month after their first rental
* Accept optional cohort_year as parameter
* Print cohort-wise retention counts using RAISE NOTICE
Advanced Twist:
* Store results in a temp table for further queries
*/

SELECT * FROM customer;
SELECT * FROM rental;


CREATE OR REPLACE PROCEDURE customer_retention_report(p_cohort_year INT DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN
    CREATE TEMP TABLE retention_report AS
    SELECT
        t.rental_month AS cohort_month,
        EXTRACT(YEAR FROM t.rental_month) AS cohort_year,
        COUNT(DISTINCT CASE 
            WHEN DATE_TRUNC('month', r.rental_date) = t.rental_month + INTERVAL '2 month'
            THEN r.customer_id END) AS retention_2,
        COUNT(DISTINCT CASE 
            WHEN DATE_TRUNC('month', r.rental_date) = t.rental_month + INTERVAL '3 month'
            THEN r.customer_id END) AS retention_3,
        COUNT(DISTINCT CASE 
            WHEN DATE_TRUNC('month', r.rental_date) = t.rental_month + INTERVAL '6 month'
            THEN r.customer_id END) AS retention_6
    FROM (
        SELECT 
            c.customer_id,
            DATE_TRUNC('month', MIN(r.rental_date))::date AS rental_month,
            MIN(r.rental_date)::date AS first_rental_date
        FROM rental r
        JOIN customer c ON r.customer_id = c.customer_id
        GROUP BY c.customer_id
    ) t
    LEFT JOIN rental r 
        ON t.customer_id = r.customer_id
    GROUP BY t.rental_month
    HAVING p_cohort_year IS NULL 
        OR EXTRACT(YEAR FROM t.rental_month) = p_cohort_year;
    
    RAISE NOTICE 'Cohort retention report generated for year: %', p_cohort_year;
END;
$$;


CALL customer_retention_report();
SELECT * FROM retention_report;


/*
Films Never Rented / Low Performers Procedure
Task:Create a procedure low_performing_films() to output:
* Films never rented → flag 'never_rented'
* Films rented but earned less than $80 → flag 'low_performer'
Requirements:
* Store results in a temp table or print using RAISE NOTICE
* Include optional filter by category
*/

SELECT * FROM film
SELECT * FROM rental
SELECT * FROM inventory
SELECT * FROM payment
SELECT * FROM film_category
SELECT * FROM category



CREATE OR REPLACE PROCEDURE low_peforming_films(p_category VARCHAR DEFAULT NULL)
LANGUAGE plpgsql
AS $$
DECLARE 
	rec RECORD;
BEGIN
	DROP TABLE IF EXISTS low_films_report;
	CREATE TEMP TABLE low_films_report AS
		WITH rented_status AS
			(SELECT 
				f.film_id,
				r.rental_id,
				CASE WHEN r.rental_id IS NULL THEN 'Never Rented' ELSE 'Rented' END AS status
			FROM film AS f
			LEFT JOIN inventory AS i
			ON i.film_id = f.film_id
			LEFT JOIN rental AS r
			ON r.inventory_id = i.inventory_id),
			less_than_50 AS
			(
				SELECT 
					rs.film_id,
					rs.status,
					COALESCE(SUM(p.amount),0) AS total_earnings
				FROM rented_status AS rs
				LEFT JOIN payment AS p
				ON rs.rental_id = p.rental_id
				GROUP BY rs.film_id,
					rs.status
			), performance AS
			(SELECT 
				lt.film_id,
				lt.status,
				lt.total_earnings,
				CASE WHEN lt.status = 'Never Rented' THEN 'Never Rented'
				WHEN lt.total_earnings < 80 THEN 'Low Performer' ELSE NULL END AS flag
			FROM less_than_50 AS lt
			WHERE lt.status = 'Never Rented' OR lt.total_earnings < 80
			), final_cte AS
			(SELECT 
				p.film_id,
				p.total_earnings,
				p.flag,
				c.name AS category
			FROM performance AS p
			LEFT JOIN film_category AS fc
			ON fc.film_id = p.film_id
			LEFT JOIN category AS c
			ON fc.category_id = c.category_id
			WHERE p_category = c.name OR p_category IS NULL)
			SELECT * FROM final_cte;
			

		FOR rec IN SELECT * FROM low_films_report LOOP
		RAISE NOTICE 'Film id : %, Total Earnings : %, Flag : %, Category : %',
		rec.film_id, rec.total_earnings, rec.flag, rec.name;
		END LOOP;
END;
$$;

CALL low_performing_films();
SELECT * FROM low_films_report;


