/*
1. Update the `fresh_segments.interest_metrics` table 
by modifying the `month_year` column 
to be a date data type with the start of the month
*/

DROP SCHEMA IF EXISTS v_fresh_segments CASCADE;
CREATE SCHEMA v_fresh_segments;

-- interest_metrics
DROP VIEW IF EXISTS v_fresh_segments.interest_metrics;
CREATE VIEW v_fresh_segments.interest_metrics AS
SELECT 
    _month,
    _year,
    CASE 
      WHEN month_year IS NOT NULL THEN TO_DATE(month_year, 'MM-YYYY')
      ELSE NULL 
    END AS month_year,
    interest_id,
    composition,
    index_value,
    ranking,
    percentile_ranking
FROM fresh_segments.interest_metrics;


SELECT 
    *
FROM v_fresh_segments.interest_metrics LIMIT 10;

--

UPDATE fresh_segments.interest_metrics
SET month_year = TO_DATE(month_year, 'MM-YYYY');

ALTER TABLE fresh_segments.interest_metrics
ALTER month_year TYPE DATE USING month_year::DATE;