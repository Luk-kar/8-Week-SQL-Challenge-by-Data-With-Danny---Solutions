-- 5. How many Vegetarian and Meatlovers were ordered by each customer?

SELECT
  customer_id,
  SUM(CASE WHEN pizza_id = 1 THEN 1 ELSE 0 END) AS meatlovers,
  SUM(CASE WHEN pizza_id = 2 THEN 1 ELSE 0 END) AS vegetarian
FROM pizza_runner_v.customer_orders
INNER JOIN pizza_runner_v.runner_orders ON runner_orders.order_id = customer_orders.order_id
WHERE
	cancellation IS NULL
GROUP BY customer_id
ORDER BY customer_id;

-- | customer_id | meatlovers | vegetarian |
-- |-------------|------------|------------|
-- | 101         | 2          | 0          |
-- | 102         | 2          | 1          |
-- | 103         | 2          | 1          |
-- | 104         | 3          | 0          |
-- | 105         | 0          | 1          |
