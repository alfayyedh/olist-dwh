INSERT INTO final.dim_customer (
    customer_id,   
    customer_nk,
    customer_zip_code_prefix,
)

SELECT
    c.id AS customer_id,
    c.customer_id AS customer_nk,
    c.customer_zip_code_prefix
FROM
    stg.customers c
    
ON CONFLICT(customer_id) 
DO UPDATE SET
    customer_nk = EXCLUDED.customer_nk,
    customer_zip_code_prefix = EXCLUDED.customer_zip_code_prefix,
    updated_at = CASE WHEN 
                        final.dim_customer.customer_nk <> EXCLUDED.customer_nk
                        OR final.dim_customer.customer_zip_code_prefix <> EXCLUDED.customer_zip_code_prefix
                THEN 
                        CURRENT_TIMESTAMP
                ELSE
                        final.dim_customer.updated_at
                END;