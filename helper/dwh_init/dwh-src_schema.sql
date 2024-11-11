-- DWH Public Schema

-- Drop table

-- DROP TABLE product_category_name_translation;

CREATE TABLE product_category_name_translation (
	product_category_name text NOT NULL,
    product_category_name_english text,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
);

-- Permissions

ALTER TABLE product_category_name_translation OWNER TO postgres;
GRANT ALL ON TABLE product_category_name_translation TO postgres;

-- products definition

-- Drop table

-- DROP TABLE products;

CREATE TABLE products (
	product_id text NOT NULL,
    product_category_name text,
    product_name_lenght real,
    product_description_lenght real,
    product_photos_qty real,
    product_weight_g real,
    product_length_cm real,
    product_height_cm real,
    product_width_cm real
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT products_pkey PRIMARY KEY (product_id),
	CONSTRAINT product_category_fkey FOREIGN KEY (product_category_name) REFERENCES product_category_name_translation(product_category_name)
);

-- Permissions

ALTER TABLE products OWNER TO postgres;
GRANT ALL ON TABLE products TO postgres;


-- Drop table

-- DROP TABLE customers;

-- geolocation definition

-- Drop table

-- DROP TABLE geolocation;

CREATE TABLE geolocation (
	geolocation_zip_code_prefix integer NOT NULL,
    geolocation_lat real,
    geolocation_lng real,
    geolocation_city text,
    geolocation_state text
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT geolocation_pkey PRIMARY KEY (geolocation_zip_code_prefix)
);

-- Permissions

ALTER TABLE geolocation OWNER TO postgres;
GRANT ALL ON TABLE geolocation TO postgres;

-- sellers definition

-- Drop table

-- DROP TABLE sellers;

CREATE TABLE sellers (
	seller_id text NOT NULL,
    seller_zip_code_prefix integer,
    seller_city text,
    seller_state text
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT sellers_pkey PRIMARY KEY (seller_id),
	CONSTRAINT geolocation_fkey FOREIGN KEY (seller_zip_code_prefix) REFERENCES geolocationation(geolocation_zip_code_prefix)
);

-- Permissions

ALTER TABLE sellers OWNER TO postgres;
GRANT ALL ON TABLE sellers TO postgres;

-- Drop table

-- DROP TABLE sorder_reviews;

CREATE TABLE order_reviews (
	review_id text NOT NULL,
    order_id text NOT NULL,
    review_score integer,
    review_comment_title text,
    review_comment_message text,
    review_creation_date text,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT order_reviews_pkey PRIMARY KEY (order_id)
);

-- Permissions

ALTER TABLE order_reviews OWNER TO postgres;
GRANT ALL ON TABLE order_reviews TO postgres;

-- Drop table

-- DROP TABLE customers;

CREATE TABLE customers (
	customer_id text NOT NULL,
    customer_unique_id text,
    customer_zip_code_prefix integer,
    customer_city text,
    customer_state text
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT customer_pkey PRIMARY KEY (customer_id),
    CONSTRAINT customer_zip_code_prefix_fkey FOREIGN KEY (customer_zip_code_prefix) REFERENCES geolocation(geolocation_zip_code_prefix)
);

-- Permissions

ALTER TABLE customers OWNER TO postgres;
GRANT ALL ON TABLE customers TO postgres;

-- order_payments definition

-- Drop table

-- DROP TABLE order_payments;

CREATE TABLE order_payments (
	order_id text NOT NULL,
    payment_sequential integer NOT NULL,
    payment_type text,
    payment_installments integer,
    payment_value real
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	-- CONSTRAINT order_payments_check CHECK ((scheduled_arrival > scheduled_departure)),
	-- CONSTRAINT order_payments_check1 CHECK (((actual_arrival IS NULL) OR ((actual_departure IS NOT NULL) AND (actual_arrival IS NOT NULL) AND (actual_arrival > actual_departure)))),
	-- CONSTRAINT order_payments_flight_no_scheduled_departure_key UNIQUE (flight_no, scheduled_departure),
	CONSTRAINT order_payments_pkey PRIMARY KEY (order_id)
);

-- Permissions

ALTER TABLE order_payments OWNER TO postgres;
GRANT ALL ON TABLE order_payments TO postgres;


-- order_items definition

-- Drop table

-- DROP TABLE 

CREATE TABLE order_items (
	order_id text NOT NULL,
    order_item_id integer NOT NULL,
    product_id text,
    seller_id text,
    shipping_limit_date text,
    price real,
    freight_value real
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT order_items_pkey PRIMARY KEY (order_id),
    CONSTRAINT products_fkey FOREIGN KEY (product_id) REFERENCES products(product_id),
    CONSTRAINT sellers_fkey FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);

-- Permissions

ALTER TABLE order_items OWNER TO postgres;
GRANT ALL ON TABLE order_items TO postgres;


-- orders definition

-- Drop table

-- DROP TABLE orders;

CREATE TABLE orders (
    order_id text NOT NULL,
    customer_id text,
    order_status text,
    order_purchase_timestamp text,
    order_approved_at text,
    order_delivered_carrier_date text,
    order_delivered_customer_date text,
    order_estimated_delivery_date text
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT orders_pkey PRIMARY KEY (order_id),
    CONSTRAINT customer_id_fkey FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT order_items_fkey FOREIGN KEY (order_id) REFERENCES order_items(order_id),
    CONSTRAINT order_payments_fkey FOREIGN KEY (order_id) REFERENCES order_payments(order_id),
    CONSTRAINT order_reviews_fkey FOREIGN KEY (order_id) REFERENCES order_reviews(order_id)

-- Permissions

ALTER TABLE orders OWNER TO postgres;
GRANT ALL ON TABLE orders TO postgres;
