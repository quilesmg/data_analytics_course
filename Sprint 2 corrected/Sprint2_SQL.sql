USE Transactions;

-- Nivell 1

-- Ex 1.
SELECT *
FROM transaction
WHERE company_id IN (
    SELECT company_id
    FROM company
    WHERE country = "Germany"
);



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
SELECT *
FROM transaction
WHERE company_id IN (
	SELECT id
    FROM company
    WHERE company_name LIKE "C%"
);




-- EX 4.
SELECT COUNT(id) AS customers
FROM company
WHERE id NOT IN (
	SELECT company_id
    FROM transaction
);


-- Nivell 2

-- EX 1.
SELECT *
FROM transaction   
 WHERE company_id IN (
 SELECT id                
 FROM company
 WHERE country = (
  SELECT country       
  FROM company
  WHERE company_name = "Non Institute" ) 
);


-- EX 2. 
SELECT company_name, id  
FROM company
 WHERE id = (   
 SELECT company_id 
 FROM transaction
 WHERE amount = ( 
  SELECT max(amount)
  FROM transaction) 
);


-- Nivell 3

-- EX 1. 
SELECT (
	SELECT country FROM company 
    WHERE id = transaction.company_id) AS country, AVG(amount)
  FROM transaction
  GROUP BY country
HAVING AVG(amount) > (
  SELECT AVG(amount)
  FROM transaction
  );


-- EX 2.
SELECT company_name, (
    CASE
    WHEN ( SELECT count(id)
           FROM transaction
           WHERE transaction.company_id = company.id ) > 4 THEN "More than 4 transactions" 
       ELSE  "Less than 4 transactions" 
       END ) AS NumTransaccions 
    FROM company;
