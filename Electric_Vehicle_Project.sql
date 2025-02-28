SHOW VARIABLES LIKE 'secure_file_priv';
CREATE DATABASE ev_sales_db;
USE ev_sales_db;

CREATE TABLE electric_vehicle_sales (
    Year INT,
    Month_Name VARCHAR(20),
    Date DATE,
    State VARCHAR(100),
    Vehicle_Class VARCHAR(50),
    Vehicle_Category VARCHAR(50),
    Vehicle_Type VARCHAR(50),
    EV_Sales_Quantity INT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Electric_Vehicle_Sales_Dataset.csv'
INTO TABLE electric_vehicle_sales
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@Year, Month_Name, @Date, State, Vehicle_Class, Vehicle_Category, Vehicle_Type, EV_Sales_Quantity)
SET Date = STR_TO_DATE(@Date, '%m-%d-%Y');

ALTER TABLE electric_vehicle_sales
modify  COLUMN year INT NOT NULL DEFAULT 0;

SET SQL_SAFE_UPDATES = 0;

UPDATE electric_vehicle_sales
SET Year = YEAR(Date)
WHERE Year IS NULL;

SET SQL_SAFE_UPDATES = 1;

SELECT * FROM electric_vehicle_sales;

------------------------------------------------------------------------------------------------------------------------------
                      -- State-wise Sales Trends:

--1.-- Which state has the highest and lowest EV sales?

(SELECT state, SUM(ev_sales_quantity) AS TOTAL_sales
FROM electric_vehicle_sales
GROUP BY state
ORDER BY TOTAL_sales DESC limit 1)
UNION
(SELECT state, SUM(ev_sales_quantity) AS TOTAL_sales
FROM electric_vehicle_sales
GROUP BY state
ORDER BY  TOTAL_sales limit 1);

---2.-- How do sales vary by state over time?

SELECT year, state, SUM(ev_sales_quantity) AS Total_Sales
FROM electric_vehicle_sales
GROUP BY year,state
ORDER BY year ASC, Total_Sales DESC ;
--------------------------------------------------------------------------------------------------------------------------------

						-- Vehicle Type & Category Insights:---
                        
--3.-- What are the most and least sold vehicle types? ----    

(SELECT vehicle_type, SUM(ev_sales_quantity) AS TOTAL_sales
FROM electric_vehicle_sales
GROUP BY vehicle_type
ORDER BY TOTAL_sales DESC limit 1)
UNION
(SELECT vehicle_type, SUM(ev_sales_quantity) AS TOTAL_sales
FROM electric_vehicle_sales
GROUP BY vehicle_type
ORDER BY  TOTAL_sales limit 1)

--4.--How do 2-wheelers and 3-wheelers compare in sales? ---

SELECT vehicle_category, SUM(ev_sales_quantity) AS Total_Sales
FROM electric_vehicle_sales
WHERE vehicle_category IN ('2-Wheelers', '3-Wheelers')
GROUP BY vehicle_category
ORDER BY Total_Sales DESC;

----------------------------------------------------------------------------------------------------------------------------------------------

					  --  Monthly & Yearly Trends:---
                      
--5--How do EV sales fluctuate across months and years?---

SELECT year, DATE_FORMAT(date,'%M') AS Months, SUM(ev_sales_quantity) AS Total_Sales
FROM electric_vehicle_sales
GROUP BY year,Months
ORDER BY year ASC, Months ASC, Total_Sales DESC;

--6.-- What are the peak and low sales months?----

(SELECT DATE_FORMAT(date,'%M') AS Months, SUM(ev_sales_quantity) AS Total_Sales
FROM electric_vehicle_sales
GROUP BY Months
ORDER BY Total_Sales DESC
LIMIT 1)
UNION
(SELECT DATE_FORMAT(date,'%M') AS Months, SUM(ev_sales_quantity) AS Total_Sales
FROM electric_vehicle_sales
GROUP BY Months
ORDER BY Total_Sales ASC
LIMIT 1)

------------------------------------------------------------------------------------------------------------------------------

                                   -- Market Share Analysis:--
                                   
-- 7--Which state dominates the EV market?---
SELECT state, SUM(ev_sales_quantity) AS Total_Sales
FROM  electric_vehicle_sales
GROUP BY state
ORDER BY Total_Sales DESC
LIMIT 1;

--8-- What is the percentage contribution of each vehicle type to total sales?-----

SELECT vehicle_type,
       SUM(ev_sales_quantity) AS Total_Sales,
       (SUM(ev_sales_quantity) * 100.0 / 
       (SELECT SUM(ev_sales_quantity) FROM electric_vehicle_sales)) AS Percentage_Contribution
FROM electric_vehicle_sales
GROUP BY vehicle_type
ORDER BY Percentage_Contribution DESC;

---------------------------------------------------------------------------------------------------------------------------

                                         -- Growth & Forecasting:------
                                         
--9.- How have EV sales grown from 2022 to 2024?--

SELECT year, 
SUM(ev_sales_quantity) AS Total_Sales,
LAG(SUM(ev_sales_quantity)) 
OVER (ORDER BY year) AS Previous_Year_Sales,
(SUM(ev_sales_quantity) - LAG(SUM(ev_sales_quantity))
OVER (ORDER BY year)) AS Sales_Growth,
ROUND((SUM(ev_sales_quantity) - LAG(SUM(ev_sales_quantity)) OVER (ORDER BY year)) * 100.0 / 
LAG(SUM(ev_sales_quantity)) OVER (ORDER BY year), 2) AS Growth_Percentage
FROM electric_vehicle_sales
WHERE year BETWEEN 2022 AND 2024
GROUP BY year
ORDER BY year;

--10.---What trends indicate future growth opportunities? ---                

SELECT state, year, 
       SUM(ev_sales_quantity) AS Total_Sales,
       ROUND((SUM(ev_sales_quantity) - LAG(SUM(ev_sales_quantity)) OVER (ORDER BY year)) * 100.0 / 
             LAG(SUM(ev_sales_quantity)) OVER (ORDER BY year), 2) AS Growth_Percentage
FROM electric_vehicle_sales
GROUP BY state,year
ORDER BY  Growth_Percentage DESC;
------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------







