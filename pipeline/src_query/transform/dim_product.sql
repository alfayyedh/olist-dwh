INSERT INTO final.dim_product (
    product_id,
    product_nk,
    product_category_name,
    product_category_name_english
)

SELECT
    p.id AS product_id,
    p.product_id AS product_nk,
    product_category_name
	
FROM
    stg.products p
    
ON CONFLICT(product_id) 
DO UPDATE SET
    product_nk = EXCLUDED.product_nk,
    product_category_name = EXCLUDED.product_category_name,
    updated_at = CASE WHEN 
                        final.dim_products.product_nk <> EXCLUDED.product_nk
                        OR final.dim_products.product_category_name <> EXCLUDED.product_category_name,
                THEN 
                        CURRENT_TIMESTAMP
                ELSE
                        final.dim_products.updated_at
                END;