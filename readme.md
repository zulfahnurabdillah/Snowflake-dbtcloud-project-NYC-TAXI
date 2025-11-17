# Proyek Data Engineering End-to-End: Analisis NYC Taxi (2024)

Proyek ini mendemonstrasikan alur kerja ELT (Extract, Load, Transform) end-to-end yang lengkap. Data perjalanan (trip data) NYC Yellow Taxi (format Parquet) diekstrak, dimuat ke dalam Snowflake, dan ditransformasi untuk menangani tipe data yang sulit. Data tersebut kemudian dimodelkan menjadi Star Schema yang bersih menggunakan dbt, dan siap untuk dianalisis di Tableau.

## 🚀 Tech Stack

* **Data Warehouse:** Snowflake
* **Alat Pemuatan Data:** SnowSQL (CLI) & Staging Snowflake
* **Alat Transformasi:** dbt Cloud
* **Format Data:** Parquet
* **Alat Visualisasi:** Tableau (Direncanakan)
* **Version Control:** Git & GitHub

## 🏛️ Arsitektur & Alur Data (ELT)

1.  **Extract:** Data NYC Yellow Taxi (Jan-Mei 2024) dalam format Parquet diunduh dari situs resmi NYC TLC. Dua file CSV *lookup* (untuk zona dan tipe pembayaran) juga disiapkan.
2.  **Load:** File Parquet di-upload ke *user stage* (`@~/`) di Snowflake menggunakan SnowSQL. Perintah `COPY INTO` khusus dengan transformasi *on-the-fly* digunakan untuk memuat data ke dalam tabel `RAW.TRIPS`, yang secara benar mengonversi *timestamp* dari format *microseconds* (epoch) menjadi `TIMESTAMP` yang valid.
3.  **Transform:** dbt Cloud terhubung ke database Snowflake.
    * **`dbt seed`** digunakan untuk memuat file CSV lookup (`taxi_zone_lookup.csv` dan `payment_types.csv`) sebagai tabel dimensi.
    * **`dbt run`** mengeksekusi model `.sql` untuk membersihkan, memfilter, dan menggabungkan data mentah menjadi Star Schema yang bersih di dalam schema `ANALYTICS`.
4.  **Visualize (Tahap Berikutnya):** Tableau akan terhubung ke schema `ANALYTICS` di Snowflake untuk membuat dashboard analitis.

## 🛠️ Cara Mereplikasi Proyek Ini

### 1. Dapatkan Data Mentah

Anda memerlukan tiga sumber data untuk proyek ini:

* **Data Perjalanan (Parquet):** Unduh file "Yellow Taxi Trip Records" bulanan dari situs resmi NYC TLC.
    * **Link:** [https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page](https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page)
* **Data Zona Taksi (CSV):** Tabel lookup untuk menerjemahkan `LocationID` menjadi nama Borough dan Zona.
    * **Link:** [https://d37ci6vzurychx.cloudfront.net/misc/taxi_zone_lookup.csv](https://d37ci6vzurychx.cloudfront.net/misc/taxi_zone_lookup.csv)
* **Data Tipe Pembayaran (CSV):** Dibuat secara manual untuk menerjemahkan `payment_type_id`. Anda bisa menemukannya di `seeds/payment_types.csv`.

### 2. Setup Snowflake (Peran & Database)

Jalankan kode berikut di worksheet Snowflake (sebagai `ACCOUNTADMIN`) untuk menyiapkan semua peran, pengguna, database, dan warehouse yang diperlukan.

```sql
-- Membuat Warehouse (Mesin Komputasi)
CREATE OR REPLACE WAREHOUSE NYC_TAXI_WH
  WAREHOUSE_SIZE = 'X_SMALL'
  AUTO_SUSPEND = 60;

-- Membuat Database dan Schema
CREATE OR REPLACE DATABASE NYC_TAXI_DB;
CREATE OR REPLACE SCHEMA NYC_TAXI_DB.RAW;
CREATE OR REPLACE SCHEMA NYC_TAXI_DB.ANALYTICS;

-- Membuat Tabel Tujuan untuk Data Mentah
CREATE OR REPLACE TABLE NYC_TAXI_DB.RAW.TRIPS (
    VendorID INT,
    tpep_pickup_datetime TIMESTAMP_NTZ(9),
    tpep_dropoff_datetime TIMESTAMP_NTZ(9),
    passenger_count INT,
    trip_distance FLOAT,
    RatecodeID INT,
    store_and_fwd_flag VARCHAR(1),
    PULocationID INT,
    DOLocationID INT,
    payment_type INT,
    fare_amount FLOAT,
    extra FLOAT,
    mta_tax FLOAT,
    tip_amount FLOAT,
    tolls_amount FLOAT,
    improvement_surcharge FLOAT,
    total_amount FLOAT,
    congestion_surcharge FLOAT
);

-- Membuat File Format untuk Parquet
CREATE OR REPLACE FILE FORMAT my_parquet_format
  TYPE = 'PARQUET';

-- (...Kode untuk membuat Role dan User (DBT_USER, TABLEAU_USER) juga disertakan di sini...)
