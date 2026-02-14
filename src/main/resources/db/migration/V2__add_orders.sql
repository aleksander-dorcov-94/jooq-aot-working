CREATE TABLE purchase_orders
(
    id        SERIAL PRIMARY KEY,
    item_name VARCHAR(255),
    price     DECIMAL(10, 2),
    user_id   INTEGER, -- Standard 1:N relationship
    -- 3. Fixed the missing space in REFERENCES
    CONSTRAINT fk_order_user FOREIGN KEY (user_id) REFERENCES users (id)
);

INSERT INTO purchase_orders (item_name, price, user_id)
VALUES ('Mechanical Keyboard', 120.00, 1);

INSERT INTO purchase_orders (item_name, price, user_id)
VALUES ('Wireless Mouse', 50.00, 1);
