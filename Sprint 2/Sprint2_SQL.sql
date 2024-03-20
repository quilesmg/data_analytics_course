USE Transactions;

-- Nivell 1

-- Ex 1.
SELECT *
FROM transaction
LEFT JOIN company ON company.id = transaction.company_id
WHERE country = "Germany";


-- EX 2.
SELECT company_name
FROM company 
WHERE id IN (
    SELECT company_id 
    FROM transaction
    WHERE amount > (
        SELECT AVG(amount) 
        FROM transaction
    )
);


-- EX 3. 
SELECT target_company, transaction.*
FROM transaction
JOIN (
    SELECT id, company_name as target_company
    FROM company
    WHERE company_name LIKE "C%"
) as company2
ON company2.id = transaction.company_id;


-- EX 4.
SELECT COUNT(id) as customers
FROM company
WHERE id NOT IN (
	SELECT company_id
    FROM transaction
);


-- Nivell 2

-- EX 1.
SELECT company_country.*, transaction.id
FROM transaction 
JOIN (
    SELECT id, company_name, country
    FROM company
    WHERE country IN (
		SELECT country
		FROM company
		WHERE company_name = "non institute"
	) 
) as company_country
ON company_country.id = transaction.company_id;



-- EX 2. 
SELECT company_name, sum
FROM company
JOIN (
	SELECT SUM(amount) as sum, company_id
	FROM transaction
	GROUP BY company_id
) as Sum_table
ON sum_table.company_id = company.id
ORDER BY sum DESC
LIMIT 1;


-- Nivell 3

-- EX 1. 
SELECT country, COUNT(transaction.id) AS counting
FROM transaction
JOIN company
ON transaction.company_id = company.id
GROUP BY country
HAVING counting > (
	SELECT AVG(transactions_count) AS transactions_avg
	FROM (
		SELECT country, COUNT(transaction.id) AS transactions_count
		FROM transaction
		JOIN company
		ON transaction.company_id = company.id
		GROUP BY country
	) AS avg_table
)
ORDER BY counting DESC;



-- EX 2.
SELECT company_name, transactions_count
FROM company
JOIN (
	SELECT company_id,
		CASE
			WHEN COUNT(transaction.id) > 4 THEN 'More than 4 transacions'
			ELSE 'Less than 4 transactions'
    END AS transactions_count
	FROM transaction
    GROUP BY company_id
) as transactions_count
ON transactions_count.company_id = company.id;
