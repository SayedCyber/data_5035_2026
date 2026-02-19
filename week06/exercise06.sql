/* Sayed Amini
Assignment: Week 06 - Unit Testing
Description: Testing my data quality rules from Assignment 02
*/

--  Use my personal folder
USE SCHEMA data5035.FOX;

-- UNIT TEST 1: Names
-- I am checking if names have a comma (Last, First format)

CREATE OR REPLACE TEMPORARY TABLE names (input_val varchar, expected int);

INSERT INTO names VALUES
('Adams, Bradon', 1),
('Bradon Adams', 0),
('Amini, Sayed', 1),
('Sayed Amini', 0);

SELECT 
    'comma_name' as check_coma,
    input_val,
    expected,
    CASE WHEN CONTAINS(input_val, ',') THEN 1 ELSE 0 END AS actual,
    actual = expected as match
FROM names;



-- UNIT TEST 2: Birth Dates
-- I am checking if the year is very old (before 1900)

CREATE OR REPLACE TEMPORARY TABLE DOB (input_val varchar, expected int);

INSERT INTO DOB VALUES
('0044-12-28', 1),
('1995-05-20', 0),
('0088-01-01', 1),
('2020-02-02', 0);

SELECT 
    'bad_year' as Year,
    input_val,
    expected,
    CASE WHEN TRY_TO_NUMBER(SUBSTR(input_val, 1, 4)) < 1900 THEN 1 ELSE 0 END AS actual,
    actual = expected as match
FROM DOB;


-- UNIT TEST 3: Category
-- I am checking for empty, NULL, or 'Unknown' categories

CREATE OR REPLACE TEMPORARY TABLE category (input_val varchar, expected int);

INSERT INTO category VALUES
('DataEnginnering', 0),
('Unknown', 1),
('n/a', 1),
(NULL, 1);

SELECT 
    'bad_category' as Category,
    input_val,
    expected,
    CASE WHEN input_val IS NULL OR LOWER(TRIM(input_val)) IN ('', 'n/a', 'unknown') THEN 1 ELSE 0 END AS actual,
    actual = expected as match
FROM category;



-- UNIT TEST 4: Zip Codes
-- I am checking if the Zip Code is too short (less than 5)

CREATE OR REPLACE TEMPORARY TABLE zipcode (input_val varchar, expected int);

INSERT INTO zipcode VALUES
('12345', 0),
('4918', 1),
('90210', 0),
('123', 1);

SELECT 
    'short_zipcode' as zipcodes,
    input_val,
    expected,
    CASE WHEN LENGTH(input_val) < 5 THEN 1 ELSE 0 END AS actual,
    actual = expected as match
FROM zipcode;



-- UNIT TEST 5: Phone Numbers
-- I am checking if the phone has an extension 'x'

CREATE OR REPLACE TEMPORARY TABLE phone_format (input_val varchar, expected int);

INSERT INTO phone_format VALUES
('123-456-7890', 0),
('123-456-7890x475', 1),
('555-000-1111', 0),
('999-888-7777x10', 1);

SELECT 
    'phone_extension' as Phone_extension,
    input_val,
    expected,
    CASE WHEN input_val LIKE '%x%' THEN 1 ELSE 0 END AS actual,
    actual = expected as match
FROM phone_format;