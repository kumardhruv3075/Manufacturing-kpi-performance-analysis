
-- ------------------------------------------------------------------------------------------------------------------------
# KPI Analysis and Creating Star Schema 
-- ------------------------------------------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------------------------------------------
# Step 1 : Create Database Manufaturing_kPI_Analysis and Use it. 

CREATE DATABASE Manufacturing_KPI_Analysis ;  
USE Manufacturing_KPI_Analysis;

-- ------------------------------------------------------------------------------------------------------------------------
# Step 2 : Create table manufactring_data and insert data in it through table data import Wizard.

CREATE TABLE manufacturing_data (
    Date DATE,
    Machine_ID VARCHAR(10),
    Shift VARCHAR(5),
    Plant_Location VARCHAR(20),
    Downtime_Reason VARCHAR(50),

    Planned_Production_Time FLOAT,
    Downtime FLOAT,
    Operating_Time FLOAT,
    Ideal_Cycle_Time FLOAT,

    Total_Production FLOAT,
    Defective_Production FLOAT,
    Good_Production FLOAT,

    Availability FLOAT,
    Performance FLOAT,
    Quality FLOAT,
    OEE FLOAT
);


SELECT COUNT(*) FROM Manufacturing_data; # Validate inserted data 

SELECT * FROM manufacturing_data LIMIT 5;

-- ------------------------------------------------------------------------------------------------------------------------
# Step 3 :  Data Insights

# 1) KPI insights 
SELECT 
    AVG(Availability) AS avg_availability,
    AVG(Performance) AS avg_performance,
    AVG(Quality) AS avg_quality,
    AVG(OEE) AS avg_oee
FROM manufacturing_data;


#  2) Machine Wise KPI Analysis
SELECT 
    Machine_ID,
    AVG(Availability) AS availability,
    AVG(Performance) AS performance,
    AVG(Quality) AS quality,
    AVG(OEE) AS oee
FROM manufacturing_data
GROUP BY Machine_ID
ORDER BY oee DESC;


# 3) Root Cause Analysis
SELECT 
    Machine_ID,
    AVG(Availability) AS availability,
    AVG(Performance) As performance,
    AVG(Quality) As quality 
FROM manufacturing_data
GROUP BY Machine_ID;

# 4) Downtime reason analysis
SELECT 
    Downtime_Reason,
    AVG(Downtime) AS avg_downtime
FROM manufacturing_data
GROUP BY Downtime_Reason
ORDER BY avg_downtime DESC;

# 5) Shift Wise Performace Analysis
SELECT 
    Shift,
    AVG(OEE) AS avg_oee
FROM manufacturing_data
GROUP BY Shift
ORDER BY avg_oee DESC;

-- ------------------------------------------------------------------------------------------------------------------------
# Step 4 : Creating Star Schema

# 1) Create Dimension Table

# a) Create dim_machine tabel

CREATE TABLE dim_machine (
    Machine_ID VARCHAR(10) PRIMARY KEY,
    Machine_Type VARCHAR(50)
);

INSERT INTO dim_machine VALUES
('M1','High Downtime Machine'),
('M2','High Defect Machine'),
('M3','Low Performance Machine'),
('M4','Best Machine');

# B) Create dim_shift table
 
CREATE TABLE dim_shift (
    Shift VARCHAR(5) PRIMARY KEY,
    Shift_Name VARCHAR(50)
);

INSERT INTO dim_shift VALUES
('A','Morning'),
('B','Afternoon'),
('C','Night');

# C) Create dim_downtime table 

CREATE TABLE dim_downtime (
    Downtime_Reason VARCHAR(50) PRIMARY KEY,
    Category VARCHAR(50)
);

INSERT INTO dim_downtime VALUES
('Breakdown','Unplanned'),
('Maintenance','Planned'),
('Setup','Planned'),
('Power Failure','Unplanned');

# D) Create dim_location table
 
CREATE TABLE dim_location (
    Plant_Location VARCHAR(50) PRIMARY KEY,
    Region VARCHAR(50)
);
INSERT INTO dim_location VALUES
('Mumbai','West'),
('Pune','West'),
('Chennai','South');

# E) Create dim_date table 

CREATE TABLE dim_date (
    Date DATE PRIMARY KEY,
    Year INT,
    Month INT,
    Day INT,
    Quarter INT
);

INSERT INTO dim_date
SELECT DISTINCT 
    Date,
    YEAR(Date),
    MONTH(Date),
    DAY(Date),
    QUARTER(Date)
FROM manufacturing_data;

# 2) Create the fact_production table

CREATE TABLE fact_production AS
SELECT 
    Date,
    Machine_ID,
    Shift,
    Plant_Location,
    Downtime_Reason,

    Planned_Production_Time,
    Downtime,
    Operating_Time,
    Total_Production,
    Defective_Production,
    Good_Production,

    Availability,
    Performance,
    Quality,
    OEE
FROM manufacturing_data;
-- ------------------------------------------------------------------------------------------------------------------------
# Step 5 :  Add Forgien key relationships 

ALTER TABLE fact_production
ADD CONSTRAINT fk_machine
FOREIGN KEY (Machine_ID)
REFERENCES dim_machine(Machine_ID);

ALTER TABLE fact_production
ADD CONSTRAINT fk_downtime
FOREIGN KEY (Downtime_Reason)
REFERENCES dim_downtime(Downtime_Reason);

ALTER TABLE fact_production
ADD CONSTRAINT fk_location
FOREIGN KEY (Plant_Location)
REFERENCES dim_location(Plant_Location);

ALTER TABLE fact_production
ADD CONSTRAINT fk_date
FOREIGN KEY (Date)
REFERENCES dim_date(Date);


# Check the relationship through join the tables 

SELECT 
    m.Machine_Type,
    AVG(f.OEE) AS avg_oee
FROM fact_production f
JOIN dim_machine m 
    ON f.Machine_ID = m.Machine_ID
GROUP BY m.Machine_Type
ORDER BY avg_oee DESC;
