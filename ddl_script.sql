CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    parent_category_id INT,
    FOREIGN KEY (parent_category_id) REFERENCES categories(id) ON DELETE SET NULL
);

CREATE TABLE order_statuses (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE payment_methods (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE payment_statuses (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(128) NOT NULL,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    is_active BOOLEAN DEFAULT true
);

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL CHECK (price > 0),
    category_id INT NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    sku VARCHAR(50) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    in_stock BOOLEAN DEFAULT true
);

CREATE TABLE warehouses (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address TEXT NOT NULL,
    capacity INT CHECK (capacity > 0)
);

CREATE TABLE inventory (
    product_id INT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    warehouse_id INT NOT NULL REFERENCES warehouses(id) ON DELETE CASCADE,
    quantity INT NOT NULL DEFAULT 0 CHECK (quantity >= 0),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (product_id, warehouse_id)
);

CREATE TABLE reviews (
    id SERIAL PRIMARY KEY,
    product_id INT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_verified_purchase BOOLEAN DEFAULT false
);

CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    amount DECIMAL(12,2) NOT NULL CHECK (amount > 0),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_method_id INT NOT NULL REFERENCES payment_methods(id) ON DELETE RESTRICT,
    status_id INT NOT NULL REFERENCES payment_statuses(id) ON DELETE RESTRICT
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status_id INT NOT NULL REFERENCES order_statuses(id) ON DELETE RESTRICT,
    shipping_address TEXT NOT NULL,
    total_amount DECIMAL(12,2) NOT NULL CHECK (total_amount >= 0),
    payment_id INT UNIQUE REFERENCES payments(id) ON DELETE SET NULL
);

CREATE TABLE order_items (
    order_id INT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id INT NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    quantity INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price > 0),
    PRIMARY KEY (order_id, product_id)
);

CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_status_id ON orders(status_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_payments_method_status ON payments(payment_method_id, status_id);

INSERT INTO order_statuses (name, description) VALUES
('created', 'Заказ создан'),
('confirmed', 'Заказ подтвержден'),
('paid', 'Заказ оплачен'),
('shipped', 'Заказ отправлен'),
('delivered', 'Заказ доставлен'),
('cancelled', 'Заказ отменен');

INSERT INTO payment_statuses (name, description) VALUES
('pending', 'Ожидает оплаты'),
('completed', 'Оплата завершена'),
('failed', 'Оплата не прошла'),
('refunded', 'Средства возвращены');

INSERT INTO payment_methods (name, description) VALUES
('credit_card', 'Оплата банковской картой'),
('cash_on_delivery', 'Наличные при получении'),
('electronic_wallet', 'Электронный кошелек');

INSERT INTO categories (name, description) VALUES
('electronics', 'Электроника'),
('smartphones', 'Смартфоны'),
('laptops', 'Ноутбуки'),
('accessories', 'Аксессуары');

INSERT INTO users (full_name, email, password_hash, registration_date, last_login, is_active)
VALUES 
('Иван Иванов', 'ivan@example.com', 'hash1', CURRENT_DATE - INTERVAL '60 days', CURRENT_DATE - INTERVAL '1 day', true),
('Мария Петрова', 'maria@example.com', 'hash2', CURRENT_DATE - INTERVAL '30 days', CURRENT_DATE - INTERVAL '2 days', true),
('Алексей Смирнов', 'alex@example.com', 'hash3', CURRENT_DATE - INTERVAL '15 days', CURRENT_DATE - INTERVAL '3 days', true);

INSERT INTO products (name, description, price, category_id, sku, in_stock)
VALUES 
('Смартфон X', 'Современный смартфон', 25000.00, 2, 'SKU001', true),
('Ноутбук Y', 'Мощный ноутбук', 55000.00, 3, 'SKU002', true),
('Наушники Z', 'Беспроводные наушники', 3500.00, 4, 'SKU003', true),
('Планшет A', 'Сенсорный планшет', 15000.00, 1, 'SKU004', true);

INSERT INTO orders (user_id, order_date, status_id, shipping_address, total_amount)
VALUES 
(1, CURRENT_DATE - INTERVAL '25 days', 3, 'г. Москва, ул. Ленина, д. 1', 25000.00),
(2, CURRENT_DATE - INTERVAL '20 days', 4, 'г. Санкт-Петербург, ул. Невский пр., д. 5', 55000.00),
(3, CURRENT_DATE - INTERVAL '15 days', 3, 'г. Екатеринбург, ул. Ленина, д. 10', 18500.00),
(1, CURRENT_DATE - INTERVAL '10 days', 2, 'г. Москва, ул. Ленина, д. 1', 3500.00),
(2, CURRENT_DATE - INTERVAL '5 days', 5, 'г. Санкт-Петербург, ул. Невский пр., д. 5', 15000.00);

INSERT INTO payments (amount, payment_date, payment_method_id, status_id)
VALUES 
(25000.00, CURRENT_DATE - INTERVAL '25 days', 1, 2),
(55000.00, CURRENT_DATE - INTERVAL '20 days', 2, 2),
(18500.00, CURRENT_DATE - INTERVAL '15 days', 3, 2),
(3500.00, CURRENT_DATE - INTERVAL '10 days', 1, 2),
(15000.00, CURRENT_DATE - INTERVAL '5 days', 2, 2);

UPDATE orders SET payment_id = 1 WHERE id = 1;
UPDATE orders SET payment_id = 2 WHERE id = 2;
UPDATE orders SET payment_id = 3 WHERE id = 3;
UPDATE orders SET payment_id = 4 WHERE id = 4;
UPDATE orders SET payment_id = 5 WHERE id = 5;

INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES 
(1, 1, 1, 25000.00),
(2, 2, 1, 55000.00),
(3, 3, 1, 3500.00),
(3, 4, 1, 15000.00),
(4, 3, 1, 3500.00),
(5, 4, 1, 15000.00);

TRUNCATE TABLE order_items, orders, payments, products, users, categories, inventory, reviews RESTART IDENTITY CASCADE;

INSERT INTO categories (name, description) VALUES
('electronics', 'Электроника'),
('smartphones', 'Смартфоны'),
('laptops', 'Ноутбуки'),
('accessories', 'Аксессуары')
ON CONFLICT (name) DO NOTHING;

INSERT INTO products (name, description, price, category_id, sku, in_stock)
SELECT 
    'Товар ' || i,
    'Описание товара ' || i,
    (random() * 10000 + 100)::numeric(10,2),
    (random() * 3 + 1)::integer,
    'SKU' || LPAD(i::text, 4, '0'),
    true
FROM generate_series(1, 100) AS i
ON CONFLICT (sku) DO NOTHING;

INSERT INTO users (full_name, email, password_hash, registration_date, last_login, is_active)
SELECT 
    'Пользователь ' || i,
    'user' || i || '@example.com',
    md5(random()::text),
    CURRENT_DATE - (random() * 365)::integer * INTERVAL '1 day',
    CURRENT_DATE - (random() * 30)::integer * INTERVAL '1 day',
    CASE WHEN random() > 0.1 THEN true ELSE false END
FROM generate_series(1, 1000) AS i;

INSERT INTO orders (user_id, order_date, status_id, shipping_address, total_amount)
SELECT 
    (random() * 999 + 1)::integer,
    CURRENT_DATE - (random() * 365)::integer * INTERVAL '1 day',
    (random() * 5 + 1)::integer,
    'Адрес ' || i,
    (random() * 10000 + 100)::numeric(10,2)
FROM generate_series(1, 5000) AS i;

INSERT INTO order_items (order_id, product_id, quantity, unit_price)
SELECT 
    o.id,
    p.id,
    (random() * 5 + 1)::integer,
    p.price
FROM orders o
CROSS JOIN (
    SELECT id, price 
    FROM products 
    ORDER BY random() 
    LIMIT 4
) p
ORDER BY random()
LIMIT 10000;