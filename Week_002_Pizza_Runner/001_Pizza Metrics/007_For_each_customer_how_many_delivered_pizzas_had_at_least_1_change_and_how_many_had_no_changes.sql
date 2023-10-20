-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT
	customer_orders.customer_id,
  COUNT(CASE WHEN ARRAY_LENGTH(customer_orders.extras, 1) > 0 OR ARRAY_LENGTH(customer_orders.exclusions, 1) > 0 THEN 1 END) AS orders_with_changes,
  COUNT(CASE WHEN customer_orders.extras IS NULL AND customer_orders.exclusions IS NULL THEN 1 END) AS orders_without_changes
FROM pizza_runner_v.runner_orders AS runner_orders
INNER JOIN pizza_runner_v.customer_orders AS customer_orders ON runner_orders.order_id = customer_orders.order_id
WHERE
runner_orders.cancellation IS NULL
GROUP BY customer_orders.customer_id
ORDER BY customer_orders.customer_id;

-- | customer_id | orders_with_changes | orders_without_changes |
-- |-------------|---------------------|------------------------|
-- | 101         | 0                   | 2                      |
-- | 102         | 0                   | 3                      |
-- | 103         | 3                   | 0                      |
-- | 104         | 2                   | 1                      |
-- | 105         | 1                   | 0                      |
