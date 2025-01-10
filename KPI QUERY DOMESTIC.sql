create database AIRINDIA;
use airindia;
select * from airindia;
-- 1.	Calculate the total passengers carried per year.
select fy,sum(PASSENGERS_CARRIED) as total_passenger from airindia group by fy order by fy; 

-- 2.	Analyze month-wise passenger trends for each year.
select fy, month, sum(PASSENGERS_CARRIED) as total_passanger from airindia group by fy, month order by fy,total_passanger;

-- 3.	Determine the year-over-year passenger growth percentage.
WITH total_pass AS (
    SELECT fy,SUM(PASSENGERS_CARRIED) AS passenger_carried FROM airindia GROUP BY fy
),
total_pass_b AS (
    SELECT fy,SUM(PASSENGERS_CARRIED) AS passenger_carriedd FROM airindia WHERE fy BETWEEN 'FY15' AND 'FY23'GROUP BY fy
)
SELECT 
    a.fy, ROUND((b.passenger_carriedd - a.passenger_carried) * 100 / a.passenger_carried, 2) AS annual_growth FROM total_pass a
LEFT JOIN 
    total_pass_b b
ON 
    a.fy = b.fy;

-- * Operational Metrics

-- 4.	Calculate the yearly average number of departures.
select fy, avg(departures) as avg_of_departure from airindia group by fy order by fy;

-- 5.	Compute the total kilometers flown per year.
select fy, avg(kilometer)as avg_distance_cover from airindia group by fy order by fy;

-- 6.	Analyze the total flight hours for each month by year.
select fy, month, SUM(hours) as hour_flight from airindia group by fy, month order by  fy, month;

-- * Efficiency Metrics
-- 7.	Calculate the annual average passenger load factor.
select fy, round(avg(pax_load_factor),3) as load_carried from airindia group by fy;

-- 8.	Evaluate the monthly trends in passenger load factor across years.
select fy, month, round(avg(pax_load_factor),3) as load_carried from airindia group by fy,month order by fy, month;

-- *Comparative Metrics
-- 9.	Identify the best-performing year in terms of total passengers carried.
select fy, sum(passengers_carried) as best_performace from airindia group by fy order by best_performace limit 1;

-- 10.	Find the worst-performing month based on the passenger load factor.
select fy, month, round(min(pax_load_factor),3) as load_carried from airindia group by fy,month order by fy, month limit 1;

-- 11.	Compare total passenger kilometers performed versus available seat kilometers by year.
SELECT fy, month, SUM(passengers_carried) AS total_passengers_carried, SUM(AVAILABLE_SEAT_KILOMETRE) AS total_available_seat_km, 
    ROUND((SUM(passengers_carried) * 100.0) / SUM(AVAILABLE_SEAT_KILOMETRE), 2) AS percentage_carried FROM airindia GROUP BY fy, month 
ORDER BY fy, month;

-- * Seasonality and Patterns
12.	Identify the month with the highest average departures.
select fy, month, avg(DEPARTURES) as higest_avg_departure from airindia group by fy, month order by fy, month limit 1;

13.	Determine peak months for passenger traffic based on total passengers carried.
WITH PeakMonth AS (
    SELECT fy, month, passengers_carried,RANK() OVER (PARTITION BY fy ORDER BY passengers_carried DESC) AS rank_value FROM airindia
)
SELECT fy, month, passengers_carried FROM PeakMonth WHERE rank_value = 1 ORDER BY fy;
