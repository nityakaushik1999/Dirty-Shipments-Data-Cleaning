# Dirty Shipments Data Cleaning & EDA using MySQL
Project Overview

This project focuses on cleaning and validating a logistics shipment dataset using MySQL. The dataset contains common real-world data quality issues such as missing values, duplicate records, inconsistent text formats, invalid dates, negative weights, and freight cost outliers.

The objective of this project is to transform raw shipment data into a clean and analysis-ready dataset by applying SQL-based data cleaning and validation techniques.

Dataset Columns
Shipment ID
Origin Warehouse
Destination City
Destination State
Carrier
Ship Date
Delivery Date
Weight (kg)
Freight Cost
Damage Reported
Data Cleaning Steps Performed
1. Text Standardization
Removed leading and trailing spaces using TRIM()
Standardized warehouse, city, and state names
Fixed inconsistent text casing
2. Missing Value Handling
Replaced invalid 'NULL' string values
Handled missing destination cities
Identified undelivered shipments with missing delivery dates
3. Duplicate Detection
Used ROW_NUMBER() window function
Identified duplicate shipment records based on business attributes
4. Data Validation
Corrected negative weight values using ABS()
Converted zero weights into NULL values
Validated shipment and delivery dates
5. Transit Time Analysis
Calculated transit days using DATEDIFF()
Flagged invalid and same-day deliveries
6. Outlier Detection
Applied Z-Score methodology on freight costs
Flagged abnormal shipment costs for further investigation
SQL Concepts Used
CASE WHEN
COALESCE
NULL Handling
String Functions
Date Functions
Window Functions
Common Table Expressions (CTEs)
Data Validation Rules
Z-Score Based Outlier Detection
# Key Outcomes
1. Text standardization and cleaning
2. Missing value handling
3. Duplicate detection using ROW_NUMBER()
4. Weight and date validation
5. Transit time calculation
6. Outlier detection using Z-Score
Tools Used
MySQL 8
SQL
GitHub
