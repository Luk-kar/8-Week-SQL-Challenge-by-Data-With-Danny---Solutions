-- 9. What was the total volume of pizzas ordered for each hour of the day?

SELECT
	EXTRACT(HOUR FROM customer_orders.order_time ) AS hour,
  COUNT(*) AS total_orders
FROM pizza_runner_v.customer_orders AS customer_orders
GROUP BY hour
ORDER BY hour;

-- | hour | total_orders |
-- |------|--------------|
-- | 11   | 1            |
-- | 13   | 3            |
-- | 18   | 3            |
-- | 19   | 1            |
-- | 21   | 3            |
-- | 23   | 3            |
