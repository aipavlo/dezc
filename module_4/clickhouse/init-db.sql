CREATE DATABASE IF NOT EXISTS dwh;


DROP VIEW IF EXISTS dwh.yellow_ext;
CREATE VIEW dwh.yellow_ext AS
SELECT *
FROM file('import/yellow/yellow_tripdata_*.parquet', 'Parquet');
CREATE OR REPLACE VIEW dwh.yellow_tripdata AS SELECT * FROM dwh.yellow_ext;


DROP VIEW IF EXISTS dwh.green_ext;
CREATE VIEW dwh.green_ext AS
SELECT *
FROM file('import/green/green_tripdata_*.parquet', 'Parquet');
CREATE OR REPLACE VIEW dwh.green_tripdata AS SELECT * FROM dwh.green_ext;


DROP VIEW IF EXISTS dwh.fhv_ext;
CREATE VIEW dwh.fhv_ext AS
SELECT *
FROM file('import/fhv/fhv_tripdata_*.parquet', 'Parquet');
CREATE OR REPLACE VIEW dwh.fhv_tripdata AS SELECT * FROM dwh.fhv_ext;


DROP TABLE IF EXISTS dwh.green_tripdata_mt;
CREATE TABLE dwh.green_tripdata_mt
(
    VendorID                 Nullable(Int64),
    lpep_pickup_datetime     Nullable(DateTime64(6)),
    lpep_dropoff_datetime    Nullable(DateTime64(6)),
    store_and_fwd_flag       Nullable(String),
    RatecodeID               Nullable(Int64),
    PULocationID             Nullable(Int64),
    DOLocationID             Nullable(Int64),
    passenger_count          Nullable(Int64),
    trip_distance            Nullable(Float64),
    fare_amount              Nullable(Float64),
    extra                    Nullable(Float64),
    mta_tax                  Nullable(Float64),
    tip_amount               Nullable(Float64),
    tolls_amount             Nullable(Float64),
    ehail_fee                Nullable(Int64),
    improvement_surcharge    Nullable(Float64),
    total_amount             Nullable(Float64),
    payment_type             Nullable(Int64),
    trip_type                Nullable(Int64),
    congestion_surcharge     Nullable(Float64)
)
ENGINE = MergeTree
ORDER BY tuple();
INSERT INTO dwh.green_tripdata_mt
(
    VendorID,
    lpep_pickup_datetime,
    lpep_dropoff_datetime,
    store_and_fwd_flag,
    RatecodeID,
    PULocationID,
    DOLocationID,
    passenger_count,
    trip_distance,
    fare_amount,
    extra,
    mta_tax,
    tip_amount,
    tolls_amount,
    ehail_fee,
    improvement_surcharge,
    total_amount,
    payment_type,
    trip_type,
    congestion_surcharge
)
SELECT
    VendorID,
    lpep_pickup_datetime,
    lpep_dropoff_datetime,
    store_and_fwd_flag,
    RatecodeID,
    PULocationID,
    DOLocationID,
    passenger_count,
    trip_distance,
    fare_amount,
    extra,
    mta_tax,
    tip_amount,
    tolls_amount,
    ehail_fee,
    improvement_surcharge,
    total_amount,
    payment_type,
    trip_type,
    congestion_surcharge
FROM file('import/green/green_tripdata_*.parquet', 'Parquet');


DROP TABLE IF EXISTS dwh.yellow_tripdata_mt;
CREATE TABLE dwh.yellow_tripdata_mt
(
    VendorID                 Nullable(Int64),
    tpep_pickup_datetime     Nullable(DateTime64(6)),
    tpep_dropoff_datetime    Nullable(DateTime64(6)),
    passenger_count          Nullable(Int64),
    trip_distance            Nullable(Float64),
    RatecodeID               Nullable(Int64),
    store_and_fwd_flag       Nullable(String),
    PULocationID             Nullable(Int64),
    DOLocationID             Nullable(Int64),
    payment_type             Nullable(Int64),
    fare_amount              Nullable(Float64),
    extra                    Nullable(Float64),
    mta_tax                  Nullable(Float64),
    tip_amount               Nullable(Float64),
    tolls_amount             Nullable(Float64),
    improvement_surcharge    Nullable(Float64),
    total_amount             Nullable(Float64),
    congestion_surcharge     Nullable(Float64)
)
ENGINE = MergeTree
ORDER BY tuple();
INSERT INTO dwh.yellow_tripdata_mt
(
    VendorID,
    tpep_pickup_datetime,
    tpep_dropoff_datetime,
    passenger_count,
    trip_distance,
    RatecodeID,
    store_and_fwd_flag,
    PULocationID,
    DOLocationID,
    payment_type,
    fare_amount,
    extra,
    mta_tax,
    tip_amount,
    tolls_amount,
    improvement_surcharge,
    total_amount,
    congestion_surcharge
)
SELECT
    VendorID,
    tpep_pickup_datetime,
    tpep_dropoff_datetime,
    passenger_count,
    trip_distance,
    RatecodeID,
    store_and_fwd_flag,
    PULocationID,
    DOLocationID,
    payment_type,
    fare_amount,
    extra,
    mta_tax,
    tip_amount,
    tolls_amount,
    improvement_surcharge,
    total_amount,
    congestion_surcharge
FROM file('import/yellow/yellow_tripdata_*.parquet', 'Parquet');


DROP TABLE IF EXISTS dwh.fhv_tripdata_mt;
CREATE TABLE dwh.fhv_tripdata_mt
(
    dispatching_base_num      Nullable(String),
    pickup_datetime           Nullable(DateTime64(6)),
    dropOff_datetime          Nullable(DateTime64(6)),
    PUlocationID              Nullable(Int64),
    DOlocationID              Nullable(Int64),
    SR_Flag                   Nullable(UInt8),
    Affiliated_base_number    Nullable(String)
)
ENGINE = MergeTree
ORDER BY tuple();
INSERT INTO dwh.fhv_tripdata_mt
(
    dispatching_base_num,
    pickup_datetime,
    dropOff_datetime,
    PUlocationID,
    DOlocationID,
    SR_Flag,
    Affiliated_base_number
)
SELECT
    dispatching_base_num,
    pickup_datetime,
    dropOff_datetime,
    PUlocationID,
    DOlocationID,
    SR_Flag,
    Affiliated_base_number
FROM file('import/fhv/fhv_tripdata_*.parquet', 'Parquet');