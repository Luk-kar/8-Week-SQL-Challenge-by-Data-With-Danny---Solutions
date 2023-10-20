-- 7. What is the successful delivery percentage for each runner?

SELECT
  runner_id,
  COUNT(*) AS total_deliveries,
  COUNT(CASE WHEN cancellation IS NULL THEN 1 END) AS successful_deliveries,
  COUNT(CASE WHEN cancellation IS NOT NULL THEN 1 END) AS failed_deliveries,
  ROUND((COUNT(CASE WHEN cancellation IS NULL THEN 1 END)::numeric / COUNT(*)) * 100, 2) AS successful_delivery_percentage
FROM pizza_runner_v.runner_orders AS runner_orders
GROUP BY runner_id
ORDER BY successful_delivery_percentage DESC;

-- | runner_id | total_deliveries | successful_deliveries | failed_deliveries | successful_delivery_percentage |
-- |-----------|------------------|-----------------------|-------------------|--------------------------------|
-- | 1         | 4                | 4                     | 0                 | 100                            |
-- | 2         | 4                | 3                     | 1                 | 75                             |
-- | 3         | 2                | 1                     | 1                 | 50                             |
