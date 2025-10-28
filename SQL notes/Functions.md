# SQL Functions Cheatsheet

SQL functions are built-in operations that perform calculations or manipulate data. They are categorized into two main types:

**Single-Row Functions** and **Multi-Row Functions**.

[](Diagrams/Function_and_category.png)

[](Diagrams/Fucntions_flowchart.png)

---

## 1. Single-Row Functions (Row-Level Calculations)

These functions operate on a single row at a time and return one result for each row.

### String Functions

*Used to manipulate text data.*

* **`CONCAT_WS(separator, string1, string2, ...)`**: Combines two or more strings with a separator. It's the best way to join names because it ignores `NULL` values.

    ```sql
    SELECT CONCAT_WS(' ', firstname, lastname) AS full_name FROM sales.employees;
    ```

* **`UPPER()` / `LOWER()`**: Converts a string to uppercase or lowercase.

    ```sql
    SELECT UPPER(product) FROM sales.products;
    ```

* **`LENGTH()`**: Returns the number of characters in a string.

    ```sql
    SELECT product, LENGTH(product) FROM sales.products;
    ```

* **`TRIM()`**: Removes leading and trailing spaces. Essential for data cleaning.

    ```sql
    SELECT TRIM('  Socks  '); -- Returns 'Socks'
    ```

* **`SUBSTRING(string FROM start FOR length)`**: Extracts a part of a string.

    ```sql
    SELECT SUBSTRING(product FROM 1 FOR 3) FROM sales.products; -- Returns 'Bot', 'Tir', etc.
    ```

### Numeric Functions

*Used to perform calculations on numeric data.*

* **`ROUND(number, decimal_places)`**: Rounds a number to a specified number of decimals.

    ```sql
    SELECT ROUND(AVG(price), 2) FROM sales.products;
    ```

* **`CEIL(number)`**: Rounds a number **up** to the nearest integer.
* **`FLOOR(number)`**: Rounds a number **down** to the nearest integer.

    ```sql
    SELECT CEIL(15.2);  -- Returns 16
    SELECT FLOOR(15.7); -- Returns 15
    ```

### Date & Time Functions

*Used to manipulate date and time values.*
[](Diagrams/Date_time_flowchart.png)
[](Diagrams/Functions_singlerow_DateTime.png)

* **`NOW()` / `CURRENT_DATE`**: Returns the current timestamp or date.

    ```sql
    SELECT NOW();
    ```

* **`EXTRACT(part FROM date)`**: Pulls a specific part (like `YEAR`, `MONTH`, `DAY`) from a date.

    ```sql
    SELECT orderdate, EXTRACT(YEAR FROM orderdate) AS order_year FROM sales.orders;
    ```

* **`AGE(date1, date2)`**: Calculates the interval between two dates.

    ```sql
    SELECT AGE(NOW(), birthdate) FROM sales.employees;
    ```

### NULL Functions

*Used to handle `NULL` (empty) values.*

* **`COALESCE(value1, value2, ...)`**: Returns the first non-NULL value in a list. It's perfect for providing a default value for a column that might be empty.

    ```sql
    SELECT COALESCE(billaddress, 'Address Not Provided') FROM sales.orders;
    ```

* **`NULLIF(value1, value2)`**: Returns `NULL` if the two values are equal; otherwise, it returns the first value.

---

## 2. Multi-Row Functions (Aggregations)

These functions operate on a set of rows and return a single result for the entire set.

### Aggregate Functions (Basics)

*Almost always used with a `GROUP BY` clause.*

* **`COUNT()`**: Counts the number of rows.
* **`SUM()`**: Calculates the sum of a numeric column.
* **`AVG()`**: Calculates the average of a numeric column.
* **`MIN()` / `MAX()`**: Finds the minimum and maximum values.

    ```sql
    SELECT
        country,
        COUNT(customerid) AS number_of_customers,
        SUM(score) AS total_score
    FROM sales.customers
    GROUP BY country;
    ```

### Window Functions (Advanced)

*Perform calculations across a set of table rows that are somehow related to the current row. Unlike aggregate functions, they do not collapse rows.*
[](Diagrams/WindowFunction_flowchart.png)
 
* **`ROW_NUMBER()`**: Assigns a unique number to each row within a partition.
* **`RANK()` / `DENSE_RANK()`**: Ranks rows within a partition, with `RANK()` leaving gaps for ties.
* **`LEAD()` / `LAG()`**: Accesses data from a subsequent row or a previous row in the same result set.

    ```sql
    -- Rank employees by salary within each department
    SELECT
        firstname,
        department,
        salary,
        RANK() OVER (PARTITION BY department ORDER BY salary DESC) as salary_rank
    FROM sales.employees;
    ```
