-- Catalog
CREATE TABLE artist (
    id    BIGSERIAL PRIMARY KEY,
    name  VARCHAR(200) NOT NULL
);

CREATE TABLE genre (
    id    BIGSERIAL PRIMARY KEY,
    name  VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE record (
    id            BIGSERIAL PRIMARY KEY,
    sku           VARCHAR(50)   NOT NULL UNIQUE,
    title         VARCHAR(200)  NOT NULL,
    artist_id     BIGINT        NOT NULL REFERENCES artist(id) ON DELETE RESTRICT,
    genre_id      BIGINT        NOT NULL REFERENCES genre(id)  ON DELETE RESTRICT,
    release_year  INTEGER       NOT NULL,
    price         NUMERIC(10,2) NOT NULL CHECK (price > 0),
    stock         INTEGER       NOT NULL DEFAULT 0 CHECK (stock >= 0),
    version       BIGINT        NOT NULL DEFAULT 0
);

CREATE INDEX idx_record_artist_id ON record(artist_id);
CREATE INDEX idx_record_genre_id  ON record(genre_id);
CREATE INDEX idx_record_year      ON record(release_year);
CREATE INDEX idx_record_price     ON record(price);

-- Customers and orders
CREATE TABLE customer (
    id          BIGSERIAL PRIMARY KEY,
    email       VARCHAR(255) NOT NULL UNIQUE,
    full_name   VARCHAR(200) NOT NULL,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE TABLE orders (
    id           BIGSERIAL PRIMARY KEY,
    customer_id  BIGINT      NOT NULL REFERENCES customer(id) ON DELETE RESTRICT,
    status       VARCHAR(20) NOT NULL DEFAULT 'PENDING'
                 CHECK (status IN ('PENDING', 'PAID', 'SHIPPED', 'CANCELLED')),
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_orders_customer_id ON orders(customer_id);

CREATE TABLE order_item (
    id          BIGSERIAL PRIMARY KEY,
    order_id    BIGINT        NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    record_id   BIGINT        NOT NULL REFERENCES record(id) ON DELETE RESTRICT,
    quantity    INTEGER       NOT NULL CHECK (quantity > 0),
    unit_price  NUMERIC(10,2) NOT NULL CHECK (unit_price > 0),
    UNIQUE (order_id, record_id)
);

CREATE INDEX idx_order_item_order_id ON order_item(order_id);
CREATE INDEX idx_order_item_record_id ON order_item(record_id);
