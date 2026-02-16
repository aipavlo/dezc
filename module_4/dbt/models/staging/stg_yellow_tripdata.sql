{{ config(
    materialized = "table",
    engine       = "MergeTree()",
    order_by     = "(vendor_id)",
    settings     = {
        "allow_nullable_key": 1
    }
) }}

with source as (
     select * from {{ source('raw', 'yellow_tripdata_mt') }}
 ),
 
 renamed as (
    select
        `VendorID` as vendor_id,
        `RatecodeID` as rate_code_id,
        `PULocationID` as pickup_location_id,
        `DOLocationID` as dropoff_location_id,

        tpep_pickup_datetime as pickup_datetime,
        tpep_dropoff_datetime as dropoff_datetime,

        store_and_fwd_flag as store_and_fwd_flag,
        passenger_count as passenger_count,
        trip_distance as trip_distance,

        fare_amount as fare_amount,
        extra as extra,
        mta_tax as mta_tax,
        tip_amount as tip_amount,
        tolls_amount as tolls_amount,
        improvement_surcharge as improvement_surcharge,
        total_amount as total_amount,
        payment_type as payment_type
    from source
    where `VendorID` is not null
 )
 
 select * from renamed
