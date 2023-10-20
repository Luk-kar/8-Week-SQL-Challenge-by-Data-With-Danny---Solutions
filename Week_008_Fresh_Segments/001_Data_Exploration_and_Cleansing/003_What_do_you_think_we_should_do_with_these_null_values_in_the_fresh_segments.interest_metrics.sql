/*
3. What do you think we should do with these null values 
in the `fresh_segments.interest_metrics`
*/

-- 1. Counting the total number of rows in the v_fresh_segments.interest_metrics table.

SELECT 
    COUNT(*)
FROM v_fresh_segments.interest_metrics
;

/*
| count |
|-------|
| 14273 |
*/

-- 2. Counting the number of null values in each column of the `v_fresh_segments.interest_metrics` table.

SELECT
    COUNT(CASE WHEN _month IS NULL THEN 1 END) AS _month,
    COUNT(CASE WHEN _year IS NULL THEN 1 END) AS _year,
    COUNT(CASE WHEN month_year IS NULL THEN 1 END) AS month_year,
    COUNT(CASE WHEN interest_id IS NULL THEN 1 END) AS interest_id,
    COUNT(CASE WHEN composition IS NULL THEN 1 END) AS composition,
    COUNT(CASE WHEN index_value IS NULL THEN 1 END) AS index_value,
    COUNT(CASE WHEN ranking IS NULL THEN 1 END) AS ranking,
    COUNT(CASE WHEN percentile_ranking IS NULL THEN 1 END) AS percentile_ranking
FROM v_fresh_segments.interest_metrics
;

/*
| _month  | _year  | month_year  | interest_id  | composition  | index_value  | ranking  | percentile_ranking |
|---------|--------|-------------|--------------|--------------|--------------|----------|--------------------|
| 1194    | 1194   | 1194        | 1193         | 0            | 0            | 0        | 0                  |
*/

-- 3. Counting the number of rows with all nulls values in _month, _year, month_year, or interest_id columns.

SELECT COUNT(*) AS count_rows_with_all_null
FROM fresh_segments.interest_metrics -- Use original data cause Query Error: error: COALESCE types character varying and date cannot be matched
WHERE COALESCE(_month, _year, month_year, interest_id) IS NULL
;

/*
| count_rows_with_all_null |
|--------------------------|
| 1193                     |
*/

-- 4. Counting the number of rows with all nulls values in _month, _year, month_year.

SELECT COUNT(*) AS count_rows_with_all_null
FROM fresh_segments.interest_metrics -- Use original data cause Query Error: error: COALESCE types character varying and date cannot be matched
WHERE COALESCE(_month, _year, month_year) IS NULL
;

/*
| count_rows_with_all_null |
|--------------------------|
| 1194                     |
*/

-- 5. Calculating percentage of rows with NULL values

/*
The rows with any null are only:
14273 / 1194 = 8.67%
*/

-- 7. Showing existing `interest_id` with non-existing `month_year`

SELECT *
FROM v_fresh_segments.interest_metrics
WHERE interest_id IS NOT NULL AND month_year IS NULL
;

/*
| _month  | _year  | month_year  | interest_id  | composition  | index_value  | ranking  | percentile_ranking |
|---------|--------|-------------|--------------|--------------|--------------|----------|--------------------|
| null    | null   | null        | 21246        | 1.61         | 0.68         | 1191     | 0.25               |
*/

-- 8. Checking if interest_id exists in `interest_map` table

SELECT *
FROM fresh_segments.interest_map
WHERE id = 21246
;

/*
| id     | interest_name                     | interest_summary                                       | created_at                | last_modified            |
|--------|-----------------------------------|--------------------------------------------------------|---------------------------|--------------------------|
| 21246  | Readers of El Salvadoran Content  | People reading news from El Salvadoran media sources.  | 2018-06-11T17:50:04.000Z  | 2018-06-11T17:50:04.000Z |
*/


-- 9. Checking missing dates and interest data

SELECT *
FROM v_fresh_segments.interest_metrics
WHERE interest_id IS NULL AND month_year IS NULL
LIMIT 10
;

/*
| _month  | _year  | month_year  | interest_id  | composition  | index_value  | ranking  | percentile_ranking |
|---------|--------|-------------|--------------|--------------|--------------|----------|--------------------|
| null    | null   | null        | null         | 6.12         | 2.85         | 43       | 96.4               |
| null    | null   | null        | null         | 7.13         | 2.84         | 45       | 96.23              |
| null    | null   | null        | null         | 6.82         | 2.84         | 45       | 96.23              |
| null    | null   | null        | null         | 5.96         | 2.83         | 47       | 96.06              |
| null    | null   | null        | null         | 7.73         | 2.82         | 48       | 95.98              |
| null    | null   | null        | null         | 5.37         | 2.82         | 48       | 95.98              |
| null    | null   | null        | null         | 6.15         | 2.82         | 48       | 95.98              |
| null    | null   | null        | null         | 5.46         | 2.81         | 51       | 95.73              |
| null    | null   | null        | null         | 5.99         | 2.44         | 113      | 90.54              |
| null    | null   | null        | null         | 4.87         | 2.44         | 113      | 90.54              |
*/

-- 10. Checking existing `interest_id` with non-existing `month_year` occurrence in non-null set

WITH no_month_year AS (
SELECT *
FROM v_fresh_segments.interest_metrics
WHERE interest_id IS NOT NULL AND month_year IS NULL
)
SELECT
	COUNT(*)
FROM v_fresh_segments.interest_metrics AS im
INNER JOIN no_month_year AS nmy ON 
  im.interest_id = nmy.interest_id AND
  im.composition = nmy.composition AND
  im.index_value = nmy.index_value AND
  im.ranking = nmy.ranking AND
  im.percentile_ranking = nmy.percentile_ranking
WHERE im.month_year IS NOT NULL
;

/*
| count |
|-------|
| 0     |
*/

-- 11. Checking non-existing `interest_id` with non-existing `month_year` occurrence in non-null set

WITH no_interest_id AS (
SELECT *
FROM v_fresh_segments.interest_metrics
WHERE month_year IS NULL AND interest_id IS NULL
)
SELECT
	COUNT(*)
FROM v_fresh_segments.interest_metrics AS im
INNER JOIN no_interest_id AS ni ON 
  im.month_year = ni.month_year
WHERE im.interest_id IS NOT NULL
;

/*
| count |
|-------|
| 0     |
*/

/*
Summary:
-- There is no coverage of entries with missing data when comparing them to entries without missing data.
-- There is no coverage of entries with missing dates when comparing them to entries with missing interest_id.
-- dates and interest_id are missing in all examples with only one exception. The interest_id with missing dates.
-- So the entries with missing data are not a duplicates. They are undefined values.

Furthermore, I consider that null values must be destroyed
*/

DROP SCHEMA IF EXISTS v_fresh_segments CASCADE;
CREATE SCHEMA v_fresh_segments;

-- interest_metrics
DROP VIEW IF EXISTS v_fresh_segments.interest_metrics;
CREATE VIEW v_fresh_segments.interest_metrics AS
SELECT 
    _month,
    _year,
    TO_DATE(month_year, 'MM-YYYY') AS month_year,
    interest_id,
    composition,
    index_value,
    ranking,
    percentile_ranking
FROM fresh_segments.interest_metrics
WHERE _month IS NOT NULL AND _year IS NOT NULL AND month_year IS NOT NULL AND interest_id IS NOT NULL
;

SELECT 
    COUNT(*)
FROM v_fresh_segments.interest_metrics
;

/*
| count |
|-------|
| 13079 |
*/

--

/*
Put simply - we should remove these values as we will not be able to specify 
which date period they are assigned to and hence are not useful for our analysis.

Looking at this in the context of the overall dataset and the business problem - 
it does not make too much sense to include these erroneous records into the analysis 
because we are going to be interested in the records only with a date specified!

This question is usually asked during data science interviews when dealing with missing records - 
usually the rule of thumb is to remove them - 
but sometimes it can be inferred from other data points or it can be filled using 
the mean, median or mode values of the column, 
however plenty of care must be taken to assess the actual business problem and 
not just blindly apply null filling techniques!
*/