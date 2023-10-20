-- 2. What range of week numbers are missing from the dataset?

WITH weeks_within_years AS (
	SELECT DISTINCT
      calendar_year,
      week_number
    FROM data_mart_v.weekly_sales
  ),
years_in_data AS (
  SELECT DISTINCT calendar_year FROM weeks_within_years
),
all_weeks_within_years AS (
   SELECT
   calendar_year,
   GENERATE_SERIES(1, CASE 
                      WHEN (calendar_year::INTEGER % 4 = 0 AND calendar_year::INTEGER % 100 != 0) OR (calendar_year::INTEGER % 400 = 0)
                      THEN 53 -- Leap year
                      ELSE 52 -- Non-leap year
                    END) AS week_number
   FROM
   years_in_data
),
non_existing_weeks AS (
SELECT
  calendar_year,
  week_number
FROM all_weeks_within_years
WHERE NOT EXISTS (
  SELECT 1
  FROM weeks_within_years
  WHERE
  weeks_within_years.calendar_year = all_weeks_within_years.calendar_year AND
  weeks_within_years.week_number = all_weeks_within_years.week_number
)
),
GapDetection AS (
    SELECT 
        calendar_year, 
        week_number,
        week_number - ROW_NUMBER() OVER (PARTITION BY calendar_year ORDER BY week_number) AS grp
    FROM non_existing_weeks
),
GroupedRanges AS (
    SELECT 
        calendar_year,
        MIN(week_number) AS start_range,
        MAX(week_number) AS end_range
    FROM GapDetection
    GROUP BY calendar_year, grp
)
SELECT
    calendar_year,
    STRING_AGG(start_range || ' - ' || end_range, ', ') AS non_existing_week_number
FROM GroupedRanges
GROUP BY calendar_year
ORDER BY calendar_year
;

/*
| calendar_year  | non_existing_week_number |
|----------------|--------------------------|
| 2018           | 1 - 12, 37 - 52          |
| 2019           | 1 - 11, 36 - 52          |
| 2020           | 1 - 11, 36 - 53          |
*/