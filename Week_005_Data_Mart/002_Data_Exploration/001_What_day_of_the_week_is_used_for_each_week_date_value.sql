-- 1. What day of the week is used for each week_date value?
-- We assume that each week of the year starts as the first day of the year

SELECT DISTINCT TO_CHAR(week_date, 'day') AS weekday
FROM data_mart_v.weekly_sales;

/*
| weekday |
|---------|
| monday  |
*/