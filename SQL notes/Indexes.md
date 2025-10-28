# 📌 Indexes in Databases

Indexes in a database are special data structures that **improve the speed of data retrieval** at the cost of additional storage and write overhead.  
Think of them as the **table of contents** in a book — instead of flipping through every page (full table scan), you jump directly to the section (row) using the index.

---

## 🔹 Why Indexes?

- Faster **SELECT** queries.
- Useful for **WHERE**, **JOIN**, **ORDER BY**, **GROUP BY**.
- Can enforce **uniqueness**.
- Trade-off: more **disk usage** + **slower INSERT/UPDATE/DELETE** (since indexes must be updated too).

---

## Types of Indexes

---

## 1. **B-Tree Index (Default)**

- Most common index type.
- Balanced tree structure, supports:
  - Equality (=)
  - Range queries (`<`, `>`, `BETWEEN`)
  - Sorting (`ORDER BY`)
- Default in PostgreSQL, MySQL, Oracle.

**Example:**

```sql
CREATE INDEX idx_product_price ON products(price);
```

**BTS:**

- DB creates a **balanced binary tree**.
- Each lookup traverses from root → branch → leaf in `O(log n)`.
- Supports range scans efficiently.

---

## 2. **Hash Index**

- Based on hash tables.
- Very fast for equality (`=`) lookups.
- Not good for ranges.

**Example:**

```sql
CREATE INDEX idx_product_name_hash ON products USING hash(pname);
```

**BTS:**

- DB computes a hash value of the column.
- Direct lookup in hash buckets (`O(1)` avg).
- No ordering, so `BETWEEN` or `ORDER BY` is slow.

---

## 3. **GIN (Generalized Inverted Index)**

- Best for **arrays, JSONB, full-text search**.
- Stores a map of values → row locations.

**Example (full-text):**

```sql
CREATE INDEX idx_doc_content_gin 
ON documents USING gin(to_tsvector('english', content));
```

**BTS:**

- Splits text into tokens (words).
- Each token points to the rows where it appears.
- Super fast `WHERE content @@ 'keyword'`.

---

## 4. **GiST (Generalized Search Tree)**

- Flexible index for complex data:
  - Geometric types
  - Full-text
  - Ranges

**Example:**

```sql
CREATE INDEX idx_locations_gist 
ON places USING gist(coordinates);
```

**BTS:**

- Works like a customizable B-Tree.
- Stores bounding boxes → prunes irrelevant data fast.

---

## 5. **SP-GiST (Space-Partitioned GiST)**

- Partitioned tree for data with **non-balanced distribution**.
- Good for:
  - Phone numbers
  - IP addresses
  - Hierarchies

**Example:**

```sql
CREATE INDEX idx_network_spgist 
ON devices USING spgist(ip_address);
```

**BTS:**

- Splits space into partitions (tries, quadtrees).
- Handles skewed data efficiently.

---

## 6. **BRIN (Block Range Index)**

- Lightweight index.
- Stores summary of **block ranges** (min/max).
- Great for large sequential data (time-series).

**Example:**

```sql
CREATE INDEX idx_sales_date_brin 
ON sales USING brin(sale_date);
```

**BTS:**

- Instead of indexing every row, stores min/max per block.
- Super small index size.
- Best for append-only tables.

---

## 7. **Clustered Index**

- **Physically orders the rows** based on index.
- Only **one clustered index** per table.
- Non-clustered indexes point to clustered index.

**Example (SQL Server/MySQL):**

```sql
CREATE CLUSTERED INDEX idx_order_id ON orders(order_id);
```

**BTS:**

- Rows stored in the order of index.
- Fast retrieval, but costly inserts (reordering).

---

## 8. **Non-Clustered Index**

- Default type (when clustered is not specified).
- Stores index separately from the actual table data.
- Can have **multiple per table**.

**Example:**

```sql
CREATE INDEX idx_customer_name ON customers(name);
```

**BTS:**

- Index entries point to the row location.
- Faster than scanning, but one extra lookup step.

---

## 9. **Unique Index**

- Ensures no duplicate values in the column.
- Enforces constraints.

**Example:**

```sql
CREATE UNIQUE INDEX idx_email_unique ON users(email);
```

**BTS:**

- Works like normal index but prevents duplicate inserts.

---

## 10. **Composite Index (Multi-Column)**

- Index on multiple columns.
- Useful when queries filter on multiple fields.

**Example:**

```sql
CREATE INDEX idx_orders_customer_date 
ON orders(customer_id, order_date);
```

**BTS:**

- Ordered first by `customer_id`, then by `order_date`.
- Efficient if queries use **left-most columns**.

---

## 11. **Partial / Filtered Index**

- Index on **subset of rows**.
- Saves space and speeds up selective queries.

**Example:**

```sql
CREATE INDEX idx_active_users 
ON users(last_login) WHERE active = true;
```

**BTS:**

- Only stores rows that match filter condition.
- Great for large tables with rare conditions.

---

## 12. **Covering Index / INCLUDE Index**

- Index includes extra columns (not part of search key).
- Reduces need to read full row.

**Example (Postgres):**

```sql
CREATE INDEX idx_orders_customer 
ON orders(customer_id) INCLUDE(order_date, amount);
```

**BTS:**

- Search key = `customer_id`.
- Extra columns (`order_date`, `amount`) are stored with index → avoids table lookup.

---

## 13. **Rowstore Index**

- Default index type in OLTP systems.
- Stores rows sequentially.
- Great for transactional workloads.

**Example:**

```sql
-- In SQL Server: Rowstore is default
CREATE INDEX idx_employee_name ON employees(name);
```

**BTS:**

- Optimized for **row-based reads/writes**.
- Fast for point lookups.

---

## 14. **Columnstore Index**

- Stores data **column by column** instead of row by row.
- Great for analytics and aggregation queries.

**Example (SQL Server):**

```sql
CREATE COLUMNSTORE INDEX idx_sales 
ON sales(product_id, sale_date, amount);
```

**BTS:**

- Compression is very high (same type values together).
- Blazing fast aggregations on large data sets.

---

## 15. **Bitmap Index** (Oracle, PostgreSQL extension)

- Efficient for low-cardinality columns (few unique values).
- Uses **bitmaps** to represent values.

**Example (Oracle):**

```sql
CREATE BITMAP INDEX idx_gender ON employees(gender);
```

**BTS:**

- Stores a bit array for each distinct value.
- Very compact and fast for `WHERE gender = 'M' OR gender = 'F'`.

---

## ⚡ Summary Table

| Index Type       | Best For                          | BTS Key Idea                    |
|------------------|-----------------------------------|---------------------------------|
| B-Tree           | Equality + range queries          | Balanced tree traversal         |
| Hash             | Equality only                     | Hash buckets lookup             |
| GIN              | Full-text, JSONB, arrays          | Inverted index (token → rows)   |
| GiST             | Geometric/range queries           | Custom balanced tree            |
| SP-GiST          | Skewed, partitioned data          | Partitioned search tree         |
| BRIN             | Large sequential, time-series     | Block summaries (min/max)       |
| Clustered        | Primary ordering of rows          | Physical row order              |
| Non-clustered    | General queries                   | Pointer to table rows           |
| Unique           | Constraints, primary keys         | Prevents duplicates             |
| Composite        | Multi-column filtering            | Left-most column priority       |
| Partial/Filtered | Subset of rows                    | Index only filtered rows        |
| Covering/Include | Extra columns in index            | Avoids extra row lookup         |
| Rowstore         | OLTP workloads                    | Row-based storage               |
| Columnstore      | Analytics, aggregations           | Column-based compression        |
| Bitmap           | Low-cardinality categorical data  | Bit array representation        |

---

## ✅ Final Notes

- Always index columns used in **WHERE**, **JOIN**, **ORDER BY**.
- Don’t over-index → slows down writes.
- Use the right type depending on workload (OLTP = rowstore, OLAP = columnstore).
