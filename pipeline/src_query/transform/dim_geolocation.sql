INSERT INTO final.dim_geolocation (
    geolocation_id,
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
)

SELECT
    g.id as geolocation_id,
    g.geolocation_zip_code_prefix,
    g.geolocation_lat,
    g.geolocation_lng,
    g.geolocation_city,
    g.geolocation_state
FROM 
    stg.geolocation g

ON CONFLICT(geolocation_id)
DO UPDATE SET 
    geolocation_zip_code_prefix = EXCLUDED.geolocation_zip_code_prefix, 
    geolocation_lat = EXCLUDED.geolocation_lat,
    geolocation_lng = EXCLUDED.geolocation_lng,
    geolocation_city = EXCLUDED.geolocation_city,
    geolocation_state = EXCLUDED.geolocation_state,
    updated_at = CASE WHEN
                        final.dim_geolocation.geolocation_zip_code_prefix <> EXCLUDED.geolocation_zip_code_prefix
                        OR final.dim_geolocation.geolocation_lat <> EXCLUDED.geolocation_lat
                        OR final.dim_geolocation.geolocation_lng <> EXCLUDED.geolocation_lng
                        OR final.dim_geolocation.geolocation_city <> EXCLUDED.geolocation_city
                        OR final.dim_geolocation.geolocation_state <> EXCLUDED.geolocation_state
                THEN
                        CURRENT_TIMESTAMP
                ELSE
                        final.dim_geolocation.updated_at
                END;