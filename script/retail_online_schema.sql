CREATE SCHEMA retail_online;
USE retail_online;
CREATE TABLE currencies (
    currency_code VARCHAR(50) PRIMARY KEY,
    currency_name VARCHAR(50),
    exchange_rate DECIMAL(20, 2),
    last_update INT
);

CREATE TABLE countries (
    country VARCHAR(250) PRIMARY KEY,
    currency_code VARCHAR(50),
    FOREIGN KEY (currency_code) REFERENCES currencies(currency_code)
);

CREATE TABLE customers (
	customer_id VARCHAR(50) PRIMARY KEY, 
    country VARCHAR(20),
    FOREIGN KEY (country) REFERENCES countries(country)
);
CREATE TABLE items (
    item_id VARCHAR(50) PRIMARY KEY,
    price_in_GBP DECIMAL(15, 2),
    description TEXT
);
CREATE TABLE orders (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    invoice_number TEXT,
    item_id VARCHAR(50),
    quantity INT,
    invoice_date INT,
    customer_id VARCHAR(50),
    FOREIGN KEY (item_id) REFERENCES items(item_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
