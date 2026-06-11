-- Database Setup
create database dirty_shipments;
use dirty_shipments;
select * 
from shipments;
desc shipments;

-- Check Total Records
SELECT COUNT(*) AS total_records
FROM shipments;

-- Check Missing Values
SELECT
SUM(destination_city IS NULL) AS missing_city,
SUM(delivery_date IS NULL) AS missing_delivery_date,
SUM(damage_reported IS NULL) AS missing_damage_report
FROM shipments;

-- Remove Leading/Trailing whitespace
select shipment_id,
trim(origin_warehouse) as origin_warehouse,
trim(destination_city) as destination_city,
trim(destination_state) as destination_state,
trim(carrier) as carrier
from shipments;

-- Standardize Text Casing
select shipment_id,
CONCAT(
    'Warehouse ',
    UPPER(RIGHT(TRIM(origin_warehouse),1))
) AS origin_warehouse,
CONCAT(
    UPPER(LEFT(TRIM(destination_city),1)),
    LOWER(SUBSTRING(TRIM(destination_city),2))
) AS destination_city,
upper((destination_state)) as destination_state,
trim(carrier) as carrier
from shipments;

-- Missing Value Handling (Replace String 'NULL' And Handle True NULLS)
SELECT
shipment_id,
CASE
    WHEN damage_reported = 'NULL' THEN NULL
    ELSE CONCAT(
        UPPER(LEFT(TRIM(damage_reported),1)),
        LOWER(SUBSTRING(TRIM(damage_reported),2))
    )
END AS damage_reported,
CASE
    WHEN TRIM(LOWER(destination_city)) IN ('null','')
    THEN 'Unknown'
    ELSE CONCAT(
        UPPER(LEFT(TRIM(destination_city),1)),
        LOWER(SUBSTRING(TRIM(destination_city),2))
    )
END AS destination_city,
COALESCE(
    DATE_FORMAT(delivery_date,'%d-%m-%Y'),
    'Not Yet Delivered'
) AS delivery_date
FROM shipments;

-- Duplicate Detection (Remove Exact Duplicate Rows)
WITH ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY origin_warehouse,
                            destination_city,
                            carrier,
                            ship_date,
                            CAST(weight_kg AS CHAR),
                            CAST(freight_cost AS CHAR)
               ORDER BY shipment_id
           ) AS row_num
    FROM shipments
)
SELECT *
FROM ranked
WHERE row_num = 1;

-- Try To Fix Negative And Suspicious Values
select shipment_id,
case 
when weight_kg<0 then abs(weight_kg)
when weight_kg=0 then NULL
else weight_kg
end as weight_kg_cleaned
from shipments;

-- Date Validation
SELECT
    shipment_id,
    ship_date,
    delivery_date,
    DATEDIFF(
        STR_TO_DATE(delivery_date,'%Y-%m-%d'),
        STR_TO_DATE(ship_date,'%Y-%m-%d')
    ) AS transit_days,
    case 
when STR_TO_DATE(delivery_date,'%Y-%m-%d') < STR_TO_DATE(ship_date,'%Y-%m-%d') then 'Invalid'
when STR_TO_DATE(delivery_date,'%Y-%m-%d') = STR_TO_DATE(ship_date,'%Y-%m-%d') then 'Same day delivery'
else 'Valid'
end as data_quality_flag
FROM shipments;

-- detect and cap outliers using percentiles
WITH stats AS (
    SELECT
        AVG(freight_cost) AS avg_cost,
        STDDEV(freight_cost) AS std_cost
    FROM shipments
)
SELECT
    s.shipment_id,
    s.freight_cost,
    ROUND(
        (s.freight_cost - st.avg_cost) / st.std_cost,
        2
    ) AS z_score,
    CASE
        WHEN ABS((s.freight_cost - st.avg_cost) / st.std_cost) > 3
        THEN 'Outlier'
        ELSE 'Normal'
    END AS outlier_flag
FROM shipments s
CROSS JOIN stats st;
