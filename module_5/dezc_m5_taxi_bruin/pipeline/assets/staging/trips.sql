/* @bruin
name: staging.trips
type: duckdb.sql
depends:
  - ingestion.trips
  - ingestion.payment_lookup

materialization:
  type: table
  strategy: time_interval
  incremental_key: pickup_datetime
  time_granularity: timestamp

columns:
  - name: pickup_datetime
    type: timestamp
    description: "When the meter was engaged"
    primary_key: true
    nullable: false
    checks:
      - name: not_null

  - name: dropoff_datetime
    type: timestamp
    description: "When the meter was disengaged"

  - name: pickup_location_id
    type: integer
    description: "Pickup TLC zone id"

  - name: dropoff_location_id
    type: integer
    description: "Dropoff TLC zone id"

  - name: fare_amount
    type: double
    description: "Fare amount"

  - name: taxi_type
    type: string
    description: "yellow or green"

  - name: payment_type_name
    type: string
    description: "Payment type name from lookup"

custom_checks:
  - name: row_count_greater_than_zero
    description: "Staging should produce at least 1 row for the processed window"
    query: |
      SELECT CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END
      FROM staging.trips
    value: 1
@bruin */

SELECT
  t.pickup_datetime,
  t.dropoff_datetime,
  t.pickup_location_id,
  t.dropoff_location_id,
  t.fare_amount,
  t.taxi_type,
  p.payment_type_name
FROM ingestion.trips AS t
LEFT JOIN ingestion.payment_lookup AS p
  ON t.payment_type = p.payment_type_id
WHERE t.pickup_datetime >= '{{ start_datetime }}'
  AND t.pickup_datetime <  '{{ end_datetime }}'
QUALIFY
  ROW_NUMBER() OVER (
    PARTITION BY
      t.pickup_datetime,
      t.dropoff_datetime,
      t.pickup_location_id,
      t.dropoff_location_id,
      t.fare_amount,
      t.taxi_type,
      t.payment_type
    ORDER BY t.extracted_at DESC
  ) = 1
