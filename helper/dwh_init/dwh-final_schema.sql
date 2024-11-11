CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- CREATE SCHEMA FOR FINAL AREA
CREATE SCHEMA IF NOT EXISTS final AUTHORIZATION postgres;

--------------------------------------------------------------------------------------------------------------------------------- FINAL SCHEMA
-- time dimension
DROP TABLE if exists final.dim_time;
CREATE TABLE final.dim_time
(
	time_id integer NOT NULL,
	time_actual time NOT NULL,
	hours_24 character(2) NOT NULL,
	hours_12 character(2) NOT NULL,
	hour_minutes character (2)  NOT NULL,
	day_minutes integer NOT NULL,
	day_time_name character varying (20) NOT NULL,
	day_night character varying (20) NOT NULL,
	CONSTRAINT time_pk PRIMARY KEY (time_id)
);

DROP TABLE if exists final.dim_date;
CREATE TABLE final.dim_date
(
  date_id                  INT NOT null primary KEY,
  date_actual              DATE NOT NULL,
  day_suffix               VARCHAR(4) NOT NULL,
  day_name                 VARCHAR(9) NOT NULL,
  day_of_year              INT NOT NULL,
  week_of_month            INT NOT NULL,
  week_of_year             INT NOT NULL,
  week_of_year_iso         CHAR(10) NOT NULL,
  month_actual             INT NOT NULL,
  month_name               VARCHAR(9) NOT NULL,
  month_name_abbreviated   CHAR(3) NOT NULL,
  quarter_actual           INT NOT NULL,
  quarter_name             VARCHAR(9) NOT NULL,
  year_actual              INT NOT NULL,
  first_day_of_week        DATE NOT NULL,
  last_day_of_week         DATE NOT NULL,
  first_day_of_month       DATE NOT NULL,
  last_day_of_month        DATE NOT NULL,
  first_day_of_quarter     DATE NOT NULL,
  last_day_of_quarter      DATE NOT NULL,
  first_day_of_year        DATE NOT NULL,
  last_day_of_year         DATE NOT NULL,
  mmyyyy                   CHAR(6) NOT NULL,
  mmddyyyy                 CHAR(10) NOT NULL,
  weekend_indr             VARCHAR(20) NOT NULL
);

CREATE INDEX dim_date_date_actual_idx
  ON final.dim_date(date_actual);

-- dim customer
CREATE TABLE final.dim_customer (
    customer_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    customer_nk VARCHAR(20) NOT NULL,
    customer_zip_code_prefix INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)

-- dim product
CREATE TABLE final.dim_product (
    product_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    product_nk VARCHAR(20) NOT NULL,
    product_category_name VARCHAR(50),
    product_category_name_english VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)

-- dim geolocation
CREATE TABLE final.dim_geolocation (
    geolocation_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    geolocation_zip_code_prefix INT NOT NULL,
    geolocation_lat INT,
    geolocation_lng INT,
    geolocation_city VARCHAR(50),
    geolocation_state VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)

-- fact delivery
CREATE TABLE final.fct_delivery (
    delivery_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    order_id INT NOT NULL,
    customer_id VARCHAR(100),
    order_status VARCHAR(30),
    order_purchase_date INT,
    order_purchase_time INT,
    order_approved_at_date INT,
    order_approved_at_time INT,
    order_delivered_carrier_date INT,
    order_delivered_carrier_time INT,
    order_delivered_customer_date INT,
    order_delivered_customer_time INT,
    order_estimated_delivery_date INT,
    order_estimated_delivery_time INT,
    shipping_limit_date INT,
    shipping_limit_time INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- Constraint
    CONSTRAINT fk_customer_id FOREIGN KEY (customer_id) REFERENCES final.dim_customer(customer_id),
    CONSTRAINT fk_order_purchase_date FOREIGN KEY (order_purchase_date) REFERENCES final.dim_date(date_id),
    CONSTRAINT fk_order_purchase_time FOREIGN KEY (order_purchase_time) REFERENCES final.dim_time(time_id),
    CONSTRAINT fk_order_approved_at_date FOREIGN KEY (order_approved_at_date) REFERENCES final.dim_date(date_id),
    CONSTRAINT fk_order_approved_at_time FOREIGN KEY (order_approved_at_time) REFERENCES final.dim_time(time_id),
    CONSTRAINT fk_order_delivered_carrier_date FOREIGN KEY (order_delivered_carrier_date) REFERENCES final.dim_date(date_id),
    CONSTRAINT fk_order_delivered_carrier_time FOREIGN KEY (order_delivered_carrier_time) REFERENCES final.dim_time(time_id),
    CONSTRAINT fk_order_delivered_customer_date FOREIGN KEY (order_delivered_customer_date) REFERENCES final.dim_date(date_id),
    CONSTRAINT fk_order_delivered_customer_time FOREIGN KEY (order_delivered_customer_time) REFERENCES final.dim_time(time_id),
    CONSTRAINT fk_order_estimated_delivery_date FOREIGN KEY (order_estimated_delivery_date) REFERENCES final.dim_date(date_id),
    CONSTRAINT fk_order_estimated_delivery_time FOREIGN KEY (order_estimated_delivery_time) REFERENCES final.dim_time(time_id),
    CONSTRAINT fk_shipping_limit_date FOREIGN KEY (shipping_limit_date) REFERENCES final.dim_date(date_id),
    CONSTRAINT fk_shipping_limit_time FOREIGN KEY (shipping_limit_time) REFERENCES final.dim_time(time_id),
)

-- fact transaction
CREATE TABLE final.fct_review (
    transaction_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    order_id INT NOT NULL,
    customer_id VARCHAR(100),
    order_status VARCHAR(30),
    review_score INT,
    review_comment_title VARCHAR(200),
    review_comment_message VARCHAR(500),
    review_creation_date INT,
    payment_value INT,
    product_id VARCHAR(100),
    geolocation_zip_code_prefix INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- Constraint
    CONSTRAINT fk_customer_id FOREIGN KEY (customer_id) REFERENCES final.dim_customer(customer_id),
    CONSTRAINT fk_review_creation_date FOREIGN KEY (review_creation_date) REFERENCES final.dim_date(date_id),
    CONSTRAINT fk_product_id FOREIGN KEY (product_id) REFERENCES final.dim_product(product_id),
    CONSTRAINT fk_geolocation_zip_code_prefix FOREIGN KEY (geolocation_zip_code_prefix) REFERENCES final.dim_geolocation(geolocation_zip_code_prefix)
)