# Recursive CTEs in SQL

Recursive CTEs allow you to express **hierarchical or iterative queries** in SQL.  
They are powerful but can be tricky to fully understand. This document explains **concepts, execution flow, working sets, and pitfalls**.

---

## 🔹 1. Basic Structure

```sql
WITH RECURSIVE cte_name AS (
    -- Anchor member (base case)
    SELECT ...
    FROM table
    WHERE condition   -- usually finds the "root" rows

    UNION ALL

    -- Recursive member (iterative step)
    SELECT ...
    FROM table t
    INNER JOIN cte_name c
        ON t.parent_id = c.id
)
SELECT * FROM cte_name;
```

## Recursive CTE Components

- **Anchor member** → runs once, finds the starting rows.  
- **Recursive member** → repeatedly runs using the previous iteration’s results.  
- **UNION ALL** → stacks results (don’t use `UNION` unless you want to remove duplicates).  

## 🔹 2. Execution Flow (Step by Step)

1. **Run Anchor Query**
   - Executes once.
   - Result → placed into the working table (**W0**).
   - Added to the final result set (**R**).

2. **Recursive Iteration (Loop Begins)**
   - Take the working table from the previous step (**Wi**).
   - Feed it into the recursive part of the query.
   - Result → new working table (**Wi+1**).
   - Append **Wi+1** rows to the final result set (**R**).
   - Repeat Step 2 until the working table is empty.

3. **Stop Condition**
   - Recursion stops when no new rows are generated.
   - Or if the engine hits the `max_recursion_depth` limit
     (100 by default in SQL Server, unlimited in PostgreSQL unless set manually).

---

## 🔹 3. Example: Employee Hierarchy

```sql
WITH RECURSIVE employee_hierarchy AS (
    -- Anchor: find top-level boss (CEO)
    SELECT 
        employeeid, 
        firstname, 
        managerid, 
        1 AS level
    FROM sales.employees
    WHERE managerid IS NULL

    UNION ALL

    -- Recursive: find subordinates
    SELECT 
        e.employeeid, 
        e.firstname, 
        e.managerid, 
        h.level + 1
    FROM sales.employees e
    INNER JOIN employee_hierarchy h
        ON e.managerid = h.employeeid
)
SELECT * 
FROM employee_hierarchy;
```

---

## 🔹 4. Line-by-Line Execution of Example

1. Run anchor (`WHERE managerid IS NULL`) → finds CEO(s).  
   - Store rows into **W0** and **R**.  
2. Use **W0** in recursive part:  
   - Find employees whose `managerid = CEO’s id`.  
   - Store into **W1**, append to **R**.  
3. Use **W1** in recursive part:  
   - Find employees whose `managerid = employees in W1`.  
   - Store into **W2**, append to **R**.  
4. Continue until **Wi = ∅**.  
5. Return **R** as final output.  

---

## 🔹 5. Key Concepts

- **Working Table (Wi):**  
  Temporary result of the last iteration, fed into the next.  

- **Result Set (R):**  
  Collects all anchor + recursive results.  

- **Termination:**  
  Stops when **Wi** is empty.  

- **Potential Infinite Loop:**  
  Happens if:  
  - Bad join condition (`ON` matches incorrectly).  
  - Cyclic data (e.g., manager references themselves).  

---

## 🔹 6. Common Pitfalls

- **Cycles in data**  
  → Can cause infinite recursion.  
  Fix: Add `WHERE` or `CYCLE` detection.  

- **Exploding results**  
  → A wrong join may multiply rows.  
  Check conditions carefully.  

- **Performance**  
  → Recursive CTEs can be slow for very deep trees.  
  Consider indexing `parent_id`.  

---

## 🔹 7. Best Practices

- Start with **anchor first** to check base rows.  
- Run **recursive part separately** with sample input.  
- Use **`UNION ALL`** unless deduplication is required.  
- Add a recursion depth limit in PostgreSQL for safety:  

  ```sql
  SET max_recursion_depth = 1000;
  ```

---

## 🔹 8. Visualization of Execution

- **Iteration 0** → Run Anchor Query → `W0` → `R`  
- **Iteration 1** → Run Recursive with `W0` → `W1` → `R`  
- **Iteration 2** → Run Recursive with `W1` → `W2` → `R`  
- **Iteration 3** → Run Recursive with `W2` → `W3` → `R`  
- ...  
- **Stop** when `Wi = ∅`  
- **Return** `R` (final result set)
