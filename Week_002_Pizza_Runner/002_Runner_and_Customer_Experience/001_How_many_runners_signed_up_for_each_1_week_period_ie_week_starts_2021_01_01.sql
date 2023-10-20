-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT
  DATE_TRUNC('week', registration_date) + INTERVAL '4 days' AS registration_week,
  COUNT(*) AS number_of_runners
FROM pizza_runner_v.runners AS runners
GROUP BY registration_week
ORDER BY registration_week;

-- | registration_week        | number_of_runners |
-- |--------------------------|-------------------|
-- | 2021-01-01 | 2                 |
-- | 2021-01-08 | 1                 |
-- | 2021-01-15 | 1                 |
