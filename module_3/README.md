# DE Zoomcamp 2026 — Module 3 DWH Homework
Local option

## What was replaced (GCP - Local)

- **GCS bucket** - local folder with parquet files mounted into the container
- **BigQuery External Table** - ClickHouse `VIEW` over Parquet via `file(...)`
- **BigQuery Materialized Table** - ClickHouse `MergeTree` table loaded from the `VIEW`
- **BigQuery Partitioning + Clustering** - ClickHouse `PARTITION BY ...` + `ORDER BY (...)`
- **BigQuery “estimated bytes processed”** → ClickHouse `system.query_log.read_bytes` for the executed query (closest practical analogue)

## Prerequisites
- Docker + Docker Compose
- ClickHouse (via Docker image)
- NYC TLC **Yellow Taxi 2024** Parquet files

## Data
Load the dataset in `/data` on the host with download.sh
Mount it into ClickHouse user_files (so `file('import/...')` works):
- container path: `./data:/var/lib/clickhouse/user_files/import:ro`

## Execution
All commands executed via `./clickhouse/init-db.sql:/docker-entrypoint-initdb.d/init-db.sql` from script `/clickhouse/init-db.sql`

Answers

Q1. Count of records for the 2024 Yellow Taxi Data

- 20332069

Q2. Estimated data read for the “distinct PULocationID” query (External vs Materialized)

- 0 MB (External Table) and 155.12 MB (Materialized Table)

Q3. Why are the estimated number of bytes different?

- It is a columnar system: scans only columns needed by the query. Selecting more columns increases scanned info.

Q4. Records with fare_amount = 0

- 8333

Q5. Best optimization strategy (filter by tpep_dropoff_datetime, order by VendorID)

- Partition by tpep_dropoff_datetime and Cluster on VendorID

Q6. Estimated bytes (non-partitioned vs partitioned table) for distinct VendorIDs (2024-03-01..2024-03-15)

- 310.24 MB (non-partitioned) and 26.84 MB (partitioned).
In ClickHouse I run the query on yellow_2024_raw vs yellow_2024_opt and compare system.query_log.read_bytes

Q7. Where is the data stored in the External Table?

- GCP Bucket. Local: files live on the host and are mounted into the container

Q8. “It is best practice in BigQuery to always cluster your data”

- False

Q9. SELECT count(*) from the materialized table — bytes estimate and why

- In BigQuery, count can be answered using metadata (so the estimate may be 0 bytes or very small), because it doesn’t necessarily need to scan. In ClickHouse, a similar optimization (metadat read)