/*
3. What is the average of the average composition 
for the top 10 interests for each month?
*/

WITH cte_index_composition AS (
  SELECT
    month_year,
    interest_id,
    AVG(composition::DECIMAL / index_value) OVER (PARTITION BY interest_id) AS avg_index_composition,
    DENSE_RANK() OVER (
      PARTITION BY month_year
      ORDER BY composition::DECIMAL / index_value DESC
    ) AS index_rank
  FROM v_fresh_segments.interest_metrics
)
SELECT
    month_year,
    ROUND(AVG(avg_index_composition)::DECIMAL, 2) AS avg_index_composition_top_10,
    DENSE_RANK() OVER (ORDER BY AVG(avg_index_composition) DESC) AS ranked
FROM cte_index_composition
WHERE index_rank <= 10
GROUP BY month_year
ORDER BY month_year
;

/*
| month_year                | avg_index_composition_top_10  | ranked |
|---------------------------|-------------------------------|--------|
| 2018-07-01T00:00:00.000Z  | 4.57                          | 10     |
| 2018-08-01T00:00:00.000Z  | 4.86                          | 9      |
| 2018-09-01T00:00:00.000Z  | 5.29                          | 3      |
| 2018-10-01T00:00:00.000Z  | 5.28                          | 4      |
| 2018-11-01T00:00:00.000Z  | 5.29                          | 3      |
| 2018-12-01T00:00:00.000Z  | 5.26                          | 5      |
| 2019-01-01T00:00:00.000Z  | 5.31                          | 2      |
| 2019-02-01T00:00:00.000Z  | 5.33                          | 1      |
| 2019-03-01T00:00:00.000Z  | 5.05                          | 6      |
| 2019-04-01T00:00:00.000Z  | 5.02                          | 7      |
| 2019-05-01T00:00:00.000Z  | 4.92                          | 8      |
| 2019-06-01T00:00:00.000Z  | 4.06                          | 12     |
| 2019-07-01T00:00:00.000Z  | 3.99                          | 13     |
| 2019-08-01T00:00:00.000Z  | 4.23                          | 11     |
*/