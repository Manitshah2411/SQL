# SQL Operators (for the `WHERE` Clause)

[](Diagrams/Operators.png)

Operators are special keywords or symbols used in the `WHERE` clause to specify conditions for filtering data.

---

## 1. Comparison Operators

*Used to compare two values.*

* **`=` (Equal to)**
* Finds rows where a column's value is exactly equal to a given value.

    ```sql
    SELECT * FROM customers WHERE country = 'USA';
    ```

* **`!=` or `<>` (Not equal to)**
* Finds rows where a column's value is not equal to a given value.

    ```sql
    SELECT * FROM customers WHERE country != 'USA';
    ```

* **`>` (Greater than)**

    ```sql
    SELECT * FROM customers WHERE score > 500;
    ```

* **`<` (Less than)**

    ```sql
    SELECT * FROM customers WHERE score < 500;
    ```

* **`>=` (Greater than or equal to)**

    ```sql
    SELECT * FROM customers WHERE score >= 500;
    ```

* **`<=` (Less than or equal to)**

    ```sql
    SELECT * FROM customers WHERE score <= 500;
    ```

---

## 2. Logical Operators

*Used to combine multiple conditions.*

* **`AND`**
* Returns rows only if **all** conditions are true.

    ```sql
    SELECT * FROM customers WHERE country = 'Germany' AND score > 400;
    ```

* **`OR`**
* Returns rows if **any** of the conditions are true.

    ```sql
    SELECT * FROM customers WHERE country = 'USA' OR country = 'UK';
    ```

* **`NOT`**
* Reverses the result of a condition. Finds rows where the condition is false.

    ```sql
    SELECT * FROM customers WHERE NOT country = 'USA';
    ```

---

## 3. Range Operator

*Used to check if a value falls within a specific range.*

* **`BETWEEN`**

* Selects values within a given range. The values are inclusive (includes the start and end values).

    ```sql
    SELECT * FROM customers WHERE score BETWEEN 500 AND 800;
    ```

---

## 4. Membership Operator

*Used to check if a value is present in a list of specified values.*

* **`IN`**
* Checks if a value matches any value in a list. It's a cleaner way to write multiple `OR` conditions.

    ```sql
    SELECT * FROM customers WHERE country IN ('USA', 'UK', 'India');
    ```

* **`NOT IN`**
* Checks if a value does not match any value in a list.

    ```sql
    SELECT * FROM customers WHERE country NOT IN ('Germany', 'Argentina');
    ```

---

## 5. Search Operator (Pattern Matching)

*Used to search for a specified pattern in a column.*

* **`LIKE`**
* Searches for a pattern in text data. It uses wildcards:
        *`%`: Represents zero, one, or multiple characters.
        *`_`: Represents a single character.

    ```sql
    -- Finds any name that starts with 'M'
    SELECT * FROM customers WHERE first_name LIKE 'M%';

    -- Finds any country with 'erman' in the middle
    SELECT * FROM customers WHERE country LIKE '%erman%';
    ```
