#!/usr/bin/bash

bruin run \
  --environment default \
  ./module_5/dezc_m5_taxi_bruin/pipeline/assets/ingestion/trips.py \
  --start-date 2022-01-01 \
  --end-date 2022-02-01