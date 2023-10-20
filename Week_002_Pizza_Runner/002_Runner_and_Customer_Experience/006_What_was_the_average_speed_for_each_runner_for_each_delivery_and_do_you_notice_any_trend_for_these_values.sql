-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

SELECT
  runner_id,
  order_id,
  DATE_PART('hour', pickup_time) AS hour_of_day,
  distance,
  duration,
  ROUND((distance / (EXTRACT(EPOCH FROM duration)::NUMERIC / 3600)), 1) AS avg_speed
FROM pizza_runner_v.runner_orders
WHERE cancellation IS NULL

-- | runner_id | order_id | hour_of_day | distance | duration        | avg_speed |
-- |-----------|----------|-------------|----------|-----------------|-----------|
-- | 1         | 1        | 18          | 20       | { "minutes": 32 }   | 37,5      |
-- | 1         | 2        | 19          | 20       | { "minutes": 27 } | 44,4      |
-- | 1         | 3        | 0           | 13,4     | { "minutes": 20 } | 40,2      |
-- | 2         | 4        | 13          | 23,4     | { "minutes": 40 } | 35,1      |
-- | 3         | 5        | 21          | 10       | { "minutes": 15 } | 40        |
-- | 2         | 7        | 21          | 25       | { "minutes": 25 } | 60        |
-- | 2         | 8        | 0           | 23,4     | { "minutes": 15 } | 93,6      |
-- | 1         | 10       | 18          | 10       | { "minutes": 10 } | 60        |
