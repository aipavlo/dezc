# DE Zoomcamp 2026 - Module 4 (Analytics Engineering) - Local setup with ClickHouse

This project is based on the official Module 4 dbt project, adapted to run fully locally using ClickHouse.

## What changed vs the official local setup
- Replaced DuckDB warehouse with ClickHouse (local Docker container)
- Raw datasets are ingested from parquet files
- dbt models/macros were adjusted for ClickHouse SQL dialect:
  - Removed/rewrote `QUALIFY` (not supported in ClickHouse)
  - Added ClickHouse equivalents for month truncation and date diff where needed
  - Fixed column name casing (e.g., `VendorID`, `PULocationID`, `DOLocationID` in Parquet)

## Prerequisites
- Docker + Docker Compose
- git
- dbt (either local venv or a container) with:
  - `dbt-core`
  - `dbt-clickhouse`
  - `dbt-utils`

## Environment variables
Create a `.env` file (same values for ClickHouse and dbt):

```env
DWH_DB=
DWH_USER=
DWH_PASSWORD=
```

## Run dbt
dbt deps
dbt build --target prod

## Answers
Q1: dbt run --select int_trips_unioned builds which models?

int_trips_unioned only.


Q2: New value 6 appears in payment_type. What happens on dbt test?

dbt fails the test with non-zero exit code

Q3: Count of records in fct_monthly_zone_revenue

12184

Q4: Zone with highest revenue for Green taxis in 2020

East Harlem North

Q5: Total trips for Green taxis in October 2019

384624

Q6: Count of records in stg_fhv_tripdata where dispatching_base_num IS NULL

43244693