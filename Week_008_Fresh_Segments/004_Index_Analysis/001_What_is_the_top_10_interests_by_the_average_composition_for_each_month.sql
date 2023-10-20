/*
1. What is the top 10 interests 
by the average composition for each month?
*/

WITH cte_index_composition AS (
  SELECT
    interest_metrics.month_year,
    interest_map.interest_name,
    interest_metrics.composition::DECIMAL / interest_metrics.index_value AS index_composition,
    DENSE_RANK() OVER (
      PARTITION BY interest_metrics.month_year
      ORDER BY interest_metrics.composition::DECIMAL / interest_metrics.index_value DESC
    ) AS index_rank
  FROM v_fresh_segments.interest_metrics
  INNER JOIN fresh_segments.interest_map
    ON interest_metrics.interest_id = interest_map.id
  WHERE interest_metrics.month_year IS NOT NULL
)
SELECT *
FROM cte_index_composition
WHERE index_rank <= 10
ORDER BY month_year, index_rank
;

/*
| month_year                | interest_name                  | index_composition   | index_rank |
|---------------------------|--------------------------------|---------------------|------------|
| 2018-07-01T00:00:00.000Z  | Las Vegas Trip Planners        | 7.3571428571428585  | 1          |
| 2018-07-01T00:00:00.000Z  | Gym Equipment Owners           | 6.9446494464944655  | 2          |
| 2018-07-01T00:00:00.000Z  | Cosmetics and Beauty Shoppers  | 6.776190476190476   | 3          |
| 2018-07-01T00:00:00.000Z  | Luxury Retail Shoppers         | 6.611538461538462   | 4          |
| 2018-07-01T00:00:00.000Z  | Furniture Shoppers             | 6.507462686567164   | 5          |
| 2018-07-01T00:00:00.000Z  | Asian Food Enthusiasts         | 6.1000000000000005  | 6          |
...
*/