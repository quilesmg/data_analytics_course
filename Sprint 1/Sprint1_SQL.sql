USE transactions;

-- Nivell 1 --

-- Ex 2.
SELECT company_name, email, country
FROM transactions.company
ORDER BY company_name;


-- Ex 3. 
SELECT DISTINCT country FROM transactions.company
LEFT JOIN transactions.transaction ON company.id = transaction.company_id
ORDER BY country;


-- Ex 4. 
SELECT COUNT(DISTINCT country) FROM transactions.company
INNER JOIN transactions.transaction ON company.id = transaction.company_id;


-- EX 5. 
SELECT country, company_name
FROM company
WHERE company.id = "b-2354";


-- EX 6. 
SELECT company.company_name, AVG(transaction.amount) as avg_transaction
FROM transaction
INNER JOIN company ON transaction.company_id = company.id
WHERE declined = FALSE
GROUP BY company_name, company_id
ORDER BY avg_transaction DESC
LIMIT 1;

-- Nivell 2 --

-- Ex 1. 
SELECT count(id) as identifiers
FROM company
GROUP BY id
HAVING identifiers >1;


-- Ex 2. 
SELECT timestamp, MAX(amount) as max_sell
FROM transaction
WHERE declined = FALSE
GROUP BY timestamp
ORDER BY max_sell DESC
LIMIT 5;


-- Ex 3. 
SELECT timestamp, MIN(amount) as min_sell
FROM transaction
WHERE declined = FALSE
GROUP BY timestamp
ORDER BY min_sell
LIMIT 5;


-- Ex 4.
SELECT country, AVG(amount) as avg_sell
FROM company
LEFT JOIN transaction on company.id = transaction.company_id
WHERE declined = false
GROUP BY country
ORDER BY avg_sell DESC;


-- Nivell 3

-- Ex 1. 
SELECT company_name, phone, country, SUM(amount) as total_sell
FROM company
LEFT JOIN transaction on company.id = transaction.company_id
WHERE declined = false 
GROUP BY company_name, phone, country
HAVING total_sell BETWEEN 100 AND 200
ORDER BY total_sell DESC;


-- Ex 2. 
SELECT company_name
FROM company
INNER JOIN transaction on company.id = transaction.company_id
WHERE declined = false AND 
CAST(timestamp AS DATE) IN ("2022-03-16", "2022-02-28", "2022-02-13")
GROUP BY company_name;