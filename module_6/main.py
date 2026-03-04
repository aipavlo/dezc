import glob
import os

from pyspark.sql import SparkSession, functions as func

spark = SparkSession.builder \
    .master("local[*]") \
    .appName('de-zoomcamp-2026-m6') \
    .getOrCreate()

print("Q1:", spark.version)


yellow_path = "../data/m_6/yellow_tripdata_2025-11.parquet"
df = spark.read.parquet(yellow_path)

# Q2: repartition
out_dir = "data/yellow_2025_11_p4"
(
    df.repartition(4)
      .write
      .mode("overwrite")
      .parquet(out_dir)
)

parquet_files = sorted(glob.glob(os.path.join(out_dir, "**", "*.parquet"), recursive=True))
total_bytes = sum(os.path.getsize(p) for p in parquet_files)
avg_mb = (total_bytes / len(parquet_files)) / (1024 * 1024)
print(f"Q2: {round(avg_mb,2)} (files: {len(parquet_files)})")

# Q3: trips that started on 2025-11-15 (pickup date)
q3 = (
    df.filter(func.to_date(func.col("tpep_pickup_datetime")) == func.lit("2025-11-15"))
      .count()
)
print("Q3:", q3)

# Q4: the longest trip
pickup_s  = func.unix_timestamp(func.col("tpep_pickup_datetime").cast("string"))
dropoff_s = func.unix_timestamp(func.col("tpep_dropoff_datetime").cast("string"))

q4 = (
    df.select(func.max((dropoff_s - pickup_s) / func.lit(3600.0)).alias("max_hours"))
      .collect()[0]["max_hours"]
)
print("Q4:", round(q4,1))

# Q5: User Interface
print("Q5: 4040")

# Q6: Least frequent pickup location zone
zones = (
    spark.read
         .option("header", "true")
         .csv("../data/m_6/taxi_zone_lookup.csv")
         .withColumn("LocationID", func.col("LocationID").cast("int"))
)

df_pu = df.select(func.col("PULocationID").cast("int").alias("PULocationID"))

joined = df_pu.join(zones, df_pu.PULocationID == zones.LocationID, "left")

counts = joined.groupBy("Zone").count()
min_count = counts.agg(func.min("count").alias("min_count")).collect()[0]["min_count"]

least_zones = counts.filter(func.col("count") == func.lit(min_count)).orderBy("Zone")
print("Q6:")
least_zones.show(50)

spark.stop()