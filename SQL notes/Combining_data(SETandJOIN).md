# Combining Data in SQL

[](Diagrams/SETvsJOIN(Combine).png)
There are two primary ways to combine data from multiple sources in SQL: **SET Operators** (which combine rows) and **JOINs** (which combine columns).

---

## 1. SET Operators (Combining Rows)

*Used to combine the results of two or more `SELECT` statements into a single result set. The columns in each `SELECT` statement must have the same number and similar data types.*

### `RULES`

* **RULE 1 :** The SET OPERATOR can be used in any clauses WHERE|JOIN|HAVING etc.
            But, the ORDER BY command can be only used once and at the last of the
            whole query
            [](Diagrams/Rule_1SET_Operators.png)
            [](Diagrams/Rule_1SET_OperatorsExample.png)

* **RULE 2:**  The number of columns should be same in each query.

* **RULE 3:** The Datatype of the columns should match. For example col1 table1 = VARCHAR
            col1 table2 = VARCHAR. If mismatch it'll throw an error.

### `UNION`

* **What it does:** Combines the results of two queries and removes any duplicate rows.
* **Analogy:** "Give me everyone from List A **OR** List B, but don't list anyone twice."

    ```sql
    SELECT name FROM table_a
    UNION
    SELECT name FROM table_b;
    ```

### `UNION ALL`

* **What it does:** Combines the results of two queries and includes **all** rows, even duplicates.
* **Analogy:** "Give me everyone from List A **AND** everyone from List B, exactly as they are."

    ```sql
    SELECT name FROM table_a
    UNION ALL
    SELECT name FROM table_b;
    ```

### `INTERSECT`

* **What it does:** Returns only the rows that appear in **both** query results.
* **Analogy:** "Give me only the people who are in **both** List A **and** List B."

    ```sql
    SELECT name FROM table_a
    INTERSECT
    SELECT name FROM table_b;
    ```

### `EXCEPT` (or `MINUS` in some databases)

* **What it does:** Returns rows from the first query that do **not** appear in the second query.
* **Analogy:** "Give me everyone from List A, **except for** the people who are also in List B."

    ```sql
    SELECT name FROM table_a
    EXCEPT
    SELECT name FROM table_b;
    ```

[](Diagrams/Use_case%20_SET.png)

[](Diagrams/Use_caseSET.png)
[!Summary](Diagrams/SET_SUMMARY.png)

---

## 2. JOINs (Combining Columns)

*Used to combine columns from two or more tables into a single row, based on a related "key" column between them.*
[](Diagrams/Types_of_joins.png)
[](Diagrams/Use_of_joins.png)

### `INNER JOIN`

* **What it does:** Returns only the rows where the key column has a matching value in **both** tables.
* **Analogy:** "Show me only the customers **who have placed an order**."

    ```sql
    SELECT *
    FROM table_a
    INNER JOIN table_b ON table_a.key_column = table_b.key_column;
    ```

### `LEFT JOIN` (or `LEFT OUTER JOIN`)

* **What it does:** Returns **all** rows from the **left** table (table A), and the matched rows from the right table (table B). If there is no match, the columns from the right table will be `NULL`.
* **Analogy:** "Show me **all** customers, and if they've placed an order, show that order information too."

    ```sql
    SELECT *
    FROM table_a
    LEFT JOIN table_b ON table_a.key_column = table_b.key_column;
    ```

### `RIGHT JOIN` (or `RIGHT OUTER JOIN`)

* **What it does:** Returns **all** rows from the **right** table (table B), and the matched rows from the left table (table A). If there is no match, the columns from the left table will be `NULL`.
* **Analogy:** "Show me **all** orders, and the customer information for the customer who placed each order."

    ```sql
    SELECT *
    FROM table_a
    RIGHT JOIN table_b ON table_a.key_column = table_b.key_column;
    ```

### `FULL JOIN` (or `FULL OUTER JOIN`)

* **What it does:** Returns all rows when there is a match in either the left or the right table. It combines the results of both `LEFT JOIN` and `RIGHT JOIN`.
* **Analogy:** "Show me **all** customers and **all** orders. Match them up where you can, but show every customer and every order, regardless of whether they have a match."

    ```sql
    SELECT *
    FROM table_a
    FULL JOIN table_b ON table_a.key_column = table_b.key_column;
    ```
