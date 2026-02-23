"""@bruin
name: ingestion.trips
type: python
image: python:3.11
connection: duckdb-default

materialization:
  type: table
  strategy: append

columns:
  - name: pickup_datetime
    type: timestamp
    description: "Pickup datetime (normalized)"

  - name: dropoff_datetime
    type: timestamp
    description: "Dropoff datetime (normalized)"

  - name: pickup_location_id
    type: integer
    description: "Pickup TLC zone id"

  - name: dropoff_location_id
    type: integer
    description: "Dropoff TLC zone id"

  - name: fare_amount
    type: double
    description: "Fare amount"

  - name: payment_type
    type: integer
    description: "Payment type id"

  - name: taxi_type
    type: string
    description: "yellow or green"

  - name: extracted_at
    type: timestamp
    description: "Timestamp of extraction (UTC)"
@bruin"""

import os
import json
import io
from datetime import datetime, timezone, timedelta, date

import pandas as pd
import requests
import pyarrow.parquet as pq
import pyarrow as pa
from dateutil.relativedelta import relativedelta


BASE_URL = "https://d37ci6vzurychx.cloudfront.net/trip-data"


def _parse_date(s: str) -> date:
    return datetime.strptime(s, "%Y-%m-%d").date()


def _month_start(d: date) -> date:
    return date(d.year, d.month, 1)


def _iter_months(start_d: date, end_d_exclusive: date):
    # We need months covering [start_d, end_d_exclusive)
    # We'll iterate month starts from start_d's month to the month of (end_d_exclusive - 1 day)
    end_inclusive = end_d_exclusive - timedelta(days=1)
    cur = _month_start(start_d)
    last = _month_start(end_inclusive)
    while cur <= last:
        yield cur.year, cur.month
        cur = cur + relativedelta(months=1)


def _read_parquet_from_url(url: str) -> pa.Table:
    r = requests.get(url, timeout=120)
    r.raise_for_status()
    buf = io.BytesIO(r.content)
    return pq.read_table(buf)


def materialize():
    # Bruin provides these env vars for the run window.
    start_date = _parse_date(os.environ["BRUIN_START_DATE"])
    end_date = _parse_date(os.environ["BRUIN_END_DATE"])  # exclusive

    vars_json = json.loads(os.environ.get("BRUIN_VARS", "{}"))
    taxi_types = vars_json.get("taxi_types", ["yellow"])
    if not isinstance(taxi_types, list) or not taxi_types:
        taxi_types = ["yellow"]

    start_dt = datetime.combine(start_date, datetime.min.time(), tzinfo=timezone.utc)
    end_dt = datetime.combine(end_date, datetime.min.time(), tzinfo=timezone.utc)

    extracted_at = datetime.now(timezone.utc)

    frames = []
    for taxi_type in taxi_types:
        taxi_type = str(taxi_type).strip().lower()
        if taxi_type not in ("yellow", "green"):
            continue

        for y, m in _iter_months(start_date, end_date):
            url = f"{BASE_URL}/{taxi_type}_tripdata_{y:04d}-{m:02d}.parquet"
            table = _read_parquet_from_url(url)
            df = table.to_pandas()

            # Normalize pickup/dropoff column names across yellow/green datasets
            if taxi_type == "yellow":
                pickup_col = "tpep_pickup_datetime"
                dropoff_col = "tpep_dropoff_datetime"
            else:
                pickup_col = "lpep_pickup_datetime"
                dropoff_col = "lpep_dropoff_datetime"

            # Some months/datasets can have missing cols; skip safely
            required_cols = [pickup_col, dropoff_col, "PULocationID", "DOLocationID", "fare_amount", "payment_type"]
            for c in required_cols:
                if c not in df.columns:
                    df[c] = pd.NA

            out = pd.DataFrame(
                {
                    "pickup_datetime": pd.to_datetime(df[pickup_col], utc=True, errors="coerce"),
                    "dropoff_datetime": pd.to_datetime(df[dropoff_col], utc=True, errors="coerce"),
                    "pickup_location_id": pd.to_numeric(df["PULocationID"], errors="coerce").astype("Int64"),
                    "dropoff_location_id": pd.to_numeric(df["DOLocationID"], errors="coerce").astype("Int64"),
                    "fare_amount": pd.to_numeric(df["fare_amount"], errors="coerce"),
                    "payment_type": pd.to_numeric(df["payment_type"], errors="coerce").astype("Int64"),
                    "taxi_type": taxi_type,
                    "extracted_at": extracted_at,
                }
            )

            # Keep only the requested window (important when reading whole-month parquet files)
            out = out[(out["pickup_datetime"] >= start_dt) & (out["pickup_datetime"] < end_dt)]
            frames.append(out)

    if not frames:
        # Return an empty DataFrame with the right columns
        return pd.DataFrame(
            columns=[
                "pickup_datetime",
                "dropoff_datetime",
                "pickup_location_id",
                "dropoff_location_id",
                "fare_amount",
                "payment_type",
                "taxi_type",
                "extracted_at",
            ]
        )

    final_df = pd.concat(frames, ignore_index=True)

    # Ensure consistent dtypes
    final_df["pickup_location_id"] = final_df["pickup_location_id"].astype("Int64")
    final_df["dropoff_location_id"] = final_df["dropoff_location_id"].astype("Int64")
    final_df["payment_type"] = final_df["payment_type"].astype("Int64")

    return final_df
