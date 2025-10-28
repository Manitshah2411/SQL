# ETL — The Complete Guide

> **Extract, Transform, Load** — end-to-end reference, concepts, patterns, examples and runnable snippets. Built to serve as a learning + reference .md you can use for notes, docs or as part of onboarding.

---

## Table of Contents

1. Overview: what is ETL
2. High-level flow & motivation
3. Detailed step: Extraction
   - Sources
   - Extraction types
   - Techniques & examples
4. Detailed step: Transformation
   - Cleansing, enrichment, joins, aggregations
   - Examples (SQL, Python/pandas)
   - Idempotency and testing
5. Detailed step: Load
   - Load patterns (full, incremental, upsert, partition swap)
   - SCD patterns
   - Examples (SQL MERGE / COPY)
6. ETL vs ELT vs Streaming vs CDC
7. Common architecture patterns (batch, lambda, kappa)
8. Tools & ecosystem (orchestration, ingestion, transform, sink)
9. Implementation examples (end-to-end):
   - Simple Python ETL (Postgres source → CSV → Postgres target)
   - ELT with dbt (raw → staging → marts)
   - CDC with Debezium → Kafka → Postgres
   - Airflow DAG example
10. Data quality, testing and observability
11. Security, governance, compliance
12. Performance tuning & cost controls
13. Operational patterns — retries, idempotency, backfills
14. Glossary & cheat sheet (commands, SQL snippets)
15. References & further reading

---

## 1. Overview: what is ETL

**ETL** stands for *Extract, Transform, Load*. It is a set of processes that reliably moves data from one or more sources into a target system (data warehouse, data lake, analytics DB) while transforming it into a structure useful for analytics, reporting, or ML. ETL pipelines are the backbone of analytics and data engineering.

**Key goals:** reliability, correctness, observability, repeatability, and performance.

---

## 2. High-level flow & motivation

1. **Extract** raw data from operational systems (OLTP DBs, API, logs).
2. **Stage** raw data (store as immutable copy: files, staging DB/schema).
3. **Transform** data: clean, enrich, aggregate, validate.
4. **Load** transformed data into target (warehouse, lakehouse, OLAP).
5. **Consume**: BI tools, ML models, dashboards.

Why not just query source? Operational systems are tuned for transactions, not analytics. ETL isolates analytical workloads and adds correctness/lineage.

---

## 3. Detailed step: Extraction

### 3.1 Sources

- Relational DBs (Postgres, MySQL, Oracle)
- Logs and event streams (Kafka, Kinesis)
- Files (CSV, JSON, Parquet) in object storage (S3/GCS/ADLS)
- APIs (REST, GraphQL)
- SaaS (Salesforce, Stripe) — via connectors
- IoT / telemetry

### 3.2 Extraction types

- **Full load:** copy entire table (initial load, rarely for production daily loads)
- **Incremental load:** copy only new/changed rows (uses `last_modified`, high-watermark, or CDC)
- **CDC (Change Data Capture):** read DB transaction logs (WAL, binlog) for row-level changes
- **Streaming / event-based extraction:** push events to pipeline in near real-time

### 3.3 Extraction techniques & examples

Technique: simple incremental SQL (timestamp high-watermark)

```sql
-- extract orders after last processed timestamp
SELECT * FROM sales.orders
WHERE updated_at > '2025-10-19 00:00:00';
```

**Technique: batch export with `COPY` (server-side)**

```sql
COPY (SELECT * FROM sales.orders WHERE order_date >= '2025-10-01') TO '/tmp/orders.csv' CSV HEADER;
```

**Technique: client-side `\copy` (psql) — writes to local client machine**

```sql
\copy (SELECT * FROM ml.customer_features) TO '/Users/me/Downloads/features.csv' CSV HEADER
```

Technique: API pagination (Python example)

```python
import requests
url = 'https://api.example.com/orders'
params = {'page': 1}
rows = []
while True:
    r = requests.get(url, params=params)
    data = r.json()
    rows.extend(data['items'])
    if not data['next_page']:
        break
    params['page'] += 1
```

Technique: CDC (Debezium) (conceptual)

- Debezium reads database transaction log and emits change events (INSERT/UPDATE/DELETE) into Kafka topics. Consumers subscribe and apply changes to destination or upstream processors.

## Best practices for extraction

- Prefer replicas for heavy reads.
- Limit extraction window (e.g., per day) to avoid huge transactions.
- Store raw extracted files as immutable copies to enable replays.
- Track schema and row counts for validation.

---

## 4. Detailed step: Transformation

Transformation is where raw bits become analytics-ready.

### 4.1 Typical transform tasks

- Data cleansing: trim, normalize case, fix formats
- Type casting and null handling
- Filtering out irrelevant rows
- Deduplication using natural keys + timestamps
- Enrichment: join with reference/master data (geography, product categories)
- Derived columns: compute totals, flags, categories
- Aggregations / rollups
- SCD handling for dimension tables

### 4.2 Examples

## Example: clean & derive with SQL (in staging schema)

```sql
CREATE TABLE staging.clean_orders AS
SELECT
  order_id,
  customer_id,
  order_date::date AS order_date,
  COALESCE(total_amount, 0)::numeric(12,2) AS total_amount,
  (COALESCE(total_amount,0) - COALESCE(shipping_cost,0)) AS net_amount
FROM raw.orders
WHERE order_date IS NOT NULL;
```

## Example: dedupe with window function

```sql
CREATE TABLE staging.orders_dedup AS
SELECT * FROM (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY updated_at DESC) rn
  FROM staging.clean_orders
) t WHERE rn = 1;
```

## Example: Python/pandas transform**

```python
import pandas as pd
orders = pd.read_csv('orders.csv')
# clean strings
orders['customer_name'] = orders['customer_name'].str.strip().str.title()
# compute derived
orders['net'] = orders['quantity'] * orders['unit_price']
# drop nulls
orders = orders.dropna(subset=['customer_id'])
orders.to_parquet('orders_transformed.parquet')
```

### 4.3 Idempotency & testing

- Design transforms to be re-runnable (idempotent): e.g., insert with `MERGE` or replace partition.
- Use unit tests (dbt tests, Great Expectations) to validate transforms on sample data.

---

## 5. Detailed step: Load

### 5.1 Load strategies

- **Full load** (truncate & insert): simple but expensive
- **Incremental load** (append, upsert/merge): efficient for ongoing loads
- **Partition swap / replace**: create new partition and atomically swap to minimize locks
- **Append-only / event sourcing**: keep immutable append-only table

### 5.2 Upsert / MERGE example (Postgres 15+)

```sql
-- target: analytics.customer_sales_summary
INSERT INTO analytics.customer_sales_summary (customer_id, total_spent, last_order)
SELECT customer_id, total_spent, last_order
FROM staging.customer_agg
ON CONFLICT (customer_id) DO UPDATE
SET total_spent = EXCLUDED.total_spent,
    last_order = EXCLUDED.last_order;
```

## MERGE (ANSI pattern)

```sql
MERGE INTO analytics.customer_sales_summary t
USING staging.customer_agg s
ON t.customer_id = s.customer_id
WHEN MATCHED THEN
  UPDATE SET total_spent = s.total_spent, last_order = s.last_order
WHEN NOT MATCHED THEN
  INSERT (customer_id, total_spent, last_order) VALUES (s.customer_id, s.total_spent, s.last_order);
```

### 5.3 Partition swap example (Hive/S3 / Snowflake stage)

- Write data for new day into `staging/partition=2025-10-19/part-*.parquet`, then `ALTER TABLE ... EXCHANGE PARTITION` or COPY INTO to target partition.

### 5.4 Slowly Changing Dimensions (SCD)

- **SCD Type 0:** no history
- **SCD Type 1:** overwrite attributes
- **SCD Type 2:** keep history with `effective_date`, `end_date` (recommended for auditing)

## SCD Type 2 example (conceptual SQL)

```sql
-- Upsert logic: if dim change detected, set current row end_date and insert new row
UPDATE dim.customer SET end_date = now() WHERE customer_key = v_key AND end_date IS NULL;
INSERT INTO dim.customer (customer_key, name, start_date, end_date) VALUES (..., now(), NULL);
```

---

## 6. ETL vs ELT vs Streaming vs CDC (short)

- **ETL:** transform before load. Good if transforms are heavy or require non-SQL code.
- **ELT:** load raw data then transform in target (data warehouse). Great with scalable cloud warehouses + dbt.
- **Streaming / Kappa:** everything is a stream; process in streaming engines (Flink, Kafka Streams). Good for low-latency needs.
- **CDC:** method to capture row-level changes for near-real-time replication.

---

## 7. Common architecture patterns

- **Batch ETL:** scheduled jobs (Airflow) — simple and robust.
- **Lambda:** speed/accuracy dual path (fast stream + batch reconciliation).
- **Kappa:** single streaming pipeline with reprocessing via log replay.
- **Data Lake + Lakehouse:** store raw parquet, use Delta/iceberg for ACID & versioning.

---

## 8. Tools & ecosystem (by layer)

- **Orchestration:** Airflow, Prefect, Dagster
- **Ingestion / Connectors:** Fivetran, Stitch, Kafka Connect, Logstash
- **CDC:** Debezium, Maxwell, AWS DMS
- **Transform:** dbt (SQL), Spark, Flink
- **Storage:** Snowflake, BigQuery, Redshift, Postgres, S3 (Parquet + Iceberg/Delta)
- **Monitoring / DQ:** Monte Carlo, Great Expectations, custom metrics + Prometheus/Grafana

---

## 9. Implementation examples

### 9.1 Simple Python ETL (Postgres → CSV → Postgres)

### extract_transform_load.py

```python
import pandas as pd
import sqlalchemy

SRC = "postgresql://user:pwd@source-host:5432/shop"
DST = "postgresql://user:pwd@analytics-host:5432/warehouse"

src_engine = sqlalchemy.create_engine(SRC)
dst_engine = sqlalchemy.create_engine(DST)

# 1) extract
orders = pd.read_sql("SELECT * FROM sales.orders WHERE order_date >= CURRENT_DATE - INTERVAL '7 days'", src_engine)

# 2) transform
orders['order_date'] = pd.to_datetime(orders['order_date']).dt.date
orders['net'] = orders['quantity'] * orders['unit_price']
orders = orders.dropna(subset=['customer_id'])

# 3) load (upsert using temp table and SQL merge)
orders.to_sql('tmp_orders', dst_engine, if_exists='replace', index=False)
with dst_engine.begin() as conn:
    conn.execute("""
    INSERT INTO analytics.orders (order_id, customer_id, order_date, net)
    SELECT order_id, customer_id, order_date, net FROM tmp_orders
    ON CONFLICT (order_id) DO UPDATE SET net = EXCLUDED.net
    """)
```

### 9.2 ELT with dbt (conceptual)

- Ingest raw data into schema `raw.*`
- dbt models:
  - `stg_orders.sql` (cleaning)
  - `mart_customer_sales.sql` (aggregations)
- dbt run -> creates materialized tables/views in `analytics` schema

Sample dbt model `stg_orders.sql`:

```sql
with raw as (
  select * from raw.orders
)
select
  order_id,
  customer_id,
  cast(order_date as date) as order_date,
  coalesce(total_amount,0)::numeric(12,2) as total_amount
from raw
where order_date is not null;
```

### 9.3 CDC (Debezium) — conceptual

- Debezium connector reads PostgreSQL WAL and writes change events to Kafka topics `db.public.orders`.
- Kafka Connect sink writes to Snowflake or a replica Postgres.
- Stream processor (Flink) computes real-time metrics.

### 9.4 Airflow DAG example (simplified)

```python
from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime

default_args = {'owner': 'data_engineer'}
with DAG('daily_etl', start_date=datetime(2025,10,1), schedule_interval='@daily', default_args=default_args) as dag:
    extract = BashOperator(task_id='extract', bash_command='python extract.py')
    transform = BashOperator(task_id='transform', bash_command='python transform.py')
    load = BashOperator(task_id='load', bash_command='python load.py')
    extract >> transform >> load
```

---

## 10. Data quality, testing & observability

- Row counts, column-level checks, null-rate checks
- Referential integrity checks
- Data drift monitoring (distributions)
- Unit testing transforms (dbt tests, pytest)
- SLA alerting for job runtimes
- Lineage & metadata tracking (OpenLineage, Amundsen)

**Example checks (SQL):**

```sql
-- check missing customer ids
SELECT COUNT(*) FROM staging.orders WHERE customer_id IS NULL;
-- check distinct counts vs source
SELECT (SELECT COUNT(*) FROM raw.orders) as src, (SELECT COUNT(*) FROM staging.orders) as staging;
```

---

## 11. Security, governance & compliance

- Encryption (TLS in transit, SSE-at-rest)
- Least privilege IAM roles for services
- Audit logging of pipeline runs and data access
- PII masking/anonymization, pseudonymization
- Data retention and deletion policies (GDPR Right to be forgotten)

---

## 12. Performance tuning & cost control

- Bulk APIs (COPY, Snowflake `COPY INTO`) instead of row-by-row inserts
- Partitioning by date to limit scans
- Use columnar formats (Parquet/ORC) for analytics
- Use replication / read replicas for extraction
- Monitor and optimize expensive SQL (EXPLAIN ANALYZE)

---

## 13. Operational patterns — retries, idempotency, backfills

- Implement exponential backoff retries for transient failures
- Design idempotent tasks: `MERGE` or `INSERT ... ON CONFLICT` or replace partition pattern
- Backfill strategy: run historical job in controlled window, mark audit logs

---

## 14. Glossary & cheat sheet

- **CDC** — Change Data Capture
- **ELT** — Extract, Load, Transform
- **SCD** — Slowly Changing Dimensions
- **High watermark** — max timestamp or numeric id processed so far
- **Idempotent** — safe to run many times

***Quick commands***

- `COPY` (server-side): `COPY (SELECT ...) TO '/tmp/out.csv' CSV HEADER;`
- `\copy` (client-side): `\copy (SELECT ...) TO '/local/out.csv' CSV HEADER;`
- `EXPLAIN ANALYZE <query>` — profile query

---

## 15. References & further reading

- [dbt docs](https://docs.getdbt.com)
- [Debezium](https://debezium.io)
- Designing Data-Intensive Applications — Martin Kleppmann
- Streaming systems: Apache Flink docs

---

## Appendices — Example: Full end-to-end mini-pipeline (code)

### A. Full minimal Python ETL runnable outline (pseudo)

```python
# etl_job.py
from datetime import date
import pandas as pd
import sqlalchemy

SRC = 'postgresql://user:pwd@localhost:5432/source'
DST = 'postgresql://user:pwd@localhost:5432/warehouse'
src = sqlalchemy.create_engine(SRC)
dst = sqlalchemy.create_engine(DST)

# extract
since = date.today().isoformat()
df = pd.read_sql('SELECT * FROM sales.orders WHERE order_date >= %s', src, params=[since])

# transform
# (clean, dedupe, derive)
df['net'] = df['quantity'] * df['unit_price']
df = df.dropna(subset=['customer_id'])

# load (upsert pattern)
df.to_sql('tmp_orders', dst, if_exists='replace', index=False)
with dst.begin() as conn:
    conn.execute("""
    INSERT INTO analytics.orders (order_id, customer_id, net) SELECT order_id, customer_id, net FROM tmp_orders
    ON CONFLICT (order_id) DO UPDATE SET net = EXCLUDED.net
    """)
```

---

### B. Example: dbt model dependency (concept)

- `models/stg_orders.sql` -> `models/mart_customer_sales.sql`
- dbt `schema.yml` contains tests and documentation

---

## End of document
