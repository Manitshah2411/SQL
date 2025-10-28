-- Basic
SELECT indexname, indexdef
FROM pg_indexes WHERE tablename = 'customer';

SELECT * FROM pg_index
WHERE tablename = 'customer';

/*
Tables → regular tables (relkind = 'r')
Indexes → B-tree, GIN, GiST, etc. (relkind = 'i')
Sequences → auto-increment counters (relkind = 'S')
Views → logical tables (relkind = 'v')
Materialized views → (relkind = 'm')
TOAST tables → storage for large objects (relkind = 't')
*/
SELECT * FROM pg_class 
WHERE relkind = 'r'

SELECT 
    t.relname AS table_name,
    i.relname AS index_name,
    ix.indisunique AS is_unique,
    ix.indisprimary AS is_primary,
    a.attname AS column_name
FROM pg_class t
JOIN pg_index ix ON t.oid = ix.indrelid
JOIN pg_class i ON i.oid = ix.indexrelid
JOIN pg_attribute a ON a.attrelid = t.oid AND a.attnum = ANY(ix.indkey)
WHERE t.relname = 'customer';

SELECT * FROM pg_attribute

SELECT
    s.schemaname,
    s.relname AS table_name,
    s.indexrelname AS index_name,
    s.idx_scan AS times_used,
    pg_size_pretty(pg_relation_size(s.indexrelid)) AS index_size,
	column_name
FROM pg_stat_user_indexes s
JOIN pg_index i ON i.indexrelid = s.indexrelid
JOIN pg_class t ON t.oid = i.indexrelid
JOIN pg_attribute a ON a.attrelid = t.oid 
ORDER BY pg_relation_size(s.indexrelid) DESC;


