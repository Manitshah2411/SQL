/*
1. Basic pg_class, pg_attribute, pg_index
- List all tables in the public schema with their OIDs and owners.
- For the customer table, list all column names, data types, and OIDs.
- List all indexes on the customer table with their columns, whether they are unique or primary, and their sizes.
- Find which columns are indexed in all tables in the public schema.
- List all triggers on the customer table with trigger type (INSERT/UPDATE/DELETE) and status (enabled/disabled).
*/

----
SELECT 
    pc.oid,               -- OID of the table
    pc.relname,           -- Table name
    r.rolname             -- Owner name
FROM pg_class AS pc
JOIN pg_namespace AS n ON n.oid = pc.relnamespace   -- correct column is relnamespace, not realnamespace
JOIN pg_roles AS r ON r.oid = pc.relowner -- connecting the roles with the OID
WHERE pc.relkind = 'r' AND n.nspname = 'public'; -- filtering that it shows table and schema is public

----
SELECT 
    a.attname AS column_name,        -- Name of the column
    t.typname AS data_type,          -- Data type of the column
    a.attnum AS column_number,       -- Column number in table
    a.attrelid AS table_oid,         -- OID of the parent table
    a.attisdropped AS is_dropped     -- Indicates if column has been dropped
FROM pg_attribute a
JOIN pg_class c ON a.attrelid = c.oid
JOIN pg_type t ON a.atttypid = t.oid
WHERE c.relname = 'customer'       -- Table name
  AND a.attnum > 0                 -- Exclude system columns(where system column is allocated to negative attnum)
ORDER BY a.attnum;

----
SELECT
    i.relname AS index_name,                      -- Index name
    ix.indisunique AS is_unique,                  -- TRUE if unique index
    ix.indisprimary AS is_primary,               -- TRUE if primary key
    a.attname AS column_name,                     -- Column included in index
    pg_size_pretty(pg_relation_size(i.oid)) AS index_size  -- Human-readable size
FROM pg_class t
JOIN pg_index ix ON t.oid = ix.indrelid         -- Table OID links to pg_index
JOIN pg_class i ON i.oid = ix.indexrelid        -- Index OID links to pg_class
JOIN pg_attribute a ON a.attrelid = t.oid AND a.attnum = ANY(ix.indkey)  -- Columns in index
WHERE t.relname = 'customer'
ORDER BY i.relname, a.attnum;


----
SELECT 
	c.relname,
	n.nspname,
	a.attname,
	i.relname
FROM pg_class AS c
JOIN pg_namespace AS n ON n.oid = c.relnamespace
JOIN pg_index AS ix ON c.oid = ix.indrelid
JOIN pg_attribute AS a ON a.attrelid = c.oid AND a.attnum = ANY(ix.indkey)
JOIN pg_class AS i ON  i.oid = ix.indexrelid
WHERE n.nspname = 'public' AND c.relkind = 'r' AND a.attnum > 0



