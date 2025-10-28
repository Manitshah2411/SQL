# User-Defined Functions (UDF) in PostgreSQL

In PostgreSQL, **User-Defined Functions (UDFs)** are custom functions created by users to encapsulate reusable logic.  
They can take input parameters, perform computations, and return a value (scalar or table).

---

## 🔹 Why Use UDFs?

- Encapsulate business logic inside the database
- Reuse logic across multiple queries
- Simplify SQL queries by abstracting complexity
- Return single values, multiple columns, or entire result sets

---

## 🔹 Syntax of UDF

```sql
CREATE OR REPLACE FUNCTION function_name(param1 type, param2 type, ...)
RETURNS return_type
LANGUAGE plpgsql
AS $$
DECLARE
    -- variable declarations
BEGIN
    -- logic
    RETURN value;
END;
$$;
```

---

## 🔹 Example 1: Simple Scalar Function

A function to **square a number**.

```sql
CREATE OR REPLACE FUNCTION square(num INT)
RETURNS INT
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN num * num;
END;
$$;

-- Usage
SELECT square(5);  -- Returns 25
```

**BTS:**  

- `RETURNS INT`: function will return an integer.  
- Function body multiplies input and returns result.  
- Called like any built-in SQL function.

---

## 🔹 Example 2: Conditional Function

Classify a number as positive, negative, or zero.

```sql
CREATE OR REPLACE FUNCTION classify_number(num INT)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
BEGIN
    IF num > 0 THEN
        RETURN 'Positive';
    ELSIF num < 0 THEN
        RETURN 'Negative';
    ELSE
        RETURN 'Zero';
    END IF;
END;
$$;

-- Usage
SELECT classify_number(-10);  -- Returns 'Negative'
```

**BTS:**  

- Uses `IF-ELSIF-ELSE` block.  
- Returns a `TEXT` value.  

---

## 🔹 Example 3: Table-Valued Function

Return the sum and count of even numbers from an array.

```sql
CREATE OR REPLACE FUNCTION sum_even(arr INT[])
RETURNS TABLE(total_sum INT, count_even INT, mean NUMERIC)
LANGUAGE plpgsql
AS $$
DECLARE
    var INT;
BEGIN
    total_sum := 0;
    count_even := 0;

    FOREACH var IN ARRAY arr LOOP
        IF var % 2 = 0 THEN
            total_sum := total_sum + var;
            count_even := count_even + 1;
        END IF;
    END LOOP;

    IF count_even > 0 THEN
        mean := total_sum::NUMERIC / count_even;
    ELSE
        mean := 0;
    END IF;

    RETURN NEXT; -- required for table-returning functions
END;
$$;

-- Usage
SELECT * FROM sum_even(ARRAY[10, 21, 30, 42]);
```

**BTS:**

- `RETURNS TABLE(...)`: allows multiple outputs.  
- `FOREACH`: iterate through array elements.  
- `RETURN NEXT`: emits a row into the result set.  

---

## 🔹 Example 4: Using IN, OUT, and INOUT Parameters

```sql
CREATE OR REPLACE FUNCTION calculate_sum(IN a INT, IN b INT, OUT total INT)
LANGUAGE plpgsql
AS $$
BEGIN
    total := a + b;
END;
$$;

-- Usage
SELECT * FROM calculate_sum(10, 20);  -- Returns 30
```

**BTS:**

- `IN`: default, accepts input only.  
- `OUT`: acts as output, automatically returned.  
- `INOUT`: both input and output.  

---

## 🔹 Example 5: Handling Errors (Safe Divide)

```sql
CREATE OR REPLACE FUNCTION safe_divide(a NUMERIC, b NUMERIC)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
BEGIN
    IF b = 0 THEN
        RAISE NOTICE 'Cannot divide by zero';
        RETURN NULL;
    ELSE
        RETURN a / b;
    END IF;
END;
$$;

-- Usage
SELECT safe_divide(10, 0);  -- Returns NULL, shows notice
```

---

## 🔹 Example 6: Returning Query Results

```sql
CREATE OR REPLACE FUNCTION get_customer_by_country(p_country TEXT)
RETURNS TABLE(customer_name TEXT, customerid INT)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT CONCAT(firstname, ' ', lastname), customerid
    FROM sales.customers
    WHERE country = p_country;
END;
$$;

-- Usage
SELECT * FROM get_customer_by_country('USA');
```

**BTS:**

- `RETURN QUERY`: directly returns the result of a SELECT.  

---

## 🔹 Example 7: Mimicking Excel MID Function

```sql
CREATE OR REPLACE FUNCTION mid(str TEXT, start INT, len INT)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN SUBSTRING(str FROM start FOR len);
END;
$$;

-- Usage
SELECT mid('PostgreSQL', 5, 3);  -- Returns 'gre'
```

---

## 🔹 Key BTS Notes

- **NEW & OLD are only available inside triggers**, not UDFs.  
- UDFs **must explicitly return** values (except OUT params).  
- UDFs can return:
  - Scalar value (`RETURNS INT`)
  - Table (`RETURNS TABLE(...)`)
  - Record (`RETURNS RECORD`)  

---

## ✅ Summary

- Use **UDFs** when you need reusable database logic.  
- They can return single values or complex result sets.  
- Great for abstracting logic, validation, and computations.  
- Often used together with procedures and triggers for complete database programming.
