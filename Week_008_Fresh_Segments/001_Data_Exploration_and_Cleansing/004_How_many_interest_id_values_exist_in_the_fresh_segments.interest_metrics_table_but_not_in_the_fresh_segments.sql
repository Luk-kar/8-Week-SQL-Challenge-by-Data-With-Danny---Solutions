/*
4. How many `interest_id` values exist in the `fresh_segments.interest_metrics` table 
but not in the `fresh_segments.interest_map` table? What about the other way around?
*/

WITH summary AS (
    SELECT
        1 AS _order,
        'all_interest_metrics' AS interest_ids,
        COUNT(DISTINCT interest_id) AS _count
    FROM fresh_segments.interest_metrics

    UNION

    SELECT
        2 AS _order,
        'all_interest_map' AS interest_ids,
        COUNT(DISTINCT id) AS _count
    FROM fresh_segments.interest_map

    UNION

    SELECT 
        3 AS _order,
        'not in map' AS interest_ids,
        COUNT(DISTINCT interest_id) AS _count
    FROM fresh_segments.interest_metrics
    WHERE NOT EXISTS (
        SELECT 1
        FROM fresh_segments.interest_map
        WHERE interest_metrics.interest_id::INTEGER = interest_map.id
    )

    UNION

    SELECT 
        4 AS _order,
        'not in metrics' AS interest_ids,
        COUNT(DISTINCT id) AS _count
    FROM fresh_segments.interest_map
    WHERE NOT EXISTS (
        SELECT 1
        FROM fresh_segments.interest_metrics
        WHERE interest_map.id = interest_metrics.interest_id::INTEGER
    )
)
SELECT
    interest_ids,
    _count
FROM summary
ORDER BY _order
;


/*
| interest_ids          | _count |
|-----------------------|--------|
| all_interest_metrics  | 1202   |
| all_interest_map      | 1209   |
| not in map            | 0      |
| not in metrics        | 7      |
*/

SELECT
  COUNT(interest_metrics.interest_id) AS all_interest_metric,
  COUNT(interest_map.id) AS all_interest_map,
  COUNT(CASE WHEN interest_metrics.interest_id IS NOT NULL AND interest_map.id IS NULL THEN 1 END) AS not_in_map,
  COUNT(CASE WHEN interest_metrics.interest_id IS NULL AND interest_map.id IS NOT NULL THEN 1 END) AS not_in_metrics
FROM fresh_segments.interest_metrics
FULL OUTER JOIN fresh_segments.interest_map
  ON interest_metrics.interest_id::INTEGER = interest_map.id
;

/*
| all_interest_metric  | all_interest_map  | not_in_map  | not_in_metrics |
|----------------------|-------------------|-------------|----------------|
| 13080                | 13087             | 0           | 7              |
*/