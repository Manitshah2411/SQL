SELECT 
    pid, 
    usename, 
    datname, 
    state, 
    query 
FROM 
    pg_stat_activity 
WHERE 
    query LIKE 'SELECT * FROM customer%' 
    AND state = 'active';

SELECT 
    pid, 
    usename, 
    datname, 
    state, 
    query 
FROM 
    pg_stat_activity 
WHERE 
    query LIKE '%pg_sleep%' -- Changed this line
    AND state = 'active'
    AND query NOT LIKE '%pg_stat_activity%'; -- Prevents seeing the monitoring query itself


-- Window 1: The slow query
SELECT pg_sleep(30), * FROM customer;

-- Window 2
SELECT 
    phase, 
    heap_blks_scanned, 
    heap_blks_total,
    round(100.0 * heap_blks_scanned / heap_blks_total, 2) AS percentage_complete
FROM 
    pg_stat_progress_vacuum 
WHERE 
    pid = 2459;


SELECT 
    locktype, 
    relation::regclass, 
    mode, 
    granted 
FROM 
    pg_locks 
WHERE 
    pid = 2459;

