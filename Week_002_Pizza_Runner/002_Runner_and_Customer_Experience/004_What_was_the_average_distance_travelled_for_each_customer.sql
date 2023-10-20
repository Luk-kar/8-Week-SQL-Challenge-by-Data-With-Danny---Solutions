-- 4. What was the average distance travelled for each customer?

SELECT
  customer_orders.customer_id,
  ROUND(AVG(runner_orders.distance), 1) AS avg_distance
FROM pizza_runner_v.runner_orders
JOIN pizza_runner_v.customer_orders ON runner_orders.order_id = customer_orders.order_id
WHERE runner_orders.cancellation IS NULL
GROUP BY customer_orders.customer_id
ORDER BY customer_orders.customer_id;

-- | customer_id | avg_distance |
-- |-------------|--------------|
-- | 101         | 20           |
-- | 102         | 16,7        |
-- | 103         | 23,4         |
-- | 104         | 10           |
-- | 105         | 25           |
