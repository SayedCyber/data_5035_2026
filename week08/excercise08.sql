/******************
  Sayed_Amini
  Data Engineering - week08
  Manufacturing cost Analysis - Serving Layer 
  
  Scenario: Finance team needs a serving layer to analyze production costs
  including Materials, Labor, overhead, and QC Testing.
********************/

--Setting up the role, database, and schema 

USE ROLE FOX_DATA5035_ROLE;
USE DATABASE DATA5035;
USE SCHEMA FOX;


-- 1: The Bus Matrix maps each business process to its related dimensions.
--    X means that dimension applies to that process.
--    all processes share all four dimensions because every cost event
--    is tied to a date, a facility, a product, and a batch.

/**
| Metric                | Description                            | Date | Facility | Product | Batch |
|-----------------------|------------------------------------  --|------|----------|---------|-------|
| Material Cost         | cost of raw ingredient per batch       |  X   |    X     |    X    |   X   |
| Labor Cost            | Operator hours and wages per batch     |  X   |    X     |    X    |   X   |
| Overhead Cost         | equipment, utilitis, cleaningroom fees |  X   |    X     |    X    |   X   |
| QC Test Cost          | Testing and failure investigation      |  X   |    X     |    X    |   X   |
| Cost Difference       | Actual cost minus standard cost        |  X   |    X     |    X    |   X   |
**/

--  2: Dimensional Star Schema
-- Each row in FACT_PRODUCTION_COSTS represents the full cost breakdown, (Materials, Labor, Overhead, QC) for one manufacturing batch.


-- 1. DIM_DATE: Answers "when did production happen"
-- DATE_KEY is a surrogate key (e.g. 20240401 for April 1st)
-- Year, month, and quarter columns allow filtering like "all costs in Q2."
CREATE OR REPLACE TABLE DIM_DATE (
    DATE_KEY INT PRIMARY KEY, -- Surrogate Key (e.g., 20240401)
    FULL_DATE DATE,
    CALENDAR_YEAR INT,
    CALENDAR_MONTH STRING,
    FISCAL_QUARTER INT
);

-- 2. DIM_FACILITY: Answers "where did production happen"
-- Stores factory details like cleanroom class and overhead rates.
-- Different facilities have different costs (e.g. Columbus ISO 5 = $320/hr).
CREATE OR REPLACE TABLE DIM_FACILITY (
    FACILITY_ID INT PRIMARY KEY,
    FACILITY_NAME STRING,    -- St. Louis, Columbus, Raleigh South
    CLEANROOM_CLASS STRING,  -- ISO 5, ISO 7, etc.
    HOURLY_OVERHEAD_RATE DECIMAL(10,2), -- e.g., $320 for Columbus
    LABOR_PREMIUM_RATE DECIMAL(5,2)     -- e.g., 1.10 for sterile 10% premiium
);

-- 3. DIM_PRODUCT: answers "what medicine was produced"
-- Stores product info like dosage form, target cost, and storage needs
CREATE OR REPLACE TABLE DIM_PRODUCT (
    PRODUCT_ID INT PRIMARY KEY,
    PRODUCT_NAME STRING, -- Cardiolex, Opticlear, DermaSmooth
    DOSAGE_FORM STRING,  -- Tablet, Sterile Drops, ointment
    TARGET_UNIT_COST DECIMAL(12,2),
    STORAGE_REQUIREMENT STRING -- cold storage room temperature
);

-- 4. DIM_BATCH: Answers "which production run"
-- Each batch has an ID (e.g. B-10454), production line, size, and time range.
CREATE OR REPLACE TABLE DIM_BATCH (
    BATCH_ID STRING PRIMARY KEY, -- e.g., B-10454
    PRODUCTION_LINE STRING,
    BATCH_SIZE_UNITS INT,
    START_TIME TIMESTAMP_NTZ,
    END_TIME TIMESTAMP_NTZ
);

-- 5. FACT_PRODUCTION_COSTS: ThIs is about central fact table.
-- Hold the actual cost numbers for each batch (materials, labor, overhead, qualitry control).
-- Also stores the standard target cost so we can calculate difference.
-- foreign keys connect to the four dimension tables above (star schema).
CREATE OR REPLACE TABLE FACT_PRODUCTION_COSTS (
    FACT_ID INT AUTOINCREMENT PRIMARY KEY,
    DATE_KEY INT REFERENCES DIM_DATE(DATE_KEY),
    FACILITY_ID INT REFERENCES DIM_FACILITY(FACILITY_ID),
    PRODUCT_ID INT REFERENCES DIM_PRODUCT(PRODUCT_ID),
    BATCH_ID STRING REFERENCES DIM_BATCH(BATCH_ID),
    
    -- quantitative measures (measures for CFO)
    ACTUAL_MATERIAL_COST DECIMAL(15,2),
    ACTUAL_LABOR_COST DECIMAL(15,2),
    ACTUAL_OVERHEAD_COST DECIMAL(15,2),
    ACTUAL_QC_COST DECIMAL(15,2),
    
    TOTAL_ACTUAL_COST DECIMAL(15,2),
    STANDARD_TARGET_COST DECIMAL(15,2),
    COST_VARIANCE_AMOUNT DECIMAL(15,2), -- calculated as TotalActual - StandardTarget
    TOTAL_UNITS_PRODUCED INT
);

-- 3: Reverse ETL Alert Table

-- Reverse ETL Alert Table: sends data back out to notify to the finance team.
-- If a batch goes over 15%  which is its standard cost, alert row is created.
-- The JSON payload included the cost breakdown and root cause detials.

CREATE OR REPLACE TABLE COST_VARIANCE_ALERTS (
    ALERT_ID INT AUTOINCREMENT PRIMARY KEY,
    BATCH_ID STRING,
    VARIANCE_PERCENTAGE DECIMAL(5,2),
    ALERT_SEVERITY STRING, -- critical , warning
    PAYLOAD_JSON VARIANT,  -- Detailed JSON for downstream notifications systeT
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

/*
-- JASON EXAMPLE FOR BATCH B-10454 (The problematic sterile batch):
-- ThiS captures the 22.5% over budget mentioned in the scenario.

{
    "alert_header": {
        "batch_id": "B-10454",
        "product": "OptiClear",
        "location": "Columbus BioCenter"
    },
    "cost_breakdown": {
        "actual_cost": 42875.00,
        "standard_cost": 35000.00,
        "variance_pct": 22.5
    },
    "root_cause_analysis": {
        "labor_issue": "14 unplanned overtime hours for rework",
        "qc_issue": "2 failure investigations (fill volume and assay) added $4,000",
        "overhead_issue": "1.5 hours excess occupancy + 9-day QA cold-storage hold"
    },
    "action_required": "Finance Manager review required for Columbus labor premiums."
}
*/