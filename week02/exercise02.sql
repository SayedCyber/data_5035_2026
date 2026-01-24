/* Sayed Amini, Assignment 02
   Data Profiling on DONATIONS table with detailed comments
*/

SELECT 
    *, -- Including all original columns as requested by the professor

    /* 1) Reversed Name Format
       We check if the NAME contains a comma. 
       Normally names are 'First Last'. If a comma exists, 
       it is likely 'Last, First' format. */
    CASE 
        WHEN NAME LIKE '%,%' THEN 1
        ELSE 0
    END AS dq_reversed_name,

    /* 2) Invalid year in Date of Birth 
       We use SUBSTR to get the first 4 characters (the year).
       If the year is less than 1900 (like 0044), it is marked as bad data. */
    CASE
        WHEN TRY_TO_NUMBER(SUBSTR(DATE_OF_BIRTH, 1, 4)) < 1900 THEN 1
        ELSE 0
    END AS dq_invalid_dob_year,

    /* 3) Missing or Generic Category
       Checks for NULL, empty, or unhelpful values like 'N/A' or 'Unknown'.
       This identifies rows that lack useful classification. */
    CASE
        WHEN CATEGORY IS NULL 
             OR LOWER(TRIM(CATEGORY)) IN ('', 'n/a', 'unknown') 
        THEN 1
        ELSE 0
    END AS dq_unuseful_category,

    /* 4) Short ZIP Codes 
       US ZIP codes must be at least 5 digits. 
       We convert ZIP to string to check its length correctly. */
    CASE
        WHEN LENGTH(ZIP::STRING) < 5 THEN 1
        ELSE 0
    END AS dq_invalid_zip,

    /* 5) Phone Numbers with Extensions
       Some numbers include 'x' for extensions. This makes the phone 
       format inconsistent for standard use. */
    CASE
        WHEN PHONE ILIKE '%x%' THEN 1
        ELSE 0
    END AS dq_phone_extension

FROM DATA5035.SPRING26.DONATIONS;

/**
REFLECTION ON DATA QUALITY:

After analyzing the data in the DONATIONS table, I found several quality challenges:

First, many names are reversed (using commas), which makes it hard to address donors 
correctly. Second, the 'Date of Birth' field has a major issue where the years are 
truncated to two digits (starting with 00), making the age data unreliable. 

I also noticed that the 'Category' field is often empty or filled with 'Unknown', 
which is not useful for analysis. Some ZIP codes are too short (less than 5 digits), 
and phone numbers are not standardized because some include extensions.

In conclusion, while the donation amounts seem fine, the identifying information 
columns need a lot of cleaning and standardization before they can be used for 
marketing or reporting.
**/