-- 1. Buat Warehouse (Mesin) baru untuk proyek ini
CREATE WAREHOUSE NYC_TAXI_WH
  WAREHOUSE_SIZE = 'MEDIUM'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE;

-- 2. Buat Database (Rumah) baru
CREATE DATABASE NYC_TAXI_DB;

-- 3. Buat Schema untuk data mentah
CREATE SCHEMA NYC_TAXI_DB.RAW;

-- 4. Aktifkan warehouse dan database 
USE WAREHOUSE NYC_TAXI_WH;
USE DATABASE NYC_TAXI_DB;

USE SCHEMA RAW;

CREATE TABLE RAW.TRIPS (
    VendorID INT,
    tpep_pickup_datetime TIMESTAMP_NTZ(9), -- NTZ = Waktu lokal NYC
    tpep_dropoff_datetime TIMESTAMP_NTZ(9),
    passenger_count INT,
    trip_distance FLOAT,
    RatecodeID INT,
    store_and_fwd_flag VARCHAR(1),
    PULocationID INT, -- Kunci PENTING untuk Pickup Location
    DOLocationID INT, -- Kunci PENTING untuk Dropoff Location
    payment_type INT, -- Kunci PENTING untuk Payment
    fare_amount FLOAT,
    extra FLOAT,
    mta_tax FLOAT,
    tip_amount FLOAT,
    tolls_amount FLOAT,
    improvement_surcharge FLOAT,
    total_amount FLOAT,
    congestion_surcharge FLOAT
);

CREATE OR REPLACE FILE FORMAT my_parquet_format_smart
  TYPE = 'PARQUET'
  MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;

USE SCHEMA NYC_TAXI_DB.RAW;

COPY INTO NYC_TAXI_DB.RAW.TRIPS
FROM (
    SELECT
        $1:VendorID::INT,
        TO_TIMESTAMP_NTZ($1:tpep_pickup_datetime::BIGINT, 6),
        TO_TIMESTAMP_NTZ($1:tpep_dropoff_datetime::BIGINT, 6),  
        $1:passenger_count::INT,
        $1:trip_distance::FLOAT,
        $1:RatecodeID::INT,
        $1:store_and_fwd_flag::VARCHAR,
        $1:PULocationID::INT,
        $1:DOLocationID::INT,
        $1:payment_type::INT,
        $1:fare_amount::FLOAT,
        $1:extra::FLOAT,
        $1:mta_tax::FLOAT,
        $1:tip_amount::FLOAT,
        $1:tolls_amount::FLOAT,
        $1:improvement_surcharge::FLOAT,
        $1:total_amount::FLOAT,
        $1:congestion_surcharge::FLOAT
        
    FROM @NYC_TAXI_DB.RAW.%TRIPS  -- Ambil dari User Stage 
    (FILE_FORMAT => 'my_parquet_format')
)
ON_ERROR = 'CONTINUE';


