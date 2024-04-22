-- Nivell 1 --

-- EX 1.

CREATE DATABASE operations;

CREATE TABLE users_all (
	id INT NOT NULL,
    name VARCHAR(100),
    surname VARCHAR(100),
    phone VARCHAR(100),
	email VARCHAR(100),
	birth_date VARCHAR(100),
    country VARCHAR(100),
    city VARCHAR(100),
    postal_code VARCHAR(100),
    address VARCHAR(200),
    PRIMARY KEY (id)
);

CREATE TABLE credit_cards (
	id VARCHAR(15) NOT NULL,
    user_id INT,
    iban VARCHAR(45),
    pan VARCHAR(45),
	pin VARCHAR(45),
	cvv VARBINARY(4),
    track1 VARCHAR(100),
    track2 VARCHAR(100),
    expiring_date VARCHAR(45),
    PRIMARY KEY (id)
);

CREATE TABLE company (
	company_id VARCHAR(15) NOT NULL,
    company_name VARCHAR(45),
    phone VARCHAR(45),
    email VARCHAR(45),
	country VARCHAR(45),
    website VARCHAR(45),
    PRIMARY KEY (company_id)
);

CREATE TABLE transactions (
	id VARCHAR(45) NOT NULL,
    card_id VARCHAR(45),
    business_id VARCHAR(100),
    timestamp TIMESTAMP(6),
	amount DECIMAL(10,0),
	declined TINYINT,
    product_ids VARCHAR(100),
    user_id INT,
    lat FLOAT,
    longitude FLOAT,
    PRIMARY KEY (id),
	FOREIGN KEY (business_id) REFERENCES company(company_id), 
	FOREIGN KEY (credit_cards) REFERENCES credit_cards(id),
	FOREIGN KEY (users_all) REFERENCES users_all(id)
);

SET GLOBAL local_infile = 'ON';

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_usa.csv"
INTO TABLE users_all
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES; 

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_uk.csv"
INTO TABLE users_all
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_ca.csv"
INTO TABLE users_all
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv"
INTO TABLE products
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES; 

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/credit_cards.csv"
INTO TABLE credit_cards
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES; 

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/company.csv"
INTO TABLE company
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES; 

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transactions.csv"
INTO TABLE transactions
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES; 


SELECT users_all.id, name, surname, count(transactions.id) as totaltransactions
FROM users_all
JOIN transactions
ON transactions.user_id = users_all.id
GROUP BY users_all.id
HAVING totaltransactions > 30;



-- EX 2. 
SELECT ROUND(AVG(transactions.amount), 2) AS total_transactions, iban 
FROM credit_cards
JOIN transactions ON transactions.card_id = credit_cards.id
JOIN company ON company.company_id = transactions.business_id
WHERE company_name = "Donec Ltd"
GROUP BY iban;


-- Nivell 2 --
-- Ex 1. 

CREATE TABLE `credit_card_status` AS
SELECT card_id,
    CASE 
        WHEN SUM(declined) >= 3 THEN 'Inativo'
        ELSE 'Ativo'
    END AS status
FROM (
    SELECT card_id, declined,
        ROW_NUMBER() OVER (PARTITION BY card_id ORDER BY timestamp DESC) AS rn
    FROM transactions
) AS last_transactions
WHERE rn <= 3
GROUP BY card_id;

SELECT COUNT(Card_id) AS active_cards
FROM credit_card_status
WHERE status = "Ativo";
-- 275 tarjetas están activas --

-- Nivell 3 --
-- EX 1. 

CREATE TABLE products (
	id INT,
    product_name VARCHAR(100),
    price VARCHAR(100),
    colour VARCHAR(100),
    weight VARCHAR(100),
    warehouse_id VARCHAR(100),
    PRIMARY KEY (id)
);

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv"
INTO TABLE products
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES; 


CREATE TABLE products_transactions (
    transaction_id VARCHAR(100) NOT NULL,
    product_id INT NOT NULL,
    PRIMARY KEY (product_id, transaction_id),
	FOREIGN KEY (transaction_id) REFERENCES transactions(id), 
	FOREIGN KEY (product_id) REFERENCES products(id)
);

        
INSERT INTO products_transactions
SELECT transactions.id, SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', n.digit+1), ',', -1) AS product_id
FROM transactions
JOIN
(SELECT 0 as digit UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) n
ON LENGTH(REPLACE(product_ids, ',' , '')) <= LENGTH(product_ids)-n.digit;


SELECT COUNT(transaction_id) as total_selling, product_name
FROM products_transactions
LEFT JOIN products ON products_transactions.product_id = products.id
GROUP BY product_id, product_name
ORDER BY total_selling DESC;
