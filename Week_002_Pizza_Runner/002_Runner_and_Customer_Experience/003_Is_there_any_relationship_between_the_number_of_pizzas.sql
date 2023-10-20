-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

SELECT DISTINCT
  t1.order_id,
  DATE_PART('minutes', AGE(t1.pickup_time, t2.order_time))::INTEGER AS pickup_minutes,
  SUM(t2.order_id) AS pizza_count
FROM pizza_runner_v.runner_orders AS t1
INNER JOIN pizza_runner_v.customer_orders AS t2
  ON t1.order_id = t2.order_id
WHERE t1.cancellation IS NULL
GROUP BY t1.order_id, pickup_minutes
ORDER BY pizza_count, pickup_minutes;

-- | order_id | pickup_minutes | pizza_count |
-- |----------|----------------|-------------|
-- | 1        | 10             | 1           |
-- | 2        | 10             | 2           |
-- | 5        | 10             | 5           |
-- | 3        | 21             | 6           |
-- | 7        | 10             | 7           |
-- | 8        | 20             | 8           |
-- | 4        | 29             | 12          |
-- | 10       | 15             | 20          |
