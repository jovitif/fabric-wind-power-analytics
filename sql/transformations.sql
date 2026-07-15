-- Create a temporary view of the wind_power table
CREATE OR REPLACE TEMPORARY VIEW bronze_wind_power AS
SELECT *
FROM WindPowerAnalytics.LH_Wind_Power_Bronze.dbo.wind_power;

-- Clean and enrich data
CREATE OR REPLACE TEMPORARY VIEW transformed_wind_power AS
SELECT
    production_id,
    date,
    turbine_name,
    capacity,
    location_name,
    latitude,
    longitude,
    region,
    status,
    responsible_department,
    wind_direction,
    ROUND(wind_speed, 2) AS wind_speed,
    ROUND(energy_produced, 2) AS energy_produced,
    DAY(date) AS day,
    MONTH(date) AS month,
    QUARTER(date) AS quarter,
    YEAR(date) AS year,
    REGEXP_REPLACE(time, '-', ':') AS time,
    CAST(SUBSTRING(time, 1, 2) AS INT) AS hour_of_day,
    CAST(SUBSTRING(time, 4, 2) AS INT) AS minute_of_hour,
    CAST(SUBSTRING(time, 7, 2) AS INT) AS second_of_minute,
    CASE
        WHEN CAST(SUBSTRING(time, 1, 2) AS INT) BETWEEN 5 AND 11 THEN 'Morning'
        WHEN CAST(SUBSTRING(time, 1, 2) AS INT) BETWEEN 12 AND 16 THEN 'Afternoon'
        WHEN CAST(SUBSTRING(time, 1, 2) AS INT) BETWEEN 17 AND 20 THEN 'Evening'
        ELSE 'Night'
    END AS time_period
FROM bronze_wind_power;

-- Drop the wind_power table in the Silver Lakehouse if it exists
DROP TABLE IF EXISTS WindPowerAnalytics.LH_Wind_Power_Silver.dbo.wind_power;

-- Create the new wind_power table in Silver Lakehouse
CREATE TABLE WindPowerAnalytics.LH_Wind_Power_Silver.dbo.wind_power
USING delta
AS
SELECT * FROM transformed_wind_power;