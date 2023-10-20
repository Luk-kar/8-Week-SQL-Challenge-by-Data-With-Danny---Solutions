/* 
3. Which 5 interests had the largest standard deviation 
in their percentile_ranking value?
*/

WITH STDDEV_by_percentile_ranking AS (
  SELECT
      interest_id,
      ROUND(STDDEV(percentile_ranking)::DECIMAL, 3) AS standard_deviation
  FROM v_fresh_segments.interest_metrics
  GROUP BY interest_id
),
ranked AS (
    SELECT
        *,
        DENSE_RANK() OVER (ORDER BY standard_deviation DESC) AS descending
    FROM STDDEV_by_percentile_ranking
    WHERE standard_deviation IS NOT NULL
)
SELECT
	ranked.descending,
    ranked.standard_deviation,
    imap.id,
    imap.interest_name,
    imap.interest_summary
FROM ranked
JOIN fresh_segments.interest_map AS imap ON ranked.interest_id = imap.id
WHERE descending <= 5
ORDER BY descending
;

/*
| descending  | standard_deviation  | id     | interest_name                           | interest_summary                                                                          |
|-------------|---------------------|--------|-----------------------------------------|-------------------------------------------------------------------------------------------|
| 1           | 41.274              | 6260   | Blockbuster Movie Fans                  | Consumers reading reviews of major movie releases.                                        |
| 2           | 30.721              | 131    | Android Fans                            | Readers of Android news and product reviews.                                              |
| 3           | 30.364              | 150    | TV Junkies                              | Consumers researching TV listings.                                                        |
| 4           | 30.175              | 23     | Techies                                 | Readers of tech news and gadget reviews.                                                  |
| 5           | 28.975              | 20764  | Entertainment Industry Decision Makers  | Professionals reading industry news and researching trends in the entertainment industry. |
*/

SELECT
  interest_metrics.interest_id,
  interest_map.interest_name,
  ROUND(STDDEV(interest_metrics.percentile_ranking)::DECIMAL, 1) AS stddev_pc_ranking,
  MAX(interest_metrics.percentile_ranking) AS max_pc_ranking,
  MIN(interest_metrics.percentile_ranking) AS min_pc_ranking,
  COUNT(*) AS record_count
FROM v_fresh_segments.interest_metrics
JOIN fresh_segments.interest_map
  ON interest_metrics.interest_id = interest_map.id
GROUP BY
  interest_metrics.interest_id,
  interest_map.interest_name
ORDER BY stddev_pc_ranking DESC NULLS LAST
LIMIT 5;

/*
| interest_id  | interest_name                           | stddev_pc_ranking  | max_pc_ranking  | min_pc_ranking  | record_count |
|--------------|-----------------------------------------|--------------------|-----------------|-----------------|--------------|
| 6260         | Blockbuster Movie Fans                  | 41.3               | 60.63           | 2.26            | 2            |
| 131          | Android Fans                            | 30.7               | 75.03           | 4.84            | 5            |
| 150          | TV Junkies                              | 30.4               | 93.28           | 10.01           | 5            |
| 23           | Techies                                 | 30.2               | 86.69           | 7.92            | 6            |
| 20764        | Entertainment Industry Decision Makers  | 29.0               | 86.15           | 11.23           | 6            |
*/