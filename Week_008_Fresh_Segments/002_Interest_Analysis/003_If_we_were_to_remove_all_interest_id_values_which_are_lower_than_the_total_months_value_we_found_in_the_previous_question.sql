/*
3. If we were to remove all interest_id values 
which are lower than the total_months value we found in the previous question - 
how many total data points would we be removing?
*/

WITH cte_removed_interests AS (
SELECT
  interest_id
FROM fresh_segments.interest_metrics
WHERE interest_id IS NOT NULL
GROUP BY interest_id
HAVING COUNT(DISTINCT month_year) < 6
)
SELECT
  COUNT(*) AS removed_rows
FROM fresh_segments.interest_metrics 
WHERE EXISTS (
  SELECT 1
  FROM cte_removed_interests
  WHERE interest_metrics.interest_id = cte_removed_interests.interest_id
)
;

/*
| removed_rows |
|--------------|
| 400          |
*/