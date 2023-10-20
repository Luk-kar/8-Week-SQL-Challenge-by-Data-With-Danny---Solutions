/*
7. Are there any records in your joined table where the `month_year` value is before
 the `created_at` value from the `fresh_segments.interest_map` table? 
Do you think these values are valid and why?
*/

/*
Checking if we do not have SCD (slowly changing dimension table)
*/

SELECT
  id,
  COUNT(*) AS _count
FROM fresh_segments.interest_map
GROUP BY id
ORDER BY _count DESC
LIMIT 5;

/*
| id     | count |
|--------|-------|
| 10978  | 1     |
| 7546   | 1     |
| 51     | 1     |
| 45524  | 1     |
| 6062   | 1     |
*/

-- month_year < created_at

SELECT 
    COUNT(*)
FROM v_fresh_segments.interest_metrics
JOIN fresh_segments.interest_map ON
interest_metrics.interest_id = interest_map.id
WHERE month_year < created_at
;

/*
| count |
|-------|
| 188   |
*/

-- preview several rows: month_year < created_at

SELECT 
    month_year,
    interest_id,
    created_at,
    last_modified
FROM v_fresh_segments.interest_metrics
JOIN fresh_segments.interest_map ON
interest_metrics.interest_id = interest_map.id
WHERE month_year < created_at
LIMIT 3
;

/*
| month_year                | interest_id  | created_at                | last_modified            |
|---------------------------|--------------|---------------------------|--------------------------|
| 2018-07-01T00:00:00.000Z  | 32704        | 2018-07-06T14:35:04.000Z  | 2018-07-06T14:35:04.000Z |
| 2018-07-01T00:00:00.000Z  | 33191        | 2018-07-17T10:40:03.000Z  | 2018-07-17T10:46:58.000Z |
| 2018-07-01T00:00:00.000Z  | 32703        | 2018-07-06T14:35:04.000Z  | 2018-07-06T14:35:04.000Z |
*/

-- The `month_year` before the `created_at` seems to be in the same month as in `created_at`.
-- It has to be check if it is in all examples.

SELECT 
    COUNT(*)
FROM v_fresh_segments.interest_metrics
JOIN fresh_segments.interest_map ON
interest_metrics.interest_id = interest_map.id
WHERE month_year < DATE_TRUNC('MONTH', created_at)
;

/*
| count |
|-------|
| 0     |
*/

/*
In `interest_metrics`, each `month_year` starts on the first day of a specific month. 
Unlike this, `interest_map` includes specific days, but overall, 
`interest_metrics` provides full coverage for the same or later months as in `interest_map`.
*/