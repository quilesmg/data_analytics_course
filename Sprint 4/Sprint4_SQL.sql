-- Nivell 1 --

-- EX 1.

SELECT id, name, surname, totaltransactions
FROM users_all
JOIN (
	SELECT user_id, COUNT(transactions.id) AS totaltransactions
	FROM transactions
	GROUP BY user_id
) AS transactions_count
ON transactions_count.user_id = users_all.id
WHERE totaltransactions > 30;


-- EX 2. 

SELECT iban, AVG(total_transactions) as avg_transactions
FROM (
	SELECT COUNT(transactions.ID) AS total_transactions, iban 
	FROM transactions
	JOIN company ON company.company_id = transactions.business_id
	JOIN credit_cards ON transactions.user_id = credit_cards.user_id
	WHERE company_name = "Donec Ltd"
    GROUP BY iban
) AS counting_transactions
GROUP BY iban;
-- la media de transaciones por iban és 2 --

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

SELECT COUNT(Card_id) as active_cards
FROM credit_card_status
WHERE status = "Ativo"
HAVING active_cards;
-- 275 tarjetas están activas --

-- Nivell 3 --
-- EX 1. 

CREATE TABLE transaction_products (
    transaction_id VARCHAR(100),
    product_id VARCHAR(100),
    PRIMARY KEY (transaction_id, product_id)
);

INSERT INTO transaction_products
SELECT transactions.id, SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', n.digit+1), ',', -1) AS product_id
FROM transactions
JOIN
(SELECT 0 as digit UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) n
ON LENGTH(REPLACE(product_ids, ',' , '')) <= LENGTH(product_ids)-n.digit;

SELECT COUNT(transaction_id) as total_selling, product_name
FROM transaction_products
INNER JOIN products ON transaction_products.product_id = products.id
GROUP BY product_id, product_name
ORDER BY total_selling DESC;


