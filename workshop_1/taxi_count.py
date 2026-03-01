import duckdb

DB_PATH = "taxi_pipeline.duckdb"
SCHEMA = "taxi"
TABLE = "trips"

con = duckdb.connect(DB_PATH, read_only=True)
full_table = f'"{SCHEMA}"."{TABLE}"'

# Q1: start/end
min_dt, max_dt = con.execute(
    f'SELECT min("trip_pickup_date_time"), max("trip_pickup_date_time") FROM {full_table}'
).fetchone()

# Q2: credit card %
pct_cc = con.execute(
    f"""
    SELECT
      SUM(CASE WHEN payment_type = 'Credit%' THEN 1 ELSE 0 END)/COUNT(1)
    FROM {full_table}
    """
).fetchone()[0]

# Q3: sum tips
sum_tips = con.execute(
    f'SELECT sum(coalesce(try_cast(tip_amt AS double), 0.0)) FROM {full_table}'
).fetchone()[0]

print(f"Q1: {min_dt} -> {max_dt}")
print(f"Q2: {pct_cc}%")
print(f"Q3: {sum_tips:.2f}")