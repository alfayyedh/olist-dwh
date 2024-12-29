INSERT INTO final.dim_product (
    product_id,
    product_nk,
    product_category_name,
    product_category_name_english
)

SELECT
    p.id AS product_id,
    p.product_id AS product_nk,
    p.product_category_name,
    pc.product_category_name_english
	
FROM
    stg.products p
JOIN
    stg.product_category_name_translation pc ON p.product_category_name = pc.product_category_name
    
ON CONFLICT(product_id) 
DO UPDATE SET
    product_nk = EXCLUDED.product_nk,
    product_category_name = EXCLUDED.product_category_name,
    product_category_name_english = EXCLUDED.product_category_name_english,
    updated_at = CASE WHEN 
                        final.dim_product.product_nk <> EXCLUDED.product_nk
                        OR final.dim_product.product_category_name <> EXCLUDED.product_category_name
                        OR final.dim_product.product_category_name_english <> EXCLUDED.product_category_name_english
                THEN 
                        CURRENT_TIMESTAMP
                ELSE
                        final.dim_product.updated_at
                END;