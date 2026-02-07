CREATE DATABASE IF NOT EXISTS dwh;

/* 1) External */
DROP VIEW IF EXISTS dwh.yellow_2024_ext;

CREATE VIEW dwh.yellow_2024_ext AS
SELECT *
FROM file('import/yellow_tripdata_2024-*.parquet', 'Parquet')
WHERE tpep_pickup_datetime >= toDateTime('2024-01-01 00:00:00')
  AND tpep_pickup_datetime <  toDateTime('2024-07-01 00:00:00');

-- Q1: Counting records 
SELECT count() AS rows_2024
FROM dwh.yellow_2024_ext;
-- 20332069

-- Q4: Counting zero fare trips 
SELECT count() AS rows_fare_0
FROM dwh.yellow_2024_ext
WHERE fare_amount = 0;
-- 8333

-- Materialized table raw
DROP TABLE IF EXISTS dwh.yellow_2024_raw;

CREATE TABLE dwh.yellow_2024_raw
ENGINE = MergeTree
ORDER BY tuple()
AS
SELECT * FROM dwh.yellow_2024_ext
LIMIT 0;

INSERT INTO dwh.yellow_2024_raw
SELECT * FROM dwh.yellow_2024_ext;

/* check */
SELECT
    (SELECT count() FROM dwh.yellow_2024_ext) AS ext_cnt, -- 20332069
    (SELECT count() FROM dwh.yellow_2024_raw) AS raw_cnt; -- 20332069

-- Q5 Partitioning and clustering
DROP TABLE IF EXISTS dwh.yellow_2024_opt;

CREATE TABLE dwh.yellow_2024_opt
AS dwh.yellow_2024_raw
ENGINE = MergeTree
PARTITION BY toDate(tpep_dropoff_datetime)
ORDER BY (VendorID, tpep_dropoff_datetime)
SETTINGS allow_nullable_key = 1;

INSERT INTO dwh.yellow_2024_opt
SELECT * FROM dwh.yellow_2024_raw;

/* ------------------------------------------------------------
   Q2/Q3 analogue: measure bytes read via system.query_log
   External vs materialized, and 1-column vs 2-columns (optional)
------------------------------------------------------------ */

SYSTEM FLUSH LOGS;

SET log_comment = 'q2_ext_two_cols';
SELECT
  count()
FROM dwh.yellow_2024_ext
WHERE PULocationID IS NOT NULL AND DOLocationID IS NOT NULL;

SET log_comment = '';

SYSTEM FLUSH LOGS;

SELECT
  read_rows,
  read_bytes,
  result_rows,
  result_bytes,
  memory_usage,
  query_id,
  log_comment,
  event_time_microseconds
FROM system.query_log
WHERE type = 'QueryFinish'
  AND log_comment = 'q2_ext_two_cols'
ORDER BY event_time_microseconds DESC
LIMIT 1;

SET log_comment = 'q2_raw_two_cols';
SELECT
  count()
FROM dwh.yellow_2024_raw
WHERE PULocationID IS NOT NULL AND DOLocationID IS NOT NULL;

SET log_comment = '';

SYSTEM FLUSH LOGS;

SELECT
  read_rows,
  read_bytes,
  result_rows,
  result_bytes,
  memory_usage,
  query_id,
  log_comment,
  event_time_microseconds
FROM system.query_log
WHERE type = 'QueryFinish'
  AND log_comment = 'q2_raw_two_cols'
ORDER BY event_time_microseconds DESC
LIMIT 1;

/* ------------------------------------------------------------
   Q6: DISTINCT VendorIDs between 2024-03-01 and 2024-03-15
   Compare raw/materialized vs optimized/partitioned
------------------------------------------------------------ */

SET log_comment = 'q6_raw_distinct_vendor';
SELECT DISTINCT
  VendorID
FROM dwh.yellow_2024_raw
WHERE tpep_dropoff_datetime >= toDateTime('2024-03-01 00:00:00')
  AND tpep_dropoff_datetime <  toDateTime('2024-03-16 00:00:00')
ORDER BY VendorID;

SET log_comment = '';

SYSTEM FLUSH LOGS;

SELECT
  read_rows,
  read_bytes,
  result_rows,
  result_bytes,
  memory_usage,
  query_id,
  log_comment,
  event_time_microseconds
FROM system.query_log
WHERE type = 'QueryFinish'
  AND log_comment = 'q6_raw_distinct_vendor'
ORDER BY event_time_microseconds DESC
LIMIT 1;

SET log_comment = 'q6_opt_distinct_vendor';
SELECT DISTINCT
  VendorID
FROM dwh.yellow_2024_opt
WHERE tpep_dropoff_datetime >= toDateTime('2024-03-01 00:00:00')
  AND tpep_dropoff_datetime <  toDateTime('2024-03-16 00:00:00')
ORDER BY VendorID;

SET log_comment = '';

SYSTEM FLUSH LOGS;

SELECT
  read_rows,
  read_bytes,
  result_rows,
  result_bytes,
  memory_usage,
  query_id,
  log_comment,
  event_time_microseconds
FROM system.query_log
WHERE type = 'QueryFinish'
  AND log_comment = 'q6_opt_distinct_vendor'
ORDER BY event_time_microseconds DESC
LIMIT 1;

select
  log_comment,
  read_rows,
  read_bytes,
  result_rows,
  result_bytes,
  memory_usage,
  query_id,
  log_comment,
  event_time_microseconds
FROM system.query_log
WHERE type = 'QueryFinish'
  AND 
  (log_comment = 'q6_opt_distinct_vendor'
  OR log_comment = 'q6_raw_distinct_vendor'
  OR log_comment = 'q2_raw_two_cols'
  OR log_comment = 'q2_ext_two_cols')
and read_rows != 0 -- not statistic query
ORDER BY event_time_microseconds desc;

/*
log_comment           |read_rows|read_bytes|result_rows|result_bytes|memory_usage|
----------------------+---------+----------+-----------+------------+------------+
q6_opt_distinct_vendor|  1758861|  24624054|          3|         780|    16485136|
q6_raw_distinct_vendor| 20332069| 194566856|          3|         270|     6519212|
q2_raw_two_cols       | 20332069|  40664138|          1|         136|     5471331|
q2_ext_two_cols       | 33894756| 567360581|          1|         136|   270389565|
*/

/* Explain pruning */
EXPLAIN indexes = 1
SELECT DISTINCT
  VendorID
FROM dwh.yellow_2024_opt
WHERE tpep_dropoff_datetime >= toDateTime('2024-03-01 00:00:00')
  AND tpep_dropoff_datetime <  toDateTime('2024-03-16 00:00:00');
