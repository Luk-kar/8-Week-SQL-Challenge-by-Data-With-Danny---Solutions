/* 
4. For the 5 interests found in the previous question - 
what was minimum and maximum percentile_ranking values 
for each interest and its corresponding year_month value? 
Can you describe what is happening for these 5 interests?
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
),
top_5 AS (
    SELECT
        *
    FROM ranked
    WHERE descending <= 5
),
max_min_percentile_ranking_and_its_months AS (
    WITH windowed AS (
        SELECT 
            interest_id,
            percentile_ranking,
            month_year,
            FIRST_VALUE(month_year) OVER (PARTITION BY interest_id ORDER BY percentile_ranking) AS min_month,
            FIRST_VALUE(month_year) OVER (PARTITION BY interest_id ORDER BY percentile_ranking DESC) AS max_month
        FROM v_fresh_segments.interest_metrics
        WHERE EXISTS (
            SELECT 1
            FROM top_5
            WHERE interest_metrics.interest_id = top_5.interest_id
        )
    )
    SELECT 
        interest_id,
        MIN(percentile_ranking) AS min_percentile,
        MAX(min_month) AS min_month, -- Since all values will be the same, MAX or MIN doesn't matter
        MAX(percentile_ranking) AS max_percentile,
        MAX(max_month) AS max_month  -- Since all values will be the same, MAX or MIN doesn't matter
    FROM windowed
    GROUP BY interest_id
)
SELECT
	top_5.descending,
    top_5.standard_deviation,
    min_max.min_percentile,
    min_max.max_percentile,
    ROUND(min_max.max_percentile - min_max.min_percentile) AS min_max_percentile_diff,
    min_max.min_month,
    min_max.max_month,
    min_max.max_month - min_max.min_month AS min_max_diff_days,
    imap.id,
    imap.interest_name,
    imap.interest_summary
FROM top_5
JOIN fresh_segments.interest_map AS imap ON top_5.interest_id = imap.id
JOIN max_min_percentile_ranking_and_its_months AS min_max ON top_5.interest_id = min_max.interest_id
ORDER BY descending
;

/*
| descending  | standard_deviation  | min_percentile  | max_percentile  | min_max_percentile_diff  | min_month                 | max_month                 | min_max_diff_days  | id     | interest_name                           | interest_summary                                                                          |
|-------------|---------------------|-----------------|-----------------|--------------------------|---------------------------|---------------------------|--------------------|--------|-----------------------------------------|-------------------------------------------------------------------------------------------|
| 1           | 41.274              | 2.26            | 60.63           | 58.37                    | 2019-08-01T00:00:00.000Z  | 2018-07-01T00:00:00.000Z  | -396               | 6260   | Blockbuster Movie Fans                  | Consumers reading reviews of major movie releases.                                        |
| 2           | 30.721              | 4.84            | 75.03           | 70.19                    | 2019-03-01T00:00:00.000Z  | 2018-07-01T00:00:00.000Z  | -243               | 131    | Android Fans                            | Readers of Android news and product reviews.                                              |
| 3           | 30.364              | 10.01           | 93.28           | 83.27                    | 2019-08-01T00:00:00.000Z  | 2018-07-01T00:00:00.000Z  | -396               | 150    | TV Junkies                              | Consumers researching TV listings.                                                        |
| 4           | 30.175              | 7.92            | 86.69           | 78.77                    | 2019-08-01T00:00:00.000Z  | 2018-07-01T00:00:00.000Z  | -396               | 23     | Techies                                 | Readers of tech news and gadget reviews.                                                  |
| 5           | 28.975              | 11.23           | 86.15           | 74.92                    | 2019-08-01T00:00:00.000Z  | 2018-07-01T00:00:00.000Z  | -396               | 20764  | Entertainment Industry Decision Makers  | Professionals reading industry news and researching trends in the entertainment industry. |
*/

/*
All of the examples have a big decrease in percentile_ranking in 396 and 243 days
*/

WITH top_5_sd_ids AS (
  SELECT
    interest_metrics.interest_id,
    ROUND(STDDEV(interest_metrics.percentile_ranking)::DECIMAL, 1) AS stddev_pc_ranking
  FROM v_fresh_segments.interest_metrics
  JOIN fresh_segments.interest_map
    ON interest_metrics.interest_id = interest_map.id
  GROUP BY
    interest_metrics.interest_id
  ORDER BY stddev_pc_ranking DESC NULLS LAST
  LIMIT 5
)
SELECT
  interest_map.interest_name,
  interest_metrics.month_year,
  interest_metrics.ranking,
  interest_metrics.percentile_ranking,
  interest_metrics.composition
FROM v_fresh_segments.interest_metrics
INNER JOIN fresh_segments.interest_map
  ON interest_metrics.interest_id = interest_map.id
INNER JOIN top_5_sd_ids
  ON interest_metrics.interest_id = top_5_sd_ids.interest_id
WHERE interest_metrics.month_year IS NOT NULL
ORDER BY
  ARRAY_POSITION(ARRAY(SELECT interest_id FROM top_5_sd_ids ORDER BY stddev_pc_ranking DESC), interest_metrics.interest_id),
  interest_metrics.month_year
;

/*
| interest_name                           | month_year                | ranking  | percentile_ranking  | composition |
|-----------------------------------------|---------------------------|----------|---------------------|-------------|
| Blockbuster Movie Fans                  | 2018-07-01T00:00:00.000Z  | 287      | 60.63               | 5.27        |
| Blockbuster Movie Fans                  | 2019-08-01T00:00:00.000Z  | 1123     | 2.26                | 1.83        |
| Android Fans                            | 2018-07-01T00:00:00.000Z  | 182      | 75.03               | 5.09        |
| Android Fans                            | 2018-08-01T00:00:00.000Z  | 684      | 10.82               | 1.77        |
| Android Fans                            | 2019-02-01T00:00:00.000Z  | 1058     | 5.62                | 1.85        |
| Android Fans                            | 2019-03-01T00:00:00.000Z  | 1081     | 4.84                | 1.72        |
| Android Fans                            | 2019-08-01T00:00:00.000Z  | 1092     | 4.96                | 1.91        |
| TV Junkies                              | 2018-07-01T00:00:00.000Z  | 49       | 93.28               | 5.3         |
| TV Junkies                              | 2018-08-01T00:00:00.000Z  | 481      | 37.29               | 1.7         |
| TV Junkies                              | 2018-10-01T00:00:00.000Z  | 430      | 49.82               | 2.34        |
| TV Junkies                              | 2018-12-01T00:00:00.000Z  | 619      | 37.79               | 1.72        |
| TV Junkies                              | 2019-08-01T00:00:00.000Z  | 1034     | 10.01               | 1.94        |
| Techies                                 | 2018-07-01T00:00:00.000Z  | 97       | 86.69               | 5.41        |
| Techies                                 | 2018-08-01T00:00:00.000Z  | 530      | 30.9                | 1.9         |
| Techies                                 | 2018-09-01T00:00:00.000Z  | 594      | 23.85               | 1.6         |
| Techies                                 | 2019-02-01T00:00:00.000Z  | 1015     | 9.46                | 1.89        |
| Techies                                 | 2019-03-01T00:00:00.000Z  | 1026     | 9.68                | 1.91        |
| Techies                                 | 2019-08-01T00:00:00.000Z  | 1058     | 7.92                | 1.9         |
| Entertainment Industry Decision Makers  | 2018-07-01T00:00:00.000Z  | 101      | 86.15               | 5.85        |
| Entertainment Industry Decision Makers  | 2018-08-01T00:00:00.000Z  | 644      | 16.04               | 1.78        |
| Entertainment Industry Decision Makers  | 2018-10-01T00:00:00.000Z  | 697      | 18.67               | 2.01        |
| Entertainment Industry Decision Makers  | 2019-02-01T00:00:00.000Z  | 873      | 22.12               | 2.11        |
| Entertainment Industry Decision Makers  | 2019-03-01T00:00:00.000Z  | 1005     | 11.53               | 1.97        |
| Entertainment Industry Decision Makers  | 2019-08-01T00:00:00.000Z  | 1020     | 11.23               | 1.91        |
*/
