/*
1. Which interests have been present in all month_year dates in our dataset?
*/

-- firstly check total number of months per interest_id
WITH cte_interest_months AS (
SELECT
  interest_id,
  COUNT(DISTINCT month_year) AS total_months
FROM fresh_segments.interest_metrics
WHERE interest_id IS NOT NULL
GROUP BY interest_id
)
SELECT
  total_months,
  COUNT(DISTINCT interest_id) AS interest_count
FROM cte_interest_months
GROUP BY total_months
ORDER BY total_months DESC;