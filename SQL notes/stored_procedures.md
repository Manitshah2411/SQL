# Stored Procedures in PostgreSQL

A **stored procedure** is a saved collection of SQL and procedural logic (PL/pgSQL) that you can execute on demand.  
It is similar to a function but is mainly used for executing a sequence of operations, not necessarily returning values.

---

## 🔹 Difference Between Function and Procedure

- **Functions**: Must return a value (scalar or table).
- **Procedures**: May or may not return values, and can be invoked with `CALL` (not `SELECT`).  
  (Introduced in PostgreSQL 11).

---

## 🔹 Syntax of Procedure

```sql
CREATE [OR REPLACE] PROCEDURE procedure_name(param_list)
LANGUAGE plpgsql
AS $$
BEGIN
    -- procedural code here
END;
$$;
```

Call a procedure using:

```sql
CALL procedure_name(arguments);
```

---

## 🔹 Example 1: Simple Procedure

```sql
CREATE OR REPLACE PROCEDURE greet_user(p_name TEXT)
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE NOTICE 'Hello, %!', p_name;
END;
$$;

CALL greet_user('Manit');
```

**BTS (Behind the Scenes):**

- PostgreSQL compiles the procedure once and stores it in the system catalog.  
- When `CALL` is used, execution context is created, parameters are passed, and PL/pgSQL block executes.

---

## 🔹 Example 2: Inserting Data with Procedure

```sql
CREATE TABLE students (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    course VARCHAR(50)
);

CREATE OR REPLACE PROCEDURE add_student(p_name TEXT, p_course TEXT)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO students(name, course)
    VALUES (p_name, p_course);
    RAISE NOTICE 'Student % added successfully', p_name;
END;
$$;

CALL add_student('Alice', 'Math');
CALL add_student('Bob', 'Science');
```

---

## 🔹 Example 3: Transaction Management in Procedure

Procedures support **transactions** inside them using `COMMIT` and `ROLLBACK`.

```sql
CREATE OR REPLACE PROCEDURE transfer_funds(p_from INT, p_to INT, p_amount NUMERIC)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Deduct from sender
    UPDATE accounts
    SET balance = balance - p_amount
    WHERE acc_id = p_from;

    -- Add to receiver
    UPDATE accounts
    SET balance = balance + p_amount
    WHERE acc_id = p_to;

    COMMIT; -- Explicit transaction commit
END;
$$;

CALL transfer_funds(1, 2, 500);
```

**BTS:**  

- When called, Postgres executes updates inside a new transaction scope.  
- If an error occurs, the transaction can be rolled back.  

---

## 🔹 Example 4: Conditional Logic in Procedures

```sql
CREATE OR REPLACE PROCEDURE check_balance(p_acc INT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_balance NUMERIC;
BEGIN
    SELECT balance INTO v_balance FROM accounts WHERE acc_id = p_acc;

    IF v_balance < 1000 THEN
        RAISE NOTICE 'Low balance: %', v_balance;
    ELSE
        RAISE NOTICE 'Sufficient balance: %', v_balance;
    END IF;
END;
$$;

CALL check_balance(1);
```

---

## 🔹 Example 5: Loops in Procedures

```sql
CREATE OR REPLACE PROCEDURE print_numbers(n INT)
LANGUAGE plpgsql
AS $$
DECLARE
    i INT := 1;
BEGIN
    WHILE i <= n LOOP
        RAISE NOTICE 'Number: %', i;
        i := i + 1;
    END LOOP;
END;
$$;

CALL print_numbers(5);
```

**BTS:**  

- A loop is run inside the execution context.  
- Postgres evaluates loop condition and executes block repeatedly until condition fails.

---

## 🔹 Example 6: Procedure Calling Another Procedure

```sql
CREATE OR REPLACE PROCEDURE proc_a()
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE NOTICE 'Inside Procedure A';
END;
$$;

CREATE OR REPLACE PROCEDURE proc_b()
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE NOTICE 'Inside Procedure B';
    CALL proc_a();
END;
$$;

CALL proc_b();
```

**BTS:**

- Procedure `proc_b` starts execution.  
- Inside, `CALL proc_a()` invokes another stored procedure.  
- Execution stack is maintained internally by PostgreSQL.

---

## 🔹 Key Points About Stored Procedures

1. Called with `CALL`, not `SELECT`.
2. Can contain `COMMIT` and `ROLLBACK` (unlike functions).
3. Useful for batch jobs, data migration, transaction handling.
4. Do not return values directly (though OUT params can be used).

---

✅ Stored Procedures = **Reusable logic + Transaction control + Performance boost**.
