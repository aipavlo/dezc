import json
from time import time

import pandas as pd
from kafka import KafkaProducer


URL = "https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2025-10.parquet"
TOPIC_NAME = "green-trips"
SERVER = "localhost:9092"

COLUMNS = [
    "lpep_pickup_datetime",
    "lpep_dropoff_datetime",
    "PULocationID",
    "DOLocationID",
    "passenger_count",
    "trip_distance",
    "tip_amount",
    "total_amount",
]


def json_serializer(data):
    return json.dumps(data).encode("utf-8")


df = pd.read_parquet(URL, columns=COLUMNS)

df["lpep_pickup_datetime"] = df["lpep_pickup_datetime"].dt.strftime("%Y-%m-%d %H:%M:%S")
df["lpep_dropoff_datetime"] = df["lpep_dropoff_datetime"].dt.strftime("%Y-%m-%d %H:%M:%S")

df = df.where(pd.notna(df), None)

records = df.to_dict(orient="records")

producer = KafkaProducer(
    bootstrap_servers=[SERVER],
    value_serializer=json_serializer,
)

t0 = time()

for message in records:
    producer.send(TOPIC_NAME, value=message)

producer.flush()

t1 = time()

print(f"rows={len(records)}")
print(f"took {(t1 - t0)} seconds")

producer.close()
