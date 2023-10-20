/* 
5. How would you describe our customers in this segment 
based off their composition and ranking values? 
What sort of products or 
services should we show 
to these customers and 
what should we avoid?
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
),
composition_stats AS (
    SELECT
        interest_id,
        MIN(composition) AS min_composition,
        MAX(composition) AS max_composition
    FROM v_fresh_segments.interest_metrics
    WHERE EXISTS (
        SELECT 1
        FROM top_5
        WHERE interest_metrics.interest_id = top_5.interest_id
    )
  	GROUP BY interest_id
)
SELECT
	top_5.descending,
    top_5.standard_deviation,
    min_max.min_percentile,
    min_max.max_percentile,
    ROUND(min_max.max_percentile - min_max.min_percentile) AS min_max_percentile_diff,
    min_max.min_month AS min_month_percentile,
    min_max.max_month AS max_month_percentile,
    min_max.max_month - min_max.min_month AS min_max_diff_days,
    _stats.min_composition,
    _stats.max_composition,
    imap.id,
    imap.interest_name,
    imap.interest_summary
FROM top_5
JOIN fresh_segments.interest_map AS imap ON top_5.interest_id = imap.id
JOIN max_min_percentile_ranking_and_its_months AS min_max ON top_5.interest_id = min_max.interest_id
JOIN composition_stats AS _stats ON top_5.interest_id = _stats.interest_id
ORDER BY descending
;

/*
| descending  | standard_deviation  | min_percentile  | max_percentile  | min_max_percentile_diff  | min_month_percentile      | max_month_percentile      | min_max_diff_days  | min_composition  | max_composition  | id     | interest_name                           | interest_summary                                                                          |
|-------------|---------------------|-----------------|-----------------|--------------------------|---------------------------|---------------------------|--------------------|------------------|------------------|--------|-----------------------------------------|-------------------------------------------------------------------------------------------|
| 1           | 41.274              | 2.26            | 60.63           | 58                       | 2019-08-01T00:00:00.000Z  | 2018-07-01T00:00:00.000Z  | -396               | 1.83             | 5.27             | 6260   | Blockbuster Movie Fans                  | Consumers reading reviews of major movie releases.                                        |
| 2           | 30.721              | 4.84            | 75.03           | 70                       | 2019-03-01T00:00:00.000Z  | 2018-07-01T00:00:00.000Z  | -243               | 1.72             | 5.09             | 131    | Android Fans                            | Readers of Android news and product reviews.                                              |
| 3           | 30.364              | 10.01           | 93.28           | 83                       | 2019-08-01T00:00:00.000Z  | 2018-07-01T00:00:00.000Z  | -396               | 1.7              | 5.3              | 150    | TV Junkies                              | Consumers researching TV listings.                                                        |
| 4           | 30.175              | 7.92            | 86.69           | 79                       | 2019-08-01T00:00:00.000Z  | 2018-07-01T00:00:00.000Z  | -396               | 1.6              | 5.41             | 23     | Techies                                 | Readers of tech news and gadget reviews.                                                  |
| 5           | 28.975              | 11.23           | 86.15           | 75                       | 2019-08-01T00:00:00.000Z  | 2018-07-01T00:00:00.000Z  | -396               | 1.78             | 5.85             | 20764  | Entertainment Industry Decision Makers  | Professionals reading industry news and researching trends in the entertainment industry. |
*/

/*
The answer

Based on the SQL query results, 
we can glean several pieces of information about each customer segment in the top_5:

1. Standard Deviation of Percentile Ranking: 
This suggests the level of variability in how the interests rank across various metrics. 
Higher standard deviations imply more variability and perhaps a wider range of interests or behaviors.

2. Composition Range: 
This gives us an idea of how strongly this particular interest is represented in the segment. 
The higher the composition value, the more prominent this interest is in the segment.

3. Percentile Ranges (Min and Max): 
These provide insights into the extremities of customer behaviors or interests, 
effectively telling us how niche or general these interests are.

4. Min-Max Percentile Difference: 
This provides an idea of the range within which the percentile rankings fall, 
again offering a measure of the variability or breadth of interests.

5. Time Range (Min and Max Months): 
This can potentially tell us about the seasonality of the interest, 
showing the months when this interest was the least and most prominent.

Based on these details, let's analyze the customer segments:

    1. Blockbuster Movie Fans:
        - High standard deviation (41.274) suggests diverse viewing habits.
        - Composition range (1.83 to 5.27) is decent, showing a good level of interest in blockbuster movies.
        - Products to Show: Latest movie releases, movie merchandise, streaming service subscriptions.
        - Avoid: Independent, low-budget films or documentaries.

    2. Android Fans:
        - A standard deviation of 30.721 suggests they are fairly versatile within the Android ecosystem.
        - Composition range (1.72 to 5.09) indicates they are quite engaged.
        - Products to Show: Android phones, tech gadgets, Android app subscriptions.
        - Avoid: iOS or Windows-related products.

    3. TV Junkies:
        - High standard deviation (30.364) suggests diverse viewing habits.
        - Composition (1.7 to 5.3) implies that they are fairly into TV shows.
        - Products to Show: Streaming service bundles, smart TVs, TV show merchandise.
        - Avoid: Book or game-related subscriptions.

    4. Techies:
        - High standard deviation (30.175) implies diverse tech interests.
        - Composition (1.6 to 5.41) is significant.
        - Products to Show: Latest gadgets, software subscriptions, tech workshops.
        - Avoid: Low-tech or non-tech products like manual tools or basic consumer goods.

    5. Entertainment Industry Decision Makers:
        - High standard deviation (28.975) suggests varying industry-related interests.
        - Composition (1.78 to 5.85) is noteworthy.
        - Products to Show: Industry reports, high-end tech gadgets, networking event passes.
        - Avoid: Basic consumer products or non-industry-specific content.

*/