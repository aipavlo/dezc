import pandas as pd
from sqlalchemy import create_engine
import psycopg2

# Q3
df_q3 = pd.read_parquet(
    "../data/green_tripdata_2025-11.parquet",
    columns=["lpep_pickup_datetime", "trip_distance"],
)

cnt = (
    (df_q3["lpep_pickup_datetime"] >= "2025-11-01")
    & (df_q3["lpep_pickup_datetime"] < "2025-12-01")
    & (df_q3["trip_distance"] <= 1)
).sum()

print("Q3:", cnt)


# Q4
df_q4 = pd.read_parquet(
    "../data/green_tripdata_2025-11.parquet",
    columns=["lpep_pickup_datetime", "trip_distance"],
)

df_q4 = df_q4[
    (df_q4["lpep_pickup_datetime"] >= "2025-11-01")
    & (df_q4["lpep_pickup_datetime"] < "2025-12-01")
    & (df_q4["trip_distance"] < 100)
]

# to day
df_q4["pickup_day"] = df_q4["lpep_pickup_datetime"].dt.date

# Max distance
daily_max = df_q4.groupby("pickup_day")["trip_distance"].max()

# Longest pickup day
pickup_day_longest = daily_max.idxmax()

print("Q4:", pickup_day_longest)

# Q5
df = pd.read_parquet(
    "../data/green_tripdata_2025-11.parquet",
    columns=["lpep_pickup_datetime", "PULocationID", "total_amount"],
)

day_start = pd.Timestamp("2025-11-18")
day_end = day_start + pd.Timedelta(days=1)

df_day = df[
    (df["lpep_pickup_datetime"] >= day_start)
    & (df["lpep_pickup_datetime"] < day_end)
].copy()

sum_by_pu = (df_day.groupby("PULocationID", as_index=False)["total_amount"].sum())

zones = pd.read_csv("../data/taxi_zone_lookup.csv")
zones = zones.rename(columns={"LocationID": "PULocationID"})

res = sum_by_pu.merge(zones[["PULocationID", "Zone", "Borough"]], on="PULocationID", how="left")

# Max zone
top_row = res.sort_values("total_amount", ascending=False).iloc[0]
print("Q5:", top_row["Zone"])

# Q6
df = pd.read_parquet(
    "../data/green_tripdata_2025-11.parquet",
    columns=["lpep_pickup_datetime", "PULocationID", "DOLocationID", "tip_amount"],
)
start = pd.Timestamp("2025-11-01")
end = pd.Timestamp("2025-12-01")

df = df[
    (df["lpep_pickup_datetime"] >= start)
    & (df["lpep_pickup_datetime"] < end)
].copy()

zones = pd.read_csv("../data/taxi_zone_lookup.csv")

pu = zones[["LocationID", "Zone"]].rename(columns={"LocationID": "PULocationID", "Zone": "pickup_zone"})
df = df.merge(pu, on="PULocationID", how="left")

do = zones[["LocationID", "Zone"]].rename(columns={"LocationID": "DOLocationID", "Zone": "dropoff_zone"})
df = df.merge(do, on="DOLocationID", how="left")

df_ehn = df[
    (df["pickup_zone"] == "East Harlem North")
    & (df["dropoff_zone"].notna())
].copy()
tips_by_dropoff = df_ehn.groupby("dropoff_zone")["tip_amount"].max()

top_dropoff_zone = tips_by_dropoff.idxmax()
top_tip_value = tips_by_dropoff.loc[top_dropoff_zone]

print("Q6:", top_dropoff_zone)