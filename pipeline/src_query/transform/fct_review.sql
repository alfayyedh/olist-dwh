INSERT INTO final.fct_review (
    dd_review_id,
    order_id,
    customer_id,
    city,
    product_id,
    order_status,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    payment_value    
)

SELECT DISTINCT 
     review_id as dd_review_id,
     so.order_id::uuid,
     dc.customer_id,
     dg.geolocation_city as city,
     dp.product_id,
     so.order_status,
     sor.review_score,
     sor.review_comment_title,
     sor.review_comment_message,
     dd1.date_id AS review_creation_date,
     sop.payment_value
FROM 
     stg.orders so
JOIN
     final.dim_customer dc ON so.customer_id = dc.customer_nk
JOIN
     final.dim_geolocation dg ON dg.geolocation_id = dc.geolocation_id
JOIN
     stg.order_reviews sor ON sor.order_id = so.order_id
JOIN
     final.dim_date dd1 ON dd1.date_actual = TO_DATE(sor.review_creation_date::text, 'YYYY-MM-DD')
JOIN
     stg.order_payments sop ON sop.order_id = so.order_id
JOIN
     stg.order_items soi ON soi.order_id = so.order_id
JOIN
     final.dim_product dp ON dp.product_nk = soi.product_id

ON CONFLICT(review_id, dd_review_id, order_id, customer_id, product_id) 
DO UPDATE SET
    city = EXCLUDED.city,
    order_status = EXCLUDED.order_status,
    review_score = EXCLUDED.review_score,
    review_comment_title = EXCLUDED.review_comment_title,
    review_comment_message = EXCLUDED.review_comment_message,
    review_creation_date = EXCLUDED.review_creation_date,
    payment_value = EXCLUDED.payment_value,
    updated_at = CASE WHEN 
                        final.fct_review.city <> EXCLUDED.city
                        OR final.fct_review.order_status <> EXCLUDED.order_status
                        OR final.fct_review.review_score <> EXCLUDED.review_score
                        OR final.fct_review.review_comment_title <> EXCLUDED.review_comment_title
                        OR final.fct_review.review_comment_message <> EXCLUDED.review_comment_message
                        OR final.fct_review.review_creation_date <> EXCLUDED.review_creation_date
                        OR final.fct_review.payment_value <> EXCLUDED.payment_value
                THEN 
                        CURRENT_TIMESTAMP
                ELSE
                        final.fct_review.updated_at
                END;