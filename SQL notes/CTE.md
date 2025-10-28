# 📘 Common Table Expressions (CTEs) in SQL

A **Common Table Expression (CTE)** is a temporary result set defined within the execution scope of a single query.  
They make SQL queries easier to read, maintain, and reuse by breaking down complex logic into smaller steps.  

---

## 🔹 1. Syntax of a CTE

```sql
WITH cte_name AS (
    SELECT ...
)
SELECT *
FROM cte_name;
```
