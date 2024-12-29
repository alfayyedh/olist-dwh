INSERT INTO final.dim_customer (
    customer_id,   
    customer_nk,
    geolocation_id
)

SELECT
    c.id AS customer_id,
    c.customer_id AS customer_nk,
    dg.geolocation_id
FROM
    stg.customers c
JOIN
    final.dim_geolocation dg ON dg.geolocation_zip_code_prefix = c.customer_zip_code_prefix
    
ON CONFLICT(customer_id) 
DO UPDATE SET
    customer_nk = EXCLUDED.customer_nk,
    geolocation_id = EXCLUDED.geolocation_id,
    updated_at = CASE WHEN 
                        final.dim_customer.customer_nk <> EXCLUDED.customer_nk
                        OR final.dim_customer.geolocation_id <> EXCLUDED.geolocation_id
                THEN 
                        CURRENT_TIMESTAMP
                ELSE
                        final.dim_customer.updated_at
                END;