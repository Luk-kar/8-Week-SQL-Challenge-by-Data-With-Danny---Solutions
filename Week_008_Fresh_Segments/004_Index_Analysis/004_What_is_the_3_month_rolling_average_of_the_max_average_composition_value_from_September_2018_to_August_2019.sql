/*
4. What is the 3 month rolling average of the max average composition value 
from September 2018 to August 2019 and 
include the previous top ranking interests in the same output shown below.
*/


WITH ranked AS (
    SELECT
        month_year,
        interest_id,
        composition::DECIMAL / index_value AS index_composition,
        DENSE_RANK() OVER (
        PARTITION BY month_year
        ORDER BY composition::DECIMAL / index_value DESC
        ) AS index_rank
    FROM v_fresh_segments.interest_metrics
),
final_result AS (
    SELECT
        r.month_year,
        imap.interest_name,
        ROUND(r.index_composition::DECIMAL, 2) AS index_composition,
        ROUND(
            AVG(r.index_composition) OVER (
              ORDER BY r.month_year
              ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING
            )::DECIMAL, 
          2) AS "3_month_moving_avg",
        LAG(imap.interest_name, 1) OVER (ORDER BY r.month_year) || 
        ': ' || 
        ROUND(LAG(r.index_composition, 1) OVER (ORDER BY r.month_year)::DECIMAL, 2) AS "1_month_ago",
        LAG(imap.interest_name, 2) OVER (ORDER BY r.month_year) || 
        ': ' || 
        ROUND(LAG(r.index_composition, 2) OVER (ORDER BY r.month_year)::DECIMAL, 2) AS "2_months_ago"
    FROM ranked r
    JOIN fresh_segments.interest_map imap ON
    r.interest_id = imap.id
    WHERE r.index_rank = 1
)
SELECT
    *
FROM final_result
WHERE month_year BETWEEN '2018-09-01' AND '2019-08-01'
ORDER BY month_year
;

/*
| month_year                | interest_name                  | index_composition  | 3_month_moving_avg  | 1_month_ago                        | 2_months_ago                      |
|---------------------------|--------------------------------|--------------------|---------------------|------------------------------------|-----------------------------------|
| 2018-09-01T00:00:00.000Z  | Work Comes First Travelers     | 8.26               | 8.56                | Las Vegas Trip Planners: 7.21      | Las Vegas Trip Planners: 7.36     |
| 2018-10-01T00:00:00.000Z  | Work Comes First Travelers     | 9.14               | 8.58                | Work Comes First Travelers: 8.26   | Las Vegas Trip Planners: 7.21     |
| 2018-11-01T00:00:00.000Z  | Work Comes First Travelers     | 8.28               | 8.08                | Work Comes First Travelers: 9.14   | Work Comes First Travelers: 8.26  |
| 2018-12-01T00:00:00.000Z  | Work Comes First Travelers     | 8.31               | 7.88                | Work Comes First Travelers: 8.28   | Work Comes First Travelers: 9.14  |
| 2019-01-01T00:00:00.000Z  | Work Comes First Travelers     | 7.66               | 7.29                | Work Comes First Travelers: 8.31   | Work Comes First Travelers: 8.28  |
| 2019-02-01T00:00:00.000Z  | Work Comes First Travelers     | 7.66               | 6.83                | Work Comes First Travelers: 7.66   | Work Comes First Travelers: 8.31  |
| 2019-03-01T00:00:00.000Z  | Alabama Trip Planners          | 6.54               | 5.74                | Work Comes First Travelers: 7.66   | Work Comes First Travelers: 7.66  |
| 2019-04-01T00:00:00.000Z  | Solar Energy Researchers       | 6.28               | 4.48                | Alabama Trip Planners: 6.54        | Work Comes First Travelers: 7.66  |
| 2019-05-01T00:00:00.000Z  | Readers of Honduran Content    | 4.41               | 3.33                | Solar Energy Researchers: 6.28     | Alabama Trip Planners: 6.54       |
| 2019-06-01T00:00:00.000Z  | Las Vegas Trip Planners        | 2.77               | 2.77                | Readers of Honduran Content: 4.41  | Solar Energy Researchers: 6.28    |
| 2019-07-01T00:00:00.000Z  | Las Vegas Trip Planners        | 2.82               | 2.77                | Las Vegas Trip Planners: 2.77      | Readers of Honduran Content: 4.41 |
| 2019-08-01T00:00:00.000Z  | Cosmetics and Beauty Shoppers  | 2.73               | 2.73                | Las Vegas Trip Planners: 2.82      | Las Vegas Trip Planners: 2.77     |
*/