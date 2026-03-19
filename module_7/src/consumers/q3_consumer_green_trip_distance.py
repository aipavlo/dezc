import json
from time import time

import pandas as pd
from kafka import KafkaConsumer

TOPIC_NAME = "green-trips"
SERVER = "localhost:9092"

consumer = KafkaConsumer(
    TOPIC_NAME,
    bootstrap_servers=[SERVER],
    auto_offset_reset="earliest",
    enable_auto_commit=False,
    group_id="green-trips-q3-v1",
    value_deserializer=lambda m: json.loads(m.decode("utf-8")),
    consumer_timeout_ms=3000,
)

count = 0

for message in consumer:
    trip = message.value
    if float(trip["trip_distance"]) > 5.0:
        count += 1

print(count)

consumer.close()