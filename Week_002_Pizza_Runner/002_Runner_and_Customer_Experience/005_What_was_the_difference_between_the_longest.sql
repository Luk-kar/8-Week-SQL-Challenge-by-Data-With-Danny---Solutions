-- 5. What was the difference between the longest and shortest delivery times for all orders?

SELECT
  MIN(duration) AS shortest_delivery_duration,
  MAX(duration) AS longest_delivery_duration,
  MAX(duration) - MIN(duration) as difference_shortest_longest_delivery_duration
FROM pizza_runner_v.runner_orders AS runner_orders
WHERE distance IS NOT NULL

-- shortest_delivery_duration | longest_delivery_duration | difference_shortest_longest_delivery_duration
-- { "minutes": 10 } | { "minutes": 40 } | { "minutes": 30 }