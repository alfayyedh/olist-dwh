CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- CREATE SCHEMA FOR STAGING
CREATE SCHEMA IF NOT EXISTS stg AUTHORIZATION postgres;

-- stg.products_category_name_translation definition

-- Drop table

-- DROP TABLE stg.product_category_name_translation;

CREATE TABLE stg.product_category_name_translation (
	id uuid default uuid_generate_v4(),
    product_category_name text NOT NULL,
    product_category_name_english text,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
);

-- Permissions

ALTER TABLE stg.product_category_name_translation OWNER TO postgres;
GRANT ALL ON TABLE stg.product_category_name_translation TO postgres;

-- stg.products definition

-- Drop table

-- DROP TABLE stg.products;

CREATE TABLE stg.products (
	id uuid default uuid_generate_v4(),
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
	CONSTRAINT product_category_fkey FOREIGN KEY (product_category_name) REFERENCES stg.product_category_name_translation(product_category_name)
);

-- Permissions

ALTER TABLE stg.products OWNER TO postgres;
GRANT ALL ON TABLE stg.products TO postgres;

-- stg.geolocation definition

-- Drop table

-- DROP TABLE stg.geolocation;

CREATE TABLE stg.geolocation (
	id uuid default uuid_generate_v4(),
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

ALTER TABLE stg.geolocation OWNER TO postgres;
GRANT ALL ON TABLE stg.geolocation TO postgres;

-- stg.sellers definition

-- Drop table

-- DROP TABLE stg.sellers;

CREATE TABLE stg.sellers (
	id uuid default uuid_generate_v4(),
    seller_id text NOT NULL,
    seller_zip_code_prefix integer,
    seller_city text,
    seller_state text
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT sellers_pkey PRIMARY KEY (seller_id),
	CONSTRAINT geolocation_fkey FOREIGN KEY (seller_zip_code_prefix) REFERENCES stg.geolocationation(geolocation_zip_code_prefix)
);

-- Permissions

ALTER TABLE stg.sellers OWNER TO postgres;
GRANT ALL ON TABLE stg.sellers TO postgres;

-- stg.order_reviews definition

-- Drop table

-- DROP TABLE stg.sorder_reviews;

CREATE TABLE stg.order_reviews (
	id uuid default uuid_generate_v4(),
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

ALTER TABLE stg.order_reviews OWNER TO postgres;
GRANT ALL ON TABLE stg.order_reviews TO postgres;

-- stg.customers definition

-- Drop table

-- DROP TABLE stg.customers;

CREATE TABLE stg.customers (
	id uuid default uuid_generate_v4(),
    customer_id text NOT NULL,
    customer_unique_id text,
    customer_zip_code_prefix integer,
    customer_city text,
    customer_state text
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT customer_pkey PRIMARY KEY (customer_id),
    CONSTRAINT customer_zip_code_prefix_fkey FOREIGN KEY (customer_zip_code_prefix) REFERENCES stg.geolocation(geolocation_zip_code_prefix)
);

-- Permissions

ALTER TABLE stg.customers OWNER TO postgres;
GRANT ALL ON TABLE stg.customers TO postgres;

-- stg.order_payments definition

-- Drop table

-- DROP TABLE stg.order_payments;

CREATE TABLE stg.order_payments (
	id uuid default uuid_generate_v4(),
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

ALTER TABLE stg.order_payments OWNER TO postgres;
GRANT ALL ON TABLE stg.order_payments TO postgres;


-- stg.order_items definition

-- Drop table

-- DROP TABLE stg.stg;

CREATE TABLE stg.order_items (
	id uuid default uuid_generate_v4(),
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
    CONSTRAINT products_fkey FOREIGN KEY (product_id) REFERENCES stg.products(product_id),
    CONSTRAINT sellers_fkey FOREIGN KEY (seller_id) REFERENCES stg.sellers(seller_id)
);

-- Permissions

ALTER TABLE stg.order_items OWNER TO postgres;
GRANT ALL ON TABLE stg.order_items TO postgres;


-- stg.orders definition

-- Drop table

-- DROP TABLE stg.orders;

CREATE TABLE stg.orders (
    id uuid default uuid_generate_v4(),
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
    CONSTRAINT customer_id_fkey FOREIGN KEY (customer_id) REFERENCES stg.customers(customer_id),
    CONSTRAINT order_items_fkey FOREIGN KEY (order_id) REFERENCES stg.order_items(order_id),
    CONSTRAINT order_payments_fkey FOREIGN KEY (order_id) REFERENCES stg.order_payments(order_id),
    CONSTRAINT order_reviews_fkey FOREIGN KEY (order_id) REFERENCES stg.order_reviews(order_id)

-- Permissions

ALTER TABLE stg.orders OWNER TO postgres;
GRANT ALL ON TABLE stg.orders TO postgres;