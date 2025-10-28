SELECT
    c.column_name AS "Column Name",
    c.data_type AS "Data Type",
    c.is_nullable AS "Nullable",
    c.column_default AS "Default Value",
    CASE
        WHEN tc.constraint_type = 'PRIMARY KEY' THEN 'YES'
        ELSE 'NO'
    END AS "Primary Key",
    CASE
        WHEN tc.constraint_type = 'UNIQUE' THEN 'YES'
        ELSE 'NO'
    END AS "Unique Key",
    fk_info.referenced_table AS "FK Table",
    fk_info.referenced_column AS "FK Column",
    idx_info.index_name AS "Index Name",
    d.description AS "Comment"
FROM information_schema.columns c
LEFT JOIN information_schema.key_column_usage kcu
    ON c.table_name = kcu.table_name
    AND c.column_name = kcu.column_name
LEFT JOIN information_schema.table_constraints tc
    ON kcu.constraint_name = tc.constraint_name
    AND kcu.table_name = tc.table_name
LEFT JOIN (
    SELECT
        conname AS fk_name,
        conrelid::regclass AS table_name,
        a.attname AS column_name,
        confrelid::regclass AS referenced_table,
        af.attname AS referenced_column
    FROM pg_constraint c
    JOIN pg_attribute a ON a.attrelid = c.conrelid AND a.attnum = ANY(c.conkey)
    JOIN pg_attribute af ON af.attrelid = c.confrelid AND af.attnum = ANY(c.confkey)
    WHERE contype = 'f'
) AS fk_info
    ON fk_info.table_name::text = c.table_name
    AND fk_info.column_name = c.column_name
LEFT JOIN (
    SELECT
        t.relname AS table_name,
        i.relname AS index_name,
        a.attname AS column_name
    FROM pg_class t
    JOIN pg_index ix ON t.oid = ix.indrelid
    JOIN pg_class i ON i.oid = ix.indexrelid
    JOIN pg_attribute a ON a.attrelid = t.oid AND a.attnum = ANY(ix.indkey)
) AS idx_info
    ON idx_info.table_name = c.table_name
    AND idx_info.column_name = c.column_name
LEFT JOIN pg_description d
    ON d.objoid = ('public.' || c.table_name)::regclass
    AND d.objsubid = c.ordinal_position
WHERE c.table_name = 'customer'
ORDER BY c.ordinal_position;




SELECT *
FROM information_schema.columns
WHERE table_name = 'customer';

