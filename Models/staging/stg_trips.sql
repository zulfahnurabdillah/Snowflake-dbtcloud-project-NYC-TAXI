with source as (

    select * from {{ source('raw', 'TRIPS') }}

)

select
    -- Ganti nama kolom (snake_case)
    VendorID as vendor_id, 
    tpep_pickup_datetime as pickup_datetime,
    tpep_dropoff_datetime as dropoff_datetime,
    passenger_count,
    trip_distance,
    RatecodeID as ratecode_id,
    PULocationID as pickup_location_id,
    DOLocationID as dropoff_location_id,
    payment_type as payment_type_id,
    fare_amount,
    tip_amount,
    tolls_amount,
    total_amount,

    -- Buat kolom baru
    timestampdiff(minute, pickup_datetime, dropoff_datetime) as duration_minutes

from source
where total_amount > 0
  
