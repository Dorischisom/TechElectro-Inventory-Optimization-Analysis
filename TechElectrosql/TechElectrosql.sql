-- Preliminaries: To create Database/schema

CREATE database Tech_electro_inc;

USE Tech_electro_inc;

-- Data Exploration
SELECT * FROM sales_data LIMIT 5;
SELECT * FROM external_factors LIMIT 5;
SELECT * FROM inventory_data LIMIT 5;
SELECT * FROM product_information LIMIT 5;

-- Understanding the structures of the datasets
SHOW COLUMNS FROM sales_data;
DESCRIBE external_factors;
DESC product_information;

-- DATA CLEANING
-- Change data type for all columns
-- external_factors table
-- salesdate DATE, GDP DECIMAL (15,2), inflationrate DECIMAL (5,2), Seasonalfactors DECIMAL (5,2)

ALTER TABLE external_factors
ADD COLUMN New_Sales_Date DATE;

SET SQL_SAFE_UPDATES = 0; -- turning off safe updates

UPDATE external_factors
SET New_Sales_Date = STR_TO_DATE(`Sales Date`, '%d/%m/%Y');

ALTER TABLE external_factors
DROP COLUMN `sales date`;

ALTER TABLE external_factors
CHANGE COLUMN New_Sales_Date Sales_Date DATE;

ALTER TABLE external_factors
MODIFY COLUMN GDP DECIMAL(15,2);

ALTER TABLE external_factors
MODIFY COLUMN `Inflation Rate` DECIMAL(5,2);

ALTER TABLE external_factors
MODIFY COLUMN `Seasonal Factor` DECIMAL(5,2);

-- Change data type for all columns
-- product_information
-- product Id INT NOT NULL, Product category TEXT, promotions ENUM ('yes', 'no')

ALTER TABLE product_information
ADD COLUMN New_promotions ENUM('yes', 'no');

UPDATE product_information
SET New_promotions = CASE
   WHEN Promotions = 'yes' THEN 'yes'
   WHEN Promotions = 'no' THEN 'no'
   ELSE NULL
 END;  
 
ALTER TABLE product_information
DROP COLUMN Promotions;

ALTER TABLE product_information
CHANGE COLUMN New_promotions Promotions ENUM('yes', 'no');

-- Sales data
-- product_id INT NOT NULL, Sales data DATE, Inventory quantity INT, product cost DECIMAL (10,2)

ALTER TABLE sales_data
ADD COLUMN New_Sales_Date DATE;

UPDATE sales_data
SET New_Sales_Date = STR_TO_DATE(`Sales Date`, '%d/%m/%Y');

ALTER TABLE sales_data
DROP COLUMN `sales date`;

ALTER TABLE sales_data
CHANGE COLUMN New_Sales_Date Sales_Date DATE;

ALTER TABLE sales_data
MODIFY COLUMN `Product cost` DECIMAL(10,2);

-- Identify null values in external factors table

SELECT
  SUM(CASE WHEN `sales_date` IS NULL THEN 1 ELSE 0 END) AS Missing_Sales_date,
  SUM(CASE WHEN `GDP` IS NULL THEN 1 ELSE 0 END) AS Missing_GDP,
  SUM(CASE WHEN `Inflation Rate` IS NULL THEN 1 ELSE 0 END) AS Missing_Inflation_Rate,
  SUM(CASE WHEN `Seasonal Factor` IS NULL THEN 1 ELSE 0 END) AS Missing_Seasonal_factor
FROM external_factors;

-- For Product information table
SELECT
  SUM(CASE WHEN `Product ID` IS NULL THEN 1 ELSE 0 END) AS Missing_Product_ID,
  SUM(CASE WHEN `Product Category` IS NULL THEN 1 ELSE 0 END) AS Missing_Product_Category,
  SUM(CASE WHEN `Promotions` IS NULL THEN 1 ELSE 0 END) AS Missing_Promotions
FROM product_information;

-- For sales data table
SELECT
  SUM(CASE WHEN `Product ID` IS NULL THEN 1 ELSE 0 END) AS Missing_Product_ID,
  SUM(CASE WHEN `Inventory Quantity` IS NULL THEN 1 ELSE 0 END) AS Missing_Inventory_Quantity,
  SUM(CASE WHEN `Product Cost` IS NULL THEN 1 ELSE 0 END) AS Missing_Product_Cost,
  SUM(CASE WHEN `Sales_Date` IS NULL THEN 1 ELSE 0 END) AS Missing_Sales_Date
FROM sales_data;  

-- Check for duplictate values using 'Group by' and 'Having' clauses and removing them if necessary
-- External_ factors table

SELECT Sales_date, COUNT(*) AS count
FROM external_factors
GROUP BY sales_date
HAVING count > 1;

SELECT COUNT(*)
FROM(SELECT Sales_date, COUNT(*) AS count
FROM external_factors
GROUP BY sales_date
HAVING count > 1) AS DUP;

-- 352 duplicates

-- For product_information table
SELECT `Product ID`, `Product Category`, COUNT(*) AS count
FROM product_information
GROUP BY `Product ID`, `Product Category`
HAVING count > 1;

SELECT COUNT(*)
FROM (SELECT `Product ID`, `Product Category`, COUNT(*) AS count
FROM product_information
GROUP BY `Product ID`, `Product Category`
HAVING count > 1) AS DUP

-- 29 duplicates

-- For sales_data table
SELECT `Product ID`, Sales_Date, COUNT(*) AS count
FROM Sales_data
GROUP BY `Product ID`, Sales_Date
HAVING count > 1;

-- No duplicates

-- Handling duplicates
-- external factors
DELETE e1 FROM external_factors e1
INNER JOIN (
 SELECT Sales_Date,
 ROW_NUMBER() OVER (PARTITION BY Sales_Date ORDER BY Sales_Date) AS rn
 FROM external_factors
 ) e2 ON e1.Sales_Date = e2.Sales_Date
WHERE e2.rn > 1;

-- Product Information
DELETE p1 FROM product_information p1
INNER JOIN (
 SELECT `Product ID`,
 ROW_NUMBER() OVER (PARTITION BY `Product ID` ORDER BY `Product ID`) AS rn
 FROM product_information
 ) p2 ON p1.`Product ID` = p2.`Product ID`
WHERE p2.rn > 1;

-- Data Integration
-- Join sales_data and product_information first
CREATE VIEW sales_product_data AS
SELECT  
    s.`Product ID`,
    s.`Inventory Quantity`,
    s.`Product Cost`,
    s.Sales_Date,
    p.`Product Category`,
    p.Promotions
FROM sales_data s
JOIN product_information p 
    ON s.`Product ID` = p.`Product ID`;
    
-- Join sales_product_data and external_ factors
CREATE VIEW Inventory_data AS
SELECT  
    sp.`Product ID`,
    sp.`Inventory Quantity`,
    sp.`Product Cost`,
    sp.Sales_Date,
    sp.`Product Category`,
    sp.Promotions,
    e.GDP,
    e.`Inflation Rate`,
    e.`Seasonal Factor`
FROM sales_product_data sp
LEFT JOIN external_factors e 
ON sp.`Sales_Date` = e.`Sales_Date`;

-- DESCRIPTIVE ANALYSIS
-- Basic statistics
-- Average sales (calculated as inventory quantity * Product cost)

SELECT `Product ID`,
AVG(`Inventory quantity` * `Product Cost`) AS avg_sales
FROM Inventory_data
GROUP BY `Product ID`
ORDER BY avg_sales DESC;

-- Median Stock Level (i.e "inventory Quantity")
SELECT `Product ID`, AVG(`Inventory Quantity`) AS median_stock
FROM (
 SELECT `Product ID`,
		`Inventory Quantity`,
ROW_NUMBER() OVER(PARTITION BY `Product ID` ORDER BY `Inventory Quantity`) AS row_num_asc,
ROW_NUMBER() OVER(PARTITION BY `Product ID` ORDER BY `Inventory Quantity` DESC) AS row_num_desc
FROM Inventory_data
) AS subquery
WHERE row_num_asc IN (row_num_desc, row_num_desc - 1, row_num_desc + 1)
GROUP BY `Product ID`;

-- Product performance metrics (total sales per product)
SELECT `Product ID`,
ROUND(SUM(`Inventory quantity` * `Product Cost`))AS total_sales
FROM Inventory_data
GROUP BY `Product ID`
ORDER BY total_sales DESC;

-- Identify high demand products based on average sales
WITH high_demand_products AS (
SELECT `Product ID`, AVG(`Inventory Quantity`) AS avg_sales
FROM inventory_data
GROUP BY `Product ID`
HAVING avg_sales > (
SELECT AVG(`Inventory Quantity`) * 0.95 FROM sales_data
  )
)
SELECT * 
FROM high_demand_products;

-- Calculate stockout frequency for high demands products
WITH high_demand_products AS (
    SELECT 
        `Product ID`, 
        AVG(`Inventory Quantity`) AS avg_sales
    FROM inventory_data
    GROUP BY `Product ID`
    HAVING avg_sales > (
        SELECT AVG(`Inventory Quantity`) * 0.95 
        FROM inventory_data
    )
)
SELECT s.`Product ID`,
       COUNT(*) AS stockout_frequency
FROM inventory_data s
WHERE s.`Product ID` IN (SELECT `Product ID` FROM high_demand_products)
  AND s.`Inventory Quantity` = 0
GROUP BY s.`Product ID`
LIMIT 0, 1000;


-- No product had stock out

-- Influence of external factors 
-- GDP
SELECT `Product ID`, 
AVG(CASE WHEN GDP > 0 THEN `Inventory Quantity` ELSE NULL END) AS avg_sales_positive_gdp,
AVG(CASE WHEN GDP <= 0 THEN `Inventory Quantity` ELSE NULL END) AS avg_sales_non_positive_gdp
FROM inventory_data
GROUP BY `Product ID`
HAVING avg_sales_positive_gdp IS NOT NULL;

-- Inflation Rate
SELECT `Product ID`, 
AVG(CASE WHEN `Inflation Rate` > 0 THEN `Inventory Quantity` ELSE NULL END) AS avg_sales_positive_Inflation_Rate,
AVG(CASE WHEN `Inflation Rate` <= 0 THEN `Inventory Quantity` ELSE NULL END) AS avg_sales_non_positive_Inflation_Rate
FROM inventory_data
GROUP BY `Product ID`
HAVING avg_sales_positive_Inflation_Rate IS NOT NULL;

-- Inventory Optimization
-- Determine the optimal reorder point for each product based on historical sales data and external factors
-- Reorder point = Lead Time Demand + Safety Stock
-- Lead Time Demand = Rolling Average sales * Lead Time
-- Reorder point =  Rolling Average sales * Lead Time +  Z * Lead Time^-2 * Standard Deviation Of Demand
-- Safety Stock = Z * Lead Time^-2 * Standard Deviation Of Demand
-- Z = 1.645 
-- A Constant Lead Time of 7days for all products
-- We aim for 95% service level.

WITH inventory_calculations AS (
SELECT `Product ID`,
AVG(rolling_avg_sales) AS avg_rolling_sales,
AVG(rolling_variance) AS avg_rolling_variance
FROM( 
SELECT `Product ID`, 
AVG(daily_sales) OVER(PARTITION BY `Product ID` ORDER BY Sales_Date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_avg_sales,
AVG(squared_diff) OVER(PARTITION BY `Product ID` ORDER BY Sales_Date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_variance
FROM (
SELECT `Product ID`,
sales_date , `Inventory Quantity` * `Product Cost` AS daily_sales,
( `Inventory Quantity` * `Product Cost` - AVG(`Inventory Quantity` * `Product Cost`) OVER(PARTITION BY `Product ID` ORDER BY Sales_Date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)) ,
( `Inventory Quantity` * `Product Cost` - AVG(`Inventory Quantity` * `Product Cost`) OVER(PARTITION BY `Product ID` ORDER BY Sales_Date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)) AS squared_diff
FROM inventory_data
) subquery
 ) subquery2
 GROUP BY `Product ID`
)
SELECT `Product ID`,
avg_rolling_sales * 7 AS Lead_time_Demand,
1.645 * (avg_rolling_variance * 7) AS safety_stock,
(avg_rolling_sales * 7) + (1.645 * (avg_rolling_variance * 7)) AS reorder_point
FROM inventory_calculations;


-- Create inventory optimization table
CREATE TABLE inventory_optimization(
  Product_ID INT,
  Reorder_point DOUBLE
);

-- Step 2 to create the stored procedure to recalculate reorder point
DELIMITER //
CREATE PROCEDURE Recalculate_reorder_point(Product_ID INT)
BEGIN
    DECLARE avgRollingSales DOUBLE;
    DECLARE avgRollingVariance DOUBLE;
	DECLARE LeadTimeDemand DOUBLE;
    DECLARE SafetyStock DOUBLE;
    DECLARE reorderpoint DOUBLE;
SELECT AVG(rolling_avg_sales), AVG(rolling_variance)
INTO avgrollingsales, avgrollingvariance
FROM ( 
SELECT `Product ID`, 
AVG(daily_sales) OVER(PARTITION BY `Product ID` ORDER BY Sales_Date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_avg_sales,
AVG(squared_diff) OVER(PARTITION BY `Product ID` ORDER BY Sales_Date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_variance
FROM (
SELECT `Product ID`,
sales_date , `Inventory Quantity` * `Product Cost` AS daily_sales,
( `Inventory Quantity` * `Product Cost` - AVG(`Inventory Quantity` * `Product Cost`) OVER(PARTITION BY `Product ID` ORDER BY Sales_Date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)) ,
( `Inventory Quantity` * `Product Cost` - AVG(`Inventory Quantity` * `Product Cost`) OVER(PARTITION BY `Product ID` ORDER BY Sales_Date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)) AS squared_diff
FROM inventory_data
) innerderived
 ) outerderived;
 SET LeadTimeDemand = avgrollingsales * 7;
 SET safetystock = 1.645 * SQRT(avgrollingvariance * 7);
 SET reorderpoint = LeadTimeDemand + safetystock;

INSERT INTO inventory_optimization (Product_ID, Reorder_point)
    VALUES (ProductID, reorderpoint)
ON DUPLICATE KEY UPDATE Reorder_point = reorderpoint;
END //
DELIMITER ;
    
-- Step 3 make inventory_data a permanent table
CREATE TABLE inventory_table AS SELECT * FROM inventory_data;
 
 -- Step 4 Create trigger
 DELIMITER //
 CREATE TRIGGER AfterInsertUnifiedTable
 AFTER INSERT ON inventory_table
 FOR EACH ROW 
 BEGIN
    CALL RecalculateReorderPoint(NEW.`Product ID`);
    END //
    DELIMITER ;
    
-- Overstock and Understock
WITH Rollingsales AS (
    SELECT 
        `Product ID`,
        Sales_date,
        AVG(`Inventory Quantity` * `Product Cost`) 
            OVER ( 
                PARTITION BY `Product ID` 
                ORDER BY Sales_date 
                ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
            ) AS rolling_avg_sales
    FROM inventory_table
),
Stockoutdays AS (
    SELECT 
        `Product ID`,
        COUNT(*) AS stockout_days
    FROM inventory_table
    WHERE `Inventory Quantity` = 0
    GROUP BY `Product ID`
)
-- Final join using both CTEs
SELECT 
    f.`Product ID`,
    AVG(f.`Inventory Quantity` * f.`Product Cost`) AS avg_inventory_value,
    AVG(rs.rolling_avg_sales) AS avg_rolling_sales,
    COALESCE(sd.stockout_days, 0) AS stockout_days
FROM inventory_table f
JOIN Rollingsales rs 
    ON f.`Product ID` = rs.`Product ID` 
   AND f.Sales_date = rs.Sales_date
LEFT JOIN Stockoutdays sd 
    ON f.`Product ID` = sd.`Product ID`
GROUP BY f.`Product ID`, sd.stockout_days;


-- MONITOR AND ADJUST
-- Monitor inventory levels
DELIMITER //
CREATE PROCEDURE MonitorInventoryLevels()
BEGIN
SELECT `Product ID`, AVG(`Inventory Quantity`) AS avginventory
FROM inventory_table 
GROUP BY `Product ID`
ORDER BY avginventory DESC;
END //
DELIMITER;

-- Monitor sales trends
DELIMITER //
CREATE PROCEDURE MonitorSalesTrends()
BEGIN
SELECT `Product ID`, Sales_date,
AVG(`Inventory Quantity` * `Product Cost`) OVER (PARTITION BY `Product ID` ORDER BY Sales_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS RollingAvgSales
FROM inventory_table 
ORDER BY `Product ID`, Sales_date ;
END//
DELIMITER ;

-- Monitor stock out frequencies
DELIMITER //
CREATE PROCEDURE MonitorStockouts()
BEGIN
SELECT `Product ID`, COUNT(*) AS StockOutDays
FROM inventory_table
WHERE `Inventory Quantity` = 0
GROUP BY `Product ID`
ORDER BY StockOutDays DESC;
END//
DELIMITER ;

