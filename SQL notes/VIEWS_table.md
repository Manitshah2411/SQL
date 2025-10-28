# SQL Views: A Complete Guide

## 🔹 What is a View?

[](Diagrams/VIEWS_Use_case.png)
[](Diagrams/VIEWS_Use_case_.png)

A **View** in SQL is a **virtual table** based on the result of a query.

- Unlike a normal table, it does not store data physically (unless it’s a **Materialized View**).
- It provides a **window** into the data stored in base tables.

---

## 🔹 Why Use Views?

### Simplification

- Hide complex queries behind a simple name.
- Example: Instead of writing a long `JOIN` every time, create a view.

### Security

- Expose only selected columns/rows to users.
- Example: Show customer names but hide credit card numbers.

### Consistency

- Ensure business rules are applied consistently (e.g., a view always calculates discounts in the same way).

### Abstraction

- Separate logical data representation from physical storage.

---

## 🔹 Normal Table vs View Table

| Feature      | **Normal Table (Base Table)** | **View Table (Virtual Table)** |
|--------------|-------------------------------|--------------------------------|
| **Definition** | Physically stores data. | Logical/virtual table based on a query. |
| **Data Storage** | Data is stored in DB. | No storage (except materialized views). |
| **Updates** | `INSERT`, `UPDATE`, `DELETE` allowed. | Usually **read-only** (some can be updated). |
| **Performance** | Faster (data pre-stored). | Slightly slower (query runs each time). |
| **Use Case** | Permanent raw/transactional data. | Abstraction, security, simplified reporting. |

---

## SQL Views: Creating, Updating, and Using Views

## 🔹 Creating a View

``` sql
-- Create a view for monthly sales
CREATE VIEW monthly_sales AS
SELECT
    DATE_TRUNC('month', sale_date) AS month,
    SUM(amount) AS total_sales
FROM sales
GROUP BY DATE_TRUNC('month', sale_date);
```

Now you can query it like a table:

``` sql
SELECT * FROM monthly_sales;
```

---

## 🔹 Updating a View

By default, views are **read-only**.

However, some views are **updatable** if: - They reference a single
table. - No `GROUP BY`, `DISTINCT`, `HAVING`, `UNION`. - No aggregate
functions (`SUM`, `AVG`, etc.).

✅ Example of **updatable view**:

``` sql
CREATE VIEW active_customers AS
SELECT customer_id, name, email
FROM customers
WHERE active = true;

-- You can update through this view:
UPDATE active_customers
SET email = 'new@mail.com'
WHERE customer_id = 101;
```

❌ Example of **non-updatable view**:

``` sql
CREATE VIEW customer_stats AS
SELECT customer_id, COUNT(order_id) AS total_orders
FROM orders
GROUP BY customer_id;
```

Here, you **cannot update** because it uses `GROUP BY`.

---

## 🔹 Materialized Views

A **Materialized View** is like a normal view but it stores the result
**physically**.

- Faster for repeated queries, especially aggregations.
- Must be refreshed to update data.

Example:

``` sql
-- Create a materialized view
CREATE MATERIALIZED VIEW monthly_sales_mv AS
SELECT
    DATE_TRUNC('month', sale_date) AS month,
    SUM(amount) AS total_sales
FROM sales
GROUP BY DATE_TRUNC('month', sale_date);

-- Refresh when data changes
REFRESH MATERIALIZED VIEW monthly_sales_mv;
```

---

## 🔹 Advantages of Views

✅ Simplify complex queries\
✅ Improve security (restrict access)\
✅ Maintain consistency\
✅ Provide abstraction for BI tools (Power BI, Tableau, etc.)

---

## 🔹 Disadvantages of Views

❌ Performance overhead (query runs each time for normal views)\
❌ Not all views are updatable\
❌ Dependency on base tables (if table structure changes, views may
break)\
❌ Materialized views need manual refresh

---

## 🔹 When to Use Views?

✅ When you want to simplify queries for analysts.\
✅ When you need to restrict access to sensitive data.\
✅ When creating reusable data models for reporting.

❌ Avoid using views for write-heavy workloads (performance hit).\
❌ Avoid too many nested views (difficult to debug).
