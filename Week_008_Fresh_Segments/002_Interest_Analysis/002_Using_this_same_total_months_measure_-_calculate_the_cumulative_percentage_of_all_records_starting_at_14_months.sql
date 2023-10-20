/*
2. Using this same total_months measure - 
calculate the cumulative percentage of all records starting at 14 months - 
which total_months value passes the 90% cumulative percentage value?
*/

WITH cte_interest_months AS (
SELECT
  interest_id,
  COUNT(DISTINCT month_year) AS total_months
FROM fresh_segments.interest_metrics
WHERE interest_id IS NOT NULL
GROUP BY interest_id
),
cte_interest_counts AS (
SELECT
  total_months,
  COUNT(DISTINCT interest_id) AS interest_count
FROM cte_interest_months
GROUP BY total_months
)
SELECT
  total_months,
  interest_count,
  ROUND(
    100 * SUM(interest_count) OVER (ORDER BY total_months DESC) /
      (SUM(interest_count) OVER ()),
    2
  ) AS cumulative_percentage
FROM cte_interest_counts
ORDER BY total_months DESC
;

/*
| total_months  | interest_count  | cumulative_percentage |
|---------------|-----------------|-----------------------|
| 14            | 480             | 39.93                 |
| 13            | 82              | 46.76                 |
| 12            | 65              | 52.16                 |
| 11            | 94              | 59.98                 |
| 10            | 86              | 67.14                 |
| 9             | 95              | 75.04                 |
| 8             | 67              | 80.62                 |
| 7             | 90              | 88.10                 |
| 6             | 33              | 90.85                 |
| 5             | 38              | 94.01                 |
| 4             | 32              | 96.67                 |
| 3             | 15              | 97.92                 |
| 2             | 12              | 98.92                 |
| 1             | 13              | 100.00                |
*/