
--Sayed Amini  , Exercise 09 - Joins in Real Wordl Data Scenario

-- in this file i practiced diffrent types of SQL joins for 2 senarios.
-- senario A is about retail (customers, orders, returns) and senario B is about healthcare (patients, visits, providers).
-- for each senario, first created temporary tables with sample data,
-- then answered 5 questions using the appropriate join type.
-- Reminder: the other 2 senarios (C and D) are done with Pandas in the notebook file "exercise09.ipynb"

-- the join types i used:
--    INNER JOIN: when i only need rows that match in both tables
--    LEFT JOIN:  when i need all rows from one table even if there is no match
--    Anti-join:  LEFT JOIN + WHERE IS NULL, to find rows with no match
--    also used CASE and subqueries in some questions


USE DATABASE "USER$FOX";
USE SCHEMA PUBLIC;
USE WAREHOUSE SNOWFLAKE_LEARNING_WH;


-- SCENARIO A: Retail Orders & Customers

--all these  seting up the tables for this senario based on assignment 09

CREATE OR REPLACE TEMPORARY TABLE customers (
    customer_id INT,
    name        STRING,
    state       STRING
);

INSERT INTO customers VALUES
    (1, 'Alice', 'MO'),
    (2, 'Bob',   'IL'),
    (3, 'Carol', 'TX');

CREATE OR REPLACE TEMPORARY TABLE orders (
    order_id    INT,
    customer_id INT,
    order_date  DATE,
    amount      DECIMAL(10,2)
);

INSERT INTO orders VALUES
    (101, 1, '2024-01-01', 100),
    (102, 1, '2024-01-05', 50),
    (103, 2, '2024-01-03', 75);

CREATE OR REPLACE TEMPORARY TABLE returns (
    return_id   INT,
    order_id    INT,
    return_date DATE
);

INSERT INTO returns VALUES
    (9001, 102, '2024-01-10');



-- Q1: Show all purchases with the customer who made them
-- join used: INNER JOIN
-- i used inner join here becuase the question says "only customers with orders" and inner join gives me only the rows that match in both tables.
-- so Carol does not show up becuase she has no orders.
-- i assumed that every customer_id in orders table exsits in customers table.

SELECT c.name AS customer_name,
       o.order_id,
       o.amount
FROM   customers c
       INNER JOIN orders o ON c.customer_id = o.customer_id;


-- --------------------------------------------------------
-- A-Q2: Show all customers and any orders they may have placed
-- --------------------------------------------------------
-- join used: LEFT JOIN
-- i used left join becuase the question says "include customers with no orders".
-- i put customers on the left side becuase i want to keep ALL customers, left join keeps everthing from the left table even if there is no match so left join is eaiser to read when you want all rows from the first table.
-- Carol has no orders so her order_id shows as NULL.

SELECT c.name AS customer_name,
       o.order_id
FROM   customers c
       LEFT JOIN orders o ON c.customer_id = o.customer_id;


-- Q3: Identify whether each order was returned

-- join used: LEFT JOIN + CASE
-- i need all orders to show up, so i put orders on the left side.
-- left join keeps all orders even if they were not returend.
-- then i use CASE WHEN to check: if there is a return_id (not null) then TRUE,
-- otherwsie FALSE.
-- i assumed each order can only be returend just one time.

SELECT o.order_id,
       CASE WHEN r.return_id IS NOT NULL THEN TRUE ELSE FALSE END AS is_returned
FROM   orders o
       LEFT JOIN returns r ON o.order_id = r.order_id;


-- Q4: Show only orders that were returned and who made them

-- join used: INNER JOIN (two times)
-- i used inner join twice becuase i only want orders that have a return.
-- first inner join between orders and returns gives me only returend orders.
-- second inner join with customers gives me the customer name.
-- if i used left join here, i would also get orders that were not returend,
-- but the quesiton says "only returned orders".
-- i assumed every order has a valid customer_id.

SELECT c.name AS customer_name,
       o.order_id,
       r.return_date
FROM   orders o
       INNER JOIN returns r   ON o.order_id    = r.order_id
       INNER JOIN customers c ON o.customer_id = c.customer_id;


-- Q5: Find customers who have never made a purchase

 -- join used: LEFT JOIN + WHERE IS NULL " anti-join"
-- i want to find customers that do not have any order
-- first i left join customers to orders so all customers show up
-- then i filter with WHERE o.order_id IS NULL,so this gives me only the customers where there was no matching order then it find rows with no match.
-- result: only Carol becuase she never ordered anything

SELECT c.name AS customer_name
FROM   customers c
       LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE  o.order_id IS NULL;



-- SCENARIO B: Healthcare Encounters


--so herer again seting up the tables for this senario based on assignment 09

CREATE OR REPLACE TEMPORARY TABLE patients (
    patient_id INT,
    name       STRING,
    birth_year INT
);

INSERT INTO patients VALUES
    (1, 'John', 1980),
    (2, 'Mary', 1975),
    (3, 'Sam',  1990);

CREATE OR REPLACE TEMPORARY TABLE visits (
    visit_id    INT,
    patient_id  INT,
    visit_date  DATE,
    provider_id INT
);

INSERT INTO visits VALUES
    (2001, 1, '2024-02-01', 10),
    (2002, 2, '2024-02-03', 11);

CREATE OR REPLACE TEMPORARY TABLE providers (
    provider_id   INT,
    provider_name STRING,
    specialty     STRING
);

INSERT INTO providers VALUES
    (10, 'Dr. Smith', 'Cardiology'),
    (11, 'Dr. Lee',   'Primary Care'),
    (12, 'Dr. Patel', 'Oncology');



-- Q1: Show each visit with patient and provider details

-- join used: INNER JOIN (two times)
-- i want to see visit info togather with patient name and doctor name.
-- i used inner join becuase the question says "only visits that occured".
-- i start from visits table and join to patients and providers.
-- so based on result, Sam does not show becuase he has no visit and Dr. Patel also does not show becuase nobody visited him. inner join removes those two.

SELECT p.name AS patient_name,
       pr.provider_name,
       v.visit_date
FROM   visits v
       INNER JOIN patients  p  ON v.patient_id  = p.patient_id
       INNER JOIN providers pr ON v.provider_id  = pr.provider_id;


-- B-Q2: Show all patients and any visits they may have had

-- join used: LEFT JOIN
-- i put patients on the left so they all stay in the result so Sam has no visit so his visit_id will be NULL.
-- i did not use right join becuase patients is my main table and i want read it left to right, patients first, then visits.

SELECT p.name AS patient_name,
       v.visit_id
FROM   patients p
       LEFT JOIN visits v ON p.patient_id = v.patient_id;



-- Q3: Show all providers and any visits they handled

-- join used: LEFT JOIN
-- same idea as Q2 but now i want all providers even if they had no visits, providers is on the left side so all doctors show up.
-- Dr Patel has no visits so his visit id is NULL.
-- again i used left join insted of right join becuase the table i want to keep everthing from (providers) is the first table i write in the FROM.

SELECT pr.provider_name,
       v.visit_id
FROM   providers pr
       LEFT JOIN visits v ON pr.provider_id = v.provider_id;



-- Q4: Find patients who have never had a visit

-- join used: LEFT JOIN + WHERE IS NULL "anti-join" 
-- i want patients with no visits.
-- left join keeps all patients, then WHERE v.visit_id IS NULL
-- filters to only the ones that had no match so based on result, only Sam comes back becuase John and Mary both have visited doctors

SELECT p.name AS patient_name
FROM   patients p
       LEFT JOIN visits v ON p.patient_id = v.patient_id
WHERE  v.visit_id IS NULL;



-- Q5: Show visits handled by cardiology providers

-- join used: INNER JOIN (two times) + WHERE filter
-- first i join all three tables with inner join to get complte visit details.
-- then i add a WHERE to keep only cardiology visits.
-- i could also put the filter in the ON clause but WHERE is cleaner to read so only John visiting with Dr. Smith will show up.

SELECT p.name AS patient_name,
       pr.provider_name,
       v.visit_date
FROM   visits v
       INNER JOIN patients  p  ON v.patient_id  = p.patient_id
       INNER JOIN providers pr ON v.provider_id  = pr.provider_id
WHERE  pr.specialty = 'Cardiology';
