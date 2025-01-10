use airindia;
select * from airindia;
-- *Operational Efficiency
-- 1.	Top 3 months with the highest number of departures over 10 years:
WITH top_3 AS (
    SELECT fy, month, passengers_carried, RANK() OVER ( partition by fy ORDER BY passengers_carried desc) AS top_3_departure
    FROM 
        airindia
)SELECT fy, month,passengers_carried FROM top_3 WHERE top_3_departure <=3  ORDER BY fy, top_3_departure;

-- 2.	Correlation between flying hours and passengers carried
With stats as (
    select  
        avg(hours) AS avg_flying_hours,
        avg(passengers_carried) AS avg_passengers_carried,
        sum(hours * passengers_carried) AS sum_xy,
        sum(hours * hours) AS sum_xx,
        sum(passengers_carried * passengers_carried) AS sum_yy,
        count(*) as n
    from
        airindia
)
select
    (sum_xy - n * avg_flying_hours * avg_passengers_carried) /
    sqrt(
        (sum_xx - n * avg_flying_hours * avg_flying_hours) *
        (sum_yy - n * avg_passengers_carried * avg_passengers_carried)
    ) as correlation
from
    stats;

-- 3.	Percentage of total kilometers flown annually compared to the cumulative total:
with s as (
select fy, sum(kilometer) as total_kilometer from airindia group by fy),
 b as (
select sum(kilometer)as final_total_kilometer from airindia)
select s.fy, s.total_kilometer, round((s.total_kilometer * 100.0)/ b.final_total_kilometer, 2) as percentage
from s 
cross join b
order by s.fy;

-- *Passenger Behavior and Demand
-- 4.	Annual average passengers per flight
select fy, sum(passengers_carried) / sum(departures) as avg_passanger_flight from airindia group by fy;

-- 5.	Identify the most efficient year in terms of passengers per kilometer
with effective as (
select fy, sum(passengers_carried) as spc, sum(PASSENGER_KMS_PERFORMED) as pkp from airindia group by fy)
select fy, round(spc/pkp,2) as efficiency from effective order by efficiency desc limit 1; 

-- *Seasonality and Trends
-- 6.	Seasonal pattern in passenger load factor (monthly averages across all years
SELECT fy,month,AVG(pax_load_factor) AS avg_load_factor FROM airindia GROUP BY fy, month ORDER BY fy, month;

-- 7.	Find the quarter with the highest passenger traffic
select fy, case when month in ("JAN","FEB","MAR") then "q1"
when month in ("APR", "MAY", "JUNE") then "q2"
when month in ("JULY", "AUG","SEP") then "q3"
else "q4" end as quater,
sum(passengers_carried) as total_passanger
from airindia 
group by fy,quater
order by fy,total_passanger desc;

-- *Performance Anomalies
-- 9.	Months with unusually low or high passenger 
select month, avg(passengers_carried) as avg_total_pass from airindia group by month order by avg_total_pass desc;

-- 10 	Years with the largest drop in passengers compared to the previous year:
WITH yearly_totals AS (
select fy, SUM(passengers_carried) as total_passengers from airindia group by fy),
yearly_drops as (
    select 
        t1.fy as current_year,
        t2.fy as previous_year,
        t1.total_passengers as current_total,
        t2.total_passengers as previous_total,
        (t2.total_passengers - t1.total_passengers) as passenger_drop
    from
        yearly_totals t1
    left join 
        yearly_totals t2
    on cast(substring(t1.fy, 3) as unsigned ) = cast(substring(t2.fy, 3) as unsigned) + 1
)
select current_year,previous_year,passenger_drop from yearly_drops order by passenger_drop DESC;

-- *Comparative Insights
-- 11.	Comparison of load factor between peak and off-peak months
select month,sum( passengers_carried) as total_passenger, avg(pax_load_factor) as pax_load from airindia  group by month order by total_passenger desc;

-- 12.	Identify years with the highest increase in available seat kilometers
WITH YearlySeatCount AS (
    select fy, sum(AVAILABLE_SEAT_KILOMETRE) as seat_count from airindia group by fy
),
YearlyChange AS (
    SELECT fy,seat_count,seat_count - lag(seat_count) over (order by fy) as seat_increase from YearlySeatCount
)
select fy, seat_count, seat_increase from YearlyChange order by seat_increase desc;

-- 13.	Determine if growth in available seat kilometers corresponds to growth in passenger kilometers performed (help by ai )
WITH YearlyMetrics AS (
    SELECT fy, SUM(AVAILABLE_SEAT_KILOMETRE) AS total_ask, SUM(PASSENGER_KMS_PERFORMED) AS total_pkp FROM airindia GROUP BY fy
),
YearlyGrowth AS (
    SELECT fy,total_ask,total_pkp,
        (total_ask - LAG(total_ask) OVER (ORDER BY fy)) * 100.0 / LAG(total_ask) OVER (ORDER BY fy) AS ask_growth,
        (total_pkp - LAG(total_pkp) OVER (ORDER BY fy)) * 100.0 / LAG(total_pkp) OVER (ORDER BY fy) AS pkp_growth
    FROM YearlyMetrics
)
SELECT 
    fy,total_ask,total_pkp,ask_growth AS ask_growth_percentage,pkp_growth AS pkp_growth_percentage,
    CASE 
        WHEN ask_growth IS NOT NULL AND pkp_growth IS NOT NULL AND ask_growth > 0 AND pkp_growth > 0 THEN 'Both Increased'
        WHEN ask_growth IS NOT NULL AND pkp_growth IS NOT NULL AND ask_growth < 0 AND pkp_growth < 0 THEN 'Both Decreased'
        WHEN ask_growth IS NOT NULL AND pkp_growth IS NOT NULL AND ask_growth > 0 AND pkp_growth < 0 THEN 'ASK Up, PKP Down'
        WHEN ask_growth IS NOT NULL AND pkp_growth IS NOT NULL AND ask_growth < 0 AND pkp_growth > 0 THEN 'ASK Down, PKP Up'
        ELSE 'No Comparison'
    END AS growth_trend
FROM 
    YearlyGrowth;

-- *Operational Trade-offs
-- 14.	Flights with the highest hours but lowest load factor
select fy,month,hours,PAX_LOAD_FACTOR from airindia order by hours DESC, PAX_LOAD_FACTOR ASC LIMIT 5;




