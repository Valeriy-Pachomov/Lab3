-- ------------------------------------------
-- 1. HUBS (ХАБЫ)
-- ------------------------------------------

-- Хаб Сотрудников
CREATE TABLE hub_employee (
    hk_employee VARCHAR(32) PRIMARY KEY, -- MD5 хэш от бизнес-ключа
    employee_email VARCHAR(100) NOT NULL, -- Бизнес-ключ
    load_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL
);

-- Хаб Клиентов
CREATE TABLE hub_customer (
    hk_customer VARCHAR(32) PRIMARY KEY,
    customer_id_bk VARCHAR(50) NOT NULL, -- Бизнес-ключ из исходной системы
    load_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL
);

-- Хаб Товаров
CREATE TABLE hub_product (
    hk_product VARCHAR(32) PRIMARY KEY,
    product_sku VARCHAR(50) NOT NULL, -- Бизнес-ключ (артикул)
    load_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL
);

-- Хаб Заказов
CREATE TABLE hub_order (
    hk_order VARCHAR(32) PRIMARY KEY,
    order_number_bk VARCHAR(50) NOT NULL, -- Бизнес-ключ (номер заказа)
    load_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL
);

-- ------------------------------------------
-- 2. LINKS (СВЯЗИ)
-- ------------------------------------------

-- Ссылка, объединяющая Заказ, создавшего его Сотрудника и купившего Клиента
CREATE TABLE lnk_order_placement (
    hk_order_placement VARCHAR(32) PRIMARY KEY,
    hk_order VARCHAR(32) NOT NULL REFERENCES hub_order(hk_order),
    hk_employee VARCHAR(32) NOT NULL REFERENCES hub_employee(hk_employee),
    hk_customer VARCHAR(32) NOT NULL REFERENCES hub_customer(hk_customer),
    load_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL
);

-- Ссылка, связывающая Заказ и Товары внутри него (Позиции)
CREATE TABLE lnk_order_item (
    hk_order_item VARCHAR(32) PRIMARY KEY,
    hk_order VARCHAR(32) NOT NULL REFERENCES hub_order(hk_order),
    hk_product VARCHAR(32) NOT NULL REFERENCES hub_product(hk_product),
    load_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL
);

-- ------------------------------------------
-- 3. SATELLITES (САТЕЛЛИТЫ)
-- ------------------------------------------

-- Сателлит данных сотрудника
CREATE TABLE sat_employee (
    hk_employee VARCHAR(32) NOT NULL REFERENCES hub_employee(hk_employee),
    load_date TIMESTAMP NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    hire_date DATE,
    hash_diff VARCHAR(32) NOT NULL, -- Для отслеживания изменений контекста
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (hk_employee, load_date)
);

-- Сателлит данных клиента
CREATE TABLE sat_customer (
    hk_customer VARCHAR(32) NOT NULL REFERENCES hub_customer(hk_customer),
    load_date TIMESTAMP NOT NULL,
    company_name VARCHAR(100),
    contact_name VARCHAR(100),
    phone VARCHAR(20),
    hash_diff VARCHAR(32) NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (hk_customer, load_date)
);

-- Сателлит данных товара
CREATE TABLE sat_product (
    hk_product VARCHAR(32) NOT NULL REFERENCES hub_product(hk_product),
    load_date TIMESTAMP NOT NULL,
    product_name VARCHAR(150),
    current_price NUMERIC(12, 2),
    hash_diff VARCHAR(32) NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (hk_product, load_date)
);

-- Сателлит статуса заказа
CREATE TABLE sat_order (
    hk_order VARCHAR(32) NOT NULL REFERENCES hub_order(hk_order),
    load_date TIMESTAMP NOT NULL,
    order_date TIMESTAMP,
    status VARCHAR(30),
    hash_diff VARCHAR(32) NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (hk_order, load_date)
);

-- Сателлит для хранения метрик транзакции конкретной позиции заказа (привязан к Link)
CREATE TABLE sat_order_item_context (
    hk_order_item VARCHAR(32) NOT NULL REFERENCES lnk_order_item(hk_order_item),
    load_date TIMESTAMP NOT NULL,
    quantity INT,
    price_per_item NUMERIC(12, 2),
    hash_diff VARCHAR(32) NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (hk_order_item, load_date)
);

