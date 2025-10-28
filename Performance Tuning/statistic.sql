SELECT
    n.nspname AS SchemaName,
    c.relname AS TableName,
    -- In PostgreSQL, 'StatisticName' typically refers to column-level stats or index names.
    -- For table-level activity similar to the screenshot, we'll use the TableName itself
    -- or, if you specifically want index stats, you'd join with pg_stat_user_indexes.
    -- Here, we'll use the table name for context.
    c.relname AS StatisticName,
    s.last_autoanalyze::date AS LastUpdateDay, -- Date of the last automatic analyze operation
    s.last_autoanalyze AS LastUpdateDate, -- Full timestamp of the last automatic analyze operation
    s.n_live_tup AS Rows, -- Number of live tuples (rows) in the table
    (s.n_tup_ins + s.n_tup_upd + s.n_tup_del) AS TotalModifications -- Total insertions + updates + deletions recorded by the stats collector
FROM
    pg_class c -- System catalog table for relations (tables, indexes, etc.)
JOIN
    pg_namespace n ON n.oid = c.relnamespace -- System catalog table for schemas
JOIN
    pg_stat_user_tables s ON s.relid = c.oid -- Statistics view for user tables
WHERE
    c.relkind = 'r' -- Filter for regular tables ('r')
    AND n.nspname NOT IN ('pg_catalog', 'information_schema', 'pg_toast') -- Exclude system schemas
ORDER BY
    n.nspname, c.relname;



CREATE EXTENSION IF NOT EXISTS pg_repack;