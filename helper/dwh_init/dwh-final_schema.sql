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
);

-- dim customer
CREATE TABLE final.dim_customer (
    customer_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    customer_nk text NOT NULL,
    geolocation_id UUID,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_geolocation_id FOREIGN KEY (geolocation_id) REFERENCES final.dim_geolocation(geolocation_id)
);

-- dim product
CREATE TABLE final.dim_product (
    product_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    product_nk text NOT NULL,
    product_category_name VARCHAR(50),
    product_category_name_english VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- fact order
CREATE TABLE final.fct_order_delivery (
    order_delivery_id UUID DEFAULT uuid_generate_v4(),
    order_id UUID,
    customer_id UUID,
    order_purchase_date INT,
    order_approved_at_date INT,
    order_delivered_carrier_date INT,
    order_delivered_customer_date INT,
    order_estimated_delivery_date INT,
    day_process INT,
    day_success INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- Constraint
    CONSTRAINT fk_customer_id FOREIGN KEY (customer_id) REFERENCES final.dim_customer(customer_id),
    CONSTRAINT fk_order_purchase_date FOREIGN KEY (order_purchase_date) REFERENCES final.dim_date(date_id),
    CONSTRAINT fk_order_approved_at_date FOREIGN KEY (order_approved_at_date) REFERENCES final.dim_date(date_id),
    CONSTRAINT fk_order_delivered_carrier_date FOREIGN KEY (order_delivered_carrier_date) REFERENCES final.dim_date(date_id),
    CONSTRAINT fk_order_delivered_customer_date FOREIGN KEY (order_delivered_customer_date) REFERENCES final.dim_date(date_id),
    CONSTRAINT fk_order_estimated_delivery_date FOREIGN KEY (order_estimated_delivery_date) REFERENCES final.dim_date(date_id)
);

ALTER TABLE final.fct_order_delivery
ADD CONSTRAINT fct_order_pkey PRIMARY KEY (order_delivery_id, order_id, customer_id);

-- fact review
CREATE TABLE final.fct_review (
    review_id UUID DEFAULT uuid_generate_v4(),
    dd_review_id text NOT NULL,
    order_id UUID,
    customer_id UUID,
    city text,
    product_id UUID,
    order_status VARCHAR(30),
    review_score INT,
    review_comment_title VARCHAR(200),
    review_comment_message VARCHAR(500),
    review_creation_date INT,
    payment_value INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- Constraint
    CONSTRAINT fk_customer_id FOREIGN KEY (customer_id) REFERENCES final.dim_customer(customer_id),
    CONSTRAINT fk_review_creation_date FOREIGN KEY (review_creation_date) REFERENCES final.dim_date(date_id),
    CONSTRAINT fk_product_id FOREIGN KEY (product_id) REFERENCES final.dim_product(product_id)
);

ALTER TABLE final.fct_review
ADD CONSTRAINT fct_review_pkey PRIMARY KEY (review_id, dd_review_id, order_id, customer_id, product_id);

--Populating data

-- 1. Insert data into dim_date table
WITH calendar_cte AS (
    SELECT 
        seq::DATE AS date_actual
    FROM generate_series(
        '2000-01-01'::DATE, 
        '2050-12-31'::DATE, 
        '1 day'::INTERVAL
    ) seq
)

INSERT INTO final.dim_date (
    date_id,
    date_actual,
    day_suffix,
    day_name,
    day_of_year,
    week_of_month,
    week_of_year,
    week_of_year_iso,
    month_actual,
    month_name,
    month_name_abbreviated,
    quarter_actual,
    quarter_name,
    year_actual,
    first_day_of_week,
    last_day_of_week,
    first_day_of_month,
    last_day_of_month,
    first_day_of_quarter,
    last_day_of_quarter,
    first_day_of_year,
    last_day_of_year,
    mmyyyy,
    mmddyyyy,
    weekend_indr
)
SELECT
    TO_CHAR(date_actual, 'YYYYMMDD')::INT AS date_id,
    date_actual,
    TO_CHAR(date_actual, 'DDth') AS day_suffix,
    TO_CHAR(date_actual, 'Day') AS day_name,
    EXTRACT(DOY FROM date_actual) AS day_of_year,
    CEIL(EXTRACT(DAY FROM date_actual) / 7.0) AS week_of_month,
    EXTRACT(WEEK FROM date_actual) AS week_of_year,
    TO_CHAR(date_actual, 'IYYY-IW') AS week_of_year_iso,
    EXTRACT(MONTH FROM date_actual) AS month_actual,
    TO_CHAR(date_actual, 'Month') AS month_name,
    TO_CHAR(date_actual, 'Mon') AS month_name_abbreviated,
    EXTRACT(QUARTER FROM date_actual) AS quarter_actual,
    CASE EXTRACT(QUARTER FROM date_actual)
        WHEN 1 THEN 'First'
        WHEN 2 THEN 'Second'
        WHEN 3 THEN 'Third'
        WHEN 4 THEN 'Fourth'
    END AS quarter_name,
    EXTRACT(YEAR FROM date_actual) AS year_actual,
    date_actual - (EXTRACT(DOW FROM date_actual)::INT) AS first_day_of_week,
    date_actual + (6 - EXTRACT(DOW FROM date_actual)::INT) AS last_day_of_week,
    date_trunc('month', date_actual)::DATE AS first_day_of_month,
    (date_trunc('month', date_actual) + '1 month - 1 day'::INTERVAL)::DATE AS last_day_of_month,
    date_trunc('quarter', date_actual)::DATE AS first_day_of_quarter,
    (date_trunc('quarter', date_actual) + '3 months - 1 day'::INTERVAL)::DATE AS last_day_of_quarter,
    date_trunc('year', date_actual)::DATE AS first_day_of_year,
    (date_trunc('year', date_actual) + '1 year - 1 day'::INTERVAL)::DATE AS last_day_of_year,
    TO_CHAR(date_actual, 'MMYYYY') AS mmyyyy,
    TO_CHAR(date_actual, 'MMDDYYYY') AS mmddyyyy,
    CASE WHEN EXTRACT(DOW FROM date_actual) IN (0, 6) THEN 'Weekend' ELSE 'Weekday' END AS weekend_indr
FROM calendar_cte;

-- 2. Insert data to dim_time
WITH time_cte AS (
    SELECT 
        (generate_series(
            '2024-12-25 00:00:00'::TIMESTAMP, 
            '2024-12-25 23:59:00'::TIMESTAMP, 
            '1 minute'::INTERVAL
        )::TIME) AS time_actual
)
INSERT INTO final.dim_time (
    time_id, 
    time_actual, 
    hours_24, 
    hours_12, 
    hour_minutes, 
    day_minutes, 
    day_time_name, 
    day_night
)
SELECT 
    CAST(TO_CHAR(time_actual, 'HH24MI') AS INTEGER) AS time_id, -- Unique ID for each minute
    time_actual,
    LPAD(CAST(EXTRACT(HOUR FROM time_actual) AS TEXT), 2, '0') AS hours_24, -- 24-hour format
    LPAD(CAST((EXTRACT(HOUR FROM time_actual) % 12) AS TEXT), 2, '0') AS hours_12, -- 12-hour format
    LPAD(CAST(EXTRACT(MINUTE FROM time_actual) AS TEXT), 2, '0') AS hour_minutes, -- Minutes of the hour
    (EXTRACT(HOUR FROM time_actual) * 60 + EXTRACT(MINUTE FROM time_actual)) AS day_minutes, -- Total minutes since midnight
    CASE 
        WHEN EXTRACT(HOUR FROM time_actual) BETWEEN 5 AND 11 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM time_actual) BETWEEN 12 AND 17 THEN 'Afternoon'
        WHEN EXTRACT(HOUR FROM time_actual) BETWEEN 18 AND 20 THEN 'Evening'
        ELSE 'Night'
    END AS day_time_name, -- Part of the day
    CASE 
        WHEN EXTRACT(HOUR FROM time_actual) BETWEEN 6 AND 18 THEN 'Day'
        ELSE 'Night'
    END AS day_night -- Day/Night indicator
FROM time_cte;
