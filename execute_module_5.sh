#!/usr/bin/bash

PIPELINE_YML="./module_5/dezc_m5_taxi_bruin/pipeline/pipeline.yml"
TRIPS_REPORT_SQL="./module_5/dezc_m5_taxi_bruin/pipeline/assets/reports/trips_report.sql"
INGESTION_TRIPS_PY="./module_5/dezc_m5_taxi_bruin/pipeline/assets/ingestion/trips.py"

bruin connections list

bruin validate $PIPELINE_YML

bruin lineage $TRIPS_REPORT_SQL --full

bruin query --connection duckdb-default --query "SELECT COUNT(*) AS cnt FROM ingestion.trips;"

bruin run $PIPELINE_YML --full-refresh --start-date 2022-01-01 --end-date 2022-02-01

bruin query --connection duckdb-default --query "SELECT COUNT(*) AS cnt FROM ingestion.trips;"

bruin run $PIPELINE_YML --start-date 2022-01-01 --end-date 2022-02-01 --var 'taxi_types=["yellow"]'

bruin run $INGESTION_TRIPS_PY --downstream --start-date 2022-01-01 --end-date 2022-02-01