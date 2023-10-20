/*
2. For all of these top 10 interests - 
which interest appears the most often?
*/

WITH cte_index_composition AS (
  SELECT
    interest_id,
  	composition,
    DENSE_RANK() OVER (
      PARTITION BY month_year
      ORDER BY composition::DECIMAL / index_value DESC
    ) AS index_rank
  FROM v_fresh_segments.interest_metrics
),
top_10_by_month AS (
    SELECT *
    FROM cte_index_composition
    WHERE index_rank <= 10
),
most_popular_interest AS (
    SELECT
        interest_id,
        COUNT(interest_id) AS _count,
  		ROUND(AVG(composition)::DECIMAL, 2) AS avg_composition,
        DENSE_RANK() OVER (ORDER BY COUNT(interest_id) DESC, AVG(composition) DESC) AS ranked
    FROM top_10_by_month
    GROUP BY interest_id
)
SELECT
    mp.ranked,
    imap.interest_name,
    mp._count AS top_months,
    avg_composition AS avg_composition_as_top
FROM most_popular_interest mp
LEFT JOIN fresh_segments.interest_map imap
	ON mp.interest_id = imap.id
WHERE mp.ranked <= 10
ORDER BY mp.ranked
;

/*
| ranked  | interest_name                                         | top_months  | avg_composition_as_top |
|---------|-------------------------------------------------------|-------------|------------------------|
| 1       | Luxury Bedding Shoppers                               | 10          | 12.94                  |
| 2       | Alabama Trip Planners                                 | 10          | 8.64                   |
| 3       | Solar Energy Researchers                              | 10          | 3.61                   |
| 4       | New Years Eve Party Ticket Purchasers                 | 9           | 9.15                   |
| 5       | Nursing and Physicians Assistant Journal Researchers  | 9           | 8.40                   |
| 6       | Readers of Honduran Content                           | 9           | 3.40                   |
| 7       | Work Comes First Travelers                            | 8           | 17.48                  |
| 8       | Teen Girl Clothing Shoppers                           | 8           | 9.42                   |
| 9       | Christmas Celebration Researchers                     | 7           | 11.03                  |
| 10      | Gym Equipment Owners                                  | 5           | 10.79                  |
*/