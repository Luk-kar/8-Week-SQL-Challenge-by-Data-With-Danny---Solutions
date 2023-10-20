DROP SCHEMA IF EXISTS v_fresh_segments CASCADE;
CREATE SCHEMA v_fresh_segments;

-- interest_metrics_cleaned
DROP VIEW IF EXISTS v_fresh_segments.interest_metrics;
CREATE VIEW v_fresh_segments.interest_metrics AS
SELECT 
    _month::INTEGER,
    _year::INTEGER,
    TO_DATE(month_year, 'MM-YYYY') AS month_year,
    interest_id::INTEGER,
    composition,
    index_value,
    ranking,
    percentile_ranking
FROM fresh_segments.interest_metrics
WHERE _month IS NOT NULL AND _year IS NOT NULL AND month_year IS NOT NULL AND interest_id IS NOT NULL
;

-- reuse queries

SELECT 
    *
FROM v_fresh_segments.interest_metrics
;

SELECT 
    *
FROM v_fresh_segments.interest_metrics
JOIN fresh_segments.interest_map ON
interest_metrics.interest_id = interest_map.id
;