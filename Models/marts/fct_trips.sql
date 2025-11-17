{{
  config(
    materialized='table',
    schema='ANALYTICS'
  )
}}

with stg_trips as (
    -- Ambil data dari staging 
    select * from {{ ref('stg_trips') }}
),

dim_pickup_locations as (
    select * from {{ ref('dim_locations') }}
),

dim_dropoff_locations as (
    select * from {{ ref('dim_locations') }}
),

dim_payment_types as (
    select * from {{ ref('dim_payment_types') }}
)

select
    -- Kunci (Keys)
    stg_trips.pickup_location_id,
    stg_trips.dropoff_location_id,
    stg_trips.payment_type_id,
    
    -- Tanggal & Waktu dipisah
    stg_trips.pickup_datetime::DATE as pickup_date,
    EXTRACT(HOUR FROM stg_trips.pickup_datetime) as pickup_hour,
    
    stg_trips.dropoff_datetime::DATE as dropoff_date,
    EXTRACT(HOUR FROM stg_trips.dropoff_datetime) as dropoff_hour,
    
    -- Dimensi (Info Deskriptif)
    dim_pickup_locations.borough as pickup_borough,
    dim_pickup_locations.zone as pickup_zone,
    dim_dropoff_locations.borough as dropoff_borough,
    dim_dropoff_locations.zone as dropoff_zone,
    dim_payment_types.payment_type_name,
    
    -- Fakta (Angka)
    stg_trips.passenger_count,
    stg_trips.trip_distance,
    stg_trips.duration_minutes,
    stg_trips.fare_amount,
    stg_trips.tip_amount,
    stg_trips.tolls_amount,
    stg_trips.total_amount
    
from stg_trips

-- Gabungkan untuk mendapatkan info lokasi penjemputan
left join dim_pickup_locations
    on stg_trips.pickup_location_id = dim_pickup_locations.location_id

-- Gabungkan untuk mendapatkan info lokasi penurunan
left join dim_dropoff_locations
    on stg_trips.dropoff_location_id = dim_dropoff_locations.location_id

-- Gabungkan untuk mendapatkan info tipe pembayaran
left join dim_payment_types
    on stg_trips.payment_type_id = dim_payment_types.payment_type_id
