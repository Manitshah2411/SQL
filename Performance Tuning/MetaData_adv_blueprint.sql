
/*
1. System Catalog Tables (pg_catalog)

These are the foundational, low-level tables that store all the metadata for the database.
Core Database Objects
pg_database: All databases in the cluster
pg_class: Tables, indexes, sequences, views (all "relations")
pg_attribute: Columns of tables ("attributes")
pg_namespace: Schemas
pg_type: Data types
pg_index: Index information
pg_sequence: Sequence information
pg_constraint: Check, primary key, unique, foreign key, and exclusion constraints
pg_depend: Dependency relationships between database objects
pg_description: Comments on database objects
pg_attrdef: Column default values
Users, Roles, and Permissions
pg_authid: Roles (users and groups)
pg_auth_members: Role membership
pg_default_acl: Default permissions for objects
pg_shdescription: Shared comments on database objects
Functions, Operators, and Languages
pg_proc: Functions and procedures
pg_language: Programming languages for functions (like PL/pgSQL)
pg_operator: Operators (e.g., +, -, *)
pg_opclass: Operator classes for index access methods
pg_opfamily: Operator families
pg_am: Index access methods (e.g., B-tree, Hash, GiST)
pg_cast: Casts (data type conversions)
pg_conversion: Character set encoding conversions
Advanced and Internal Features
pg_trigger: Triggers on tables
pg_rewrite: Rules for the query rewrite system
pg_publication: Publication information for logical replication
pg_subscription: Subscription information for logical replication
pg_partitioned_table: Information about partitioned tables
pg_policy: Row-level security policies
pg_event_trigger: Event triggers
pg_tablespace: Tablespaces (locations on disk)

2. System Views
These are the user-friendly interfaces for accessing the catalog data and real-time server statistics.
A. General Purpose and Statistics Views (mostly pg_ prefix)
pg_stat_activity: Active connections and their queries
pg_locks: Information about all active locks
pg_settings: Current server configuration parameters
pg_roles: User-friendly view of roles
pg_tables: User-friendly view of tables
pg_views: User-friendly view of views
pg_indexes: User-friendly view of indexes
pg_sequences: User-friendly view of sequences
pg_rules: User-friendly view of query rewrite rules
pg_user: Information about the current user
pg_stat_database: Database-wide statistics (transactions, blocks read, etc.)
pg_stat_all_tables / pg_stat_user_tables / pg_stat_sys_tables: Usage statistics for all, user, or system tables
pg_stat_all_indexes / pg_stat_user_indexes / pg_stat_sys_indexes: Usage statistics for indexes
pg_statio_all_tables / pg_statio_user_tables / pg_statio_sys_tables: I/O statistics for tables
pg_statio_all_indexes / pg_statio_user_indexes / pg_statio_sys_indexes: I/O statistics for indexes
pg_statio_all_sequences / pg_statio_user_sequences / pg_statio_sys_sequences: I/O statistics for sequences
pg_stat_bgwriter: Statistics about the background writer process
pg_stat_replication: Statistics about replication senders
pg_stat_wal_receiver: Statistics about the WAL receiver
pg_stat_statements: (Extension) Execution statistics of all queries
pg_prepared_statements: Prepared statements available in the session
pg_cursors: Cursors available in the session
Progress Reporting Views
pg_stat_progress_analyze
pg_stat_progress_basebackup
pg_stat_progress_cluster
pg_stat_progress_copy
pg_stat_progress_create_index
pg_stat_progress_vacuu

B. Information Schema Views
This is the SQL-standard set of views for metadata.
information_schema.tables
information_schema.columns
information_schema.views
information_schema.schemata
information_schema.sequences
information_schema.table_constraints
information_schema.key_column_usage
information_schema.referential_constraints
information_schema.check_constraints
information_schema.routines (functions and procedures)
information_schema.parameters (arguments to routines)
information_schema.triggers
information_schema.roles
information_schema.table_privileges
information_schema.column_privileges
information_schema.usage_privileges
information_schema.role_table_grants
*/

--==============
--==============
-- 1. pg_catalog
--==============
--==============

---------------------------------------------------
-- 1.1 pg_class — Tables, Indexes, Sequences, Views
---------------------------------------------------

SELECT 
    oid,
    relname,
    relnamespace,
    reltype,
    reloftype,
    relowner,
    relam,
    relfilenode,
    reltablespace,
    relpages,
    reltuples,
    relallvisible,
    reltoastrelid,
    relhasindex,
    relisshared,
    relpersistence,
    relkind,
    relnatts,
    relchecks,
    relhasrules,
    relhastriggers,
    relhassubclass,
    relrowsecurity,
    relforcerowsecurity,
    relispopulated,
    relreplident,
    relispartition,
    relrewrite,
    relfrozenxid,
    relminmxid,
    relacl,
    reloptions
FROM pg_class;

--------------------------------------
--1.2 pg_attribute — Columns of Tables
--------------------------------------
SELECT 
    attrelid,
    attname,
    atttypid,
    attstattarget,
    attlen,
    attnum,
    attndims,
    attcacheoff,
    atttypmod,
    attbyval,
    attstorage,
    attalign,
    attnotnull,
    atthasdef,
    attidentity,
    attgenerated,
    attisdropped,
    attislocal,
    attinhcount,
    attcollation,
    attacl
FROM pg_attribute;

-----------------------------------
-- 1.3 pg_index — Index Definitions
-----------------------------------

SELECT 
    indexrelid,
    indrelid,
    indnatts,
    indnkeyatts,
    indisunique,
    indisprimary,
    indisexclusion,
    indimmediate,
    indisclustered,
    indisvalid,
    indcheckxmin,
    indisready,
    indislive,
    indisreplident,
    indkey,
    indcollation,
    indclass,
    indoption,
    indexprs,
    indpred
FROM pg_index;

------------------------------------------------------------------
-- 1.4 pg_constraint — Primary, Foreign, Unique, Check Constraints
------------------------------------------------------------------

SELECT 
    oid,
    conname,
    connamespace,
    contype,
    condeferrable,
    condeferred,
    convalidated,
    conrelid,
    contypid,
    conindid,
    confrelid,
    confupdtype,
    confdeltype,
    confmatchtype,
    conislocal,
    coninhcount,
    connoinherit,
    conkey,
    confkey,
    conpfeqop,
    conppeqop,
    conffeqop,
    conexclop,
    conbin
FROM pg_constraint;

---------------------------
-- 1.5 pg_type — Data Types
---------------------------

SELECT 
    oid,
    typname,
    typnamespace,
    typowner,
    typlen,
    typbyval,
    typtype,
    typcategory,
    typispreferred,
    typisdefined,
    typdelim,
    typrelid,
    typelem,
    typarray,
    typinput,
    typoutput,
    typreceive,
    typsend,
    typmodin,
    typmodout,
    typanalyze,
    typalign,
    typstorage,
    typnotnull,
    typbasetype,
    typtypmod,
    typndims,
    typcollation,
    typdefaultbin,
    typdefault,
    typacl
FROM pg_type;

---------------------------------------
-- 1.6 pg_proc — Functions & Procedures
---------------------------------------

SELECT 
    oid,
    proname,
    pronamespace,
    proowner,
    prolang,
    procost,
    prorows,
    provariadic,
    prosupport,
    prokind,
    prosecdef,
    proleakproof,
    proisstrict,
    proretset,
    provolatile,
    proparallel,
    pronargs,
    pronargdefaults,
    prorettype,
    proargtypes,
    proallargtypes,
    proargmodes,
    proargnames,
    proargdefaults,
    protrftypes,
    prosrc,
    probin,
    proconfig,
    proacl
FROM pg_proc;

----------------------------
--1.7 pg_namespace — Schemas
----------------------------

SELECT 
    oid,
    nspname,
    nspowner,
    nspacl
FROM pg_namespace;


--==========================================
--==========================================
-- 2️ Statistics & Runtime Usage — pg_stat_*
--==========================================
--==========================================

--------------------------------------------
-- 2.1 pg_stat_user_tables — Per Table Stats
--------------------------------------------

SELECT 
    relid,
    schemaname,
    relname,
    seq_scan,
    seq_tup_read,
    idx_scan,
    idx_tup_fetch,
    n_tup_ins,
    n_tup_upd,
    n_tup_del,
    n_tup_hot_upd,
    n_live_tup,
    n_dead_tup,
    n_mod_since_analyze,
    n_ins_since_vacuum,
    last_vacuum,
    last_autovacuum,
    last_analyze,
    last_autoanalyze,
    vacuum_count,
    autovacuum_count,
    analyze_count,
    autoanalyze_count
FROM pg_stat_user_tables;

---------------------------------------------
-- 2.2 pg_stat_user_indexes — Per Index Usage
---------------------------------------------

SELECT 
    relid,
    indexrelid,
    schemaname,
    relname,
    indexrelname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes;


----------------------------------------------
-- 2.3 pg_statio_user_tables — Table I/O Stats
----------------------------------------------

SELECT 
    relid,
    schemaname,
    relname,
    heap_blks_read,
    heap_blks_hit,
    idx_blks_read,
    idx_blks_hit,
    toast_blks_read,
    toast_blks_hit,
    tidx_blks_read,
    tidx_blks_hit
FROM pg_statio_user_tables;

-----------------------------------------------
-- 2.4 pg_statio_user_indexes — Index I/O Stats
-----------------------------------------------

SELECT 
    relid,
    indexrelid,
    schemaname,
    relname,
    indexrelname,
    idx_blks_read,
    idx_blks_hit
FROM pg_statio_user_indexes;

----------------------------------------------------
-- 2.5 pg_stat_activity — Current Queries & Sessions
----------------------------------------------------

SELECT 
    datid,
    datname,
    pid,
    leader_pid,
    usesysid,
    usename,
    application_name,
    client_addr,
    client_hostname,
    client_port,
    backend_start,
    xact_start,
    query_start,
    state_change,
    wait_event_type,
    wait_event,
    state,
    backend_xid,
    backend_xmin,
    query,
    backend_type
FROM pg_stat_activity;

--------------------------------------------
-- 2.6 pg_stat_database — Per Database Stats
--------------------------------------------

SELECT 
    datid,
    datname,
    numbackends,
    xact_commit,
    xact_rollback,
    blks_read,
    blks_hit,
    tup_returned,
    tup_fetched,
    tup_inserted,
    tup_updated,
    tup_deleted,
    conflicts,
    temp_files,
    temp_bytes,
    deadlocks,
    checksum_failures,
    checksum_last_failure,
    blk_read_time,
    blk_write_time,
    session_time,
    active_time,
    idle_in_transaction_time,
    sessions,
    sessions_abandoned,
    sessions_fatal,
    sessions_killed
FROM pg_stat_database;

--=============================================
--=============================================
-- 3. Information Schema — information_schema.*
--=============================================
--=============================================

--------------------------------
-- 3.1 information_schema.tables
--------------------------------

SELECT 
    table_catalog,
    table_schema,
    table_name,
    table_type,
    self_referencing_column_name,
    reference_generation,
    user_defined_type_catalog,
    user_defined_type_schema,
    user_defined_type_name,
    is_insertable_into,
    is_typed,
    commit_action
FROM information_schema.tables;

---------------------------------
-- 3.2 information_schema.columns
---------------------------------

SELECT 
    table_catalog,
    table_schema,
    table_name,
    column_name,
    ordinal_position,
    column_default,
    is_nullable,
    data_type,
    character_maximum_length,
    character_octet_length,
    numeric_precision,
    numeric_precision_radix,
    numeric_scale,
    datetime_precision,
    interval_type,
    interval_precision,
    character_set_catalog,
    character_set_schema,
    character_set_name,
    collation_catalog,
    collation_schema,
    collation_name,
    domain_catalog,
    domain_schema,
    domain_name,
    udt_catalog,
    udt_schema,
    udt_name,
    scope_catalog,
    scope_schema,
    scope_name,
    maximum_cardinality,
    dtd_identifier,
    is_self_referencing,
    is_identity,
    identity_generation,
    identity_start,
    identity_increment,
    identity_maximum,
    identity_minimum,
    identity_cycle,
    is_generated,
    generation_expression,
    is_updatable
FROM information_schema.columns;

-------------------------------------------
-- 3.3 information_schema.table_constraints
-------------------------------------------

SELECT 
    constraint_catalog,
    constraint_schema,
    constraint_name,
    table_catalog,
    table_schema,
    table_name,
    constraint_type,
    is_deferrable,
    initially_deferred,
    enforced
FROM information_schema.table_constraints;

------------------------------------------
-- 3.4 information_schema.key_column_usage
------------------------------------------

SELECT 
    constraint_catalog,
    constraint_schema,
    constraint_name,
    table_catalog,
    table_schema,
    table_name,
    column_name,
    ordinal_position,
    position_in_unique_constraint
FROM information_schema.key_column_usage;

