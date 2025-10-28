# Triggers in PostgreSQL

## 📌 What is a Trigger?

A **trigger** is a function that is automatically executed (or "fired") when certain events occur on a table or view.  
Events can be:

- `INSERT`
- `UPDATE`
- `DELETE`
- `TRUNCATE`

---

## 📌 Syntax

```sql
CREATE OR REPLACE FUNCTION trigger_function()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- logic here
    RETURN NEW; -- or OLD depending on event
END;
$$;

CREATE TRIGGER trigger_name
{ BEFORE | AFTER | INSTEAD OF } { INSERT | UPDATE | DELETE | TRUNCATE }
ON table_name
[ FOR EACH ROW | FOR EACH STATEMENT ]
EXECUTE FUNCTION trigger_function();
```

---

## 📌 Key Concepts

- **OLD**: Refers to the row before the change (valid in UPDATE, DELETE).
- **NEW**: Refers to the new row after the change (valid in INSERT, UPDATE).
- **TG_OP**: Contains the operation (`INSERT`, `UPDATE`, `DELETE`).
- **FOR EACH ROW**: Trigger fires for each affected row.
- **FOR EACH STATEMENT**: Trigger fires once per statement, regardless of affected rows.

---

## 📌 Examples

### 1. Logging Salary Changes

```sql
CREATE TABLE employees(
    emp_id INT PRIMARY KEY,
    name VARCHAR(50),
    salary NUMERIC
);

CREATE TABLE employees_logs(
    emp_id INT,
    old_salary NUMERIC,
    new_salary NUMERIC,
    changed_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION employees_trg()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.salary IS DISTINCT FROM OLD.salary THEN 
        INSERT INTO employees_logs(emp_id, old_salary, new_salary, changed_on)
        VALUES(OLD.emp_id, OLD.salary, NEW.salary, NOW());
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER employee_logs_trg
BEFORE UPDATE OF salary
ON employees
FOR EACH ROW
EXECUTE FUNCTION employees_trg();
```

**BTS**:

- When salary is updated, Postgres compares `OLD.salary` and `NEW.salary`.  
- If different, it inserts a log into `employees_logs`.  
- `RETURN NEW` ensures the updated row is written to the `employees` table.

---

### 2. Prevent Deletion (Soft Delete)

```sql
CREATE TABLE students(
    id INT PRIMARY KEY,
    name VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE
);

CREATE OR REPLACE FUNCTION prevent_delete()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE students SET is_active = FALSE WHERE id = OLD.id;
    RETURN NULL; -- prevents actual delete
END;
$$;

CREATE TRIGGER prevent_delete_trg
BEFORE DELETE ON students
FOR EACH ROW
EXECUTE FUNCTION prevent_delete();
```

**BTS**:

- When a row is deleted, trigger updates `is_active = FALSE`.  
- `RETURN NULL` prevents actual deletion.  

---

### 3. Auto-Update Timestamp

```sql
CREATE TABLE orders(
    order_id INT PRIMARY KEY,
    product VARCHAR(50),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.last_updated := NOW();
    RETURN NEW;
END;
$$;

CREATE TRIGGER update_orders_trg
BEFORE UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();
```

**BTS**:

- `NEW.last_updated := NOW()` updates the timestamp only for the row being modified.  
- Prevents the need to manually update timestamps.

---

### 4. Audit Trail

```sql
CREATE TABLE accounts(
    acc_id INT PRIMARY KEY,
    balance NUMERIC
);

CREATE TABLE audit_logs(
    acc_id INT,
    action VARCHAR(10),
    old_balance NUMERIC,
    new_balance NUMERIC,
    changed_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION acc_audit()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO audit_logs(acc_id, action, old_balance, new_balance)
        VALUES(NEW.acc_id, TG_OP, NULL, NEW.balance);

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit_logs(acc_id, action, old_balance, new_balance)
        VALUES(OLD.acc_id, TG_OP, OLD.balance, NEW.balance);
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER acc_audit_trg
AFTER INSERT OR UPDATE ON accounts
FOR EACH ROW
EXECUTE FUNCTION acc_audit();
```

**BTS**:

- Uses `TG_OP` to detect operation type (`INSERT`, `UPDATE`).  
- Logs balances accordingly.  

---

## 📌 When to Use Triggers

✅ Logging changes (audit trail)  
✅ Maintaining derived columns (e.g., timestamps)  
✅ Enforcing business rules (soft delete, constraints)  
✅ Replication or syncing data  

⚠️ Use carefully: Triggers add hidden logic → may cause debugging complexity.  

---

## 📌 Summary

- **Procedures**: Explicitly called.  
- **Functions (UDFs)**: Return values, used in queries.  
- **Triggers**: Implicitly executed on events.
