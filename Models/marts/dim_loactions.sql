-- Cukup ambil data bersih dari seed
select
    LocationID as location_id,
    Borough as borough,
    Zone as zone,
    service_zone
from {{ ref('taxi_zone_lookup') }}
