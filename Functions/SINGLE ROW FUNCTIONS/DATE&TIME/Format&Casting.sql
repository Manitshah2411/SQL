select * from sales.orders;
-----------------------------
--|	SINGLE ROW FUNCTIONS  |--
-----------------------------

----DATE & TIME FUNCTIONS----


-- 1. TO_CHAR

--- DATE FORMATTING ---
-- DD(Date INT), Day/Dy(Weekday STR), YYYY(Year INT), YY(LAST 2 digit of the year INT), MM(Month INT), Month/Mon(Month STR)
-- D(Day of the week (1=Sunday, 7=Saturday)), Q (Quarter of the year (1-4)), WW (Week number of the year (1-53))
SELECT
    creationtime,
	TO_CHAR(orderdate, 'Day, Dy') AS Days, -- Dy for abbreviation Day for full Dayname
	TO_CHAR(orderdate, 'D') AS Days,
	TO_CHAR(orderdate, 'Q') AS Q,
	TO_CHAR(orderdate, 'WW') AS week,
	TO_CHAR(orderdate, 'Month, Mon') AS Months, -- Mon give abbreviation of months like Jan, feb...
	TO_CHAR(orderdate, 'DD Mon, YYYY') AS ind_format, 
    TO_CHAR(orderdate, 'YYYY-MM-DD') AS iso_format,
    TO_CHAR(orderdate, 'Mon DD, YYYY') AS usa_format, 
    TO_CHAR(orderdate, 'Dy, Month DD') AS friendly_format
FROM
    sales.orders;

SELECT
	TO_CHAR(creationtime,'Mon YY') AS Months,
	COUNT(*)
FROM sales.orders
GROUP BY TO_CHAR(creationtime,'Mon YY')


--- TIME FORMATTING ---
-- HH24				Hour of day (00-23)				14 (for 2 PM)
-- HH12 or HH		Hour of day (01-12)				02 (for 2 PM)
-- MI				Minute (00-59)					07
-- SS				Second (00-59)					30
-- MS				Millisecond (000-999)			500
-- AM or PM			Meridiem indicator (uppercase)	PM

SELECT 
	creationtime,
	TO_CHAR(creationtime,'HH24:MI') AS time,
	TO_CHAR(creationtime, '"Day" Dy, Mon DD "Quarter" Q, YY HH24:MI:SS ') AS formatted
FROM sales.orders




--- NUMERIC FORMATTING ---
-- FM	Fill mode. Prevents padding with spaces and suppresses trailing zeros.
-- 9	Placeholder for a digit. If the digit doesn't exist, it's a space.
-- 0	Placeholder for a digit. If the digit doesn't exist, it's a zero (for padding).
-- .	Decimal point.
-- ,	Group separator (comma).
-- PR	Encloses negative values in angle brackets (<>).
-- $	Currency symbol (will be placed at the beginning).
-- G	Local group separator.
-- D	Local decimal point.

SELECT
	TO_CHAR(1234.5678,'FM9999.99') AS with_commas,
	TO_CHAR(8799301204,'9,999,999,999') AS with_commas,
	TO_CHAR(10,'0000') AS with_commas,
	TO_CHAR(-10,'99PR') AS with_commas,
	TO_CHAR(10000.57,'$99G999D99') AS with_commas,
	TO_CHAR(12345.67, 'L99G999D99') AS local_currency


-- 2. CAST & :: 
 
-- Two ways to type cast your data.
SELECT
	customerid::VARCHAR(50),
	orderdate::TEXT,
	'1234'::INT,
	'2025-8-29'::DATE,
	CAST(sales AS TEXT), 
	CAST(creationtime AS DATE)
FROM sales.orders;






	
