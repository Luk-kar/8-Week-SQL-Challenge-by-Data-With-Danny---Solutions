-- 6. What was the maximum number of pizzas delivered in a single order?

WITH ranked_orders AS (
  SELECT
    runner_orders.order_id,
    COUNT(customer_orders.pizza_id) AS delivered_pizzas,
    RANK() OVER (ORDER BY COUNT(customer_orders.pizza_id) DESC, runner_orders.order_id) AS rank
  FROM pizza_runner.runner_orders AS runner_orders
  INNER JOIN pizza_runner.customer_orders AS customer_orders ON runner_orders.order_id = customer_orders.order_id
  WHERE runner_orders.cancellation IS NULL
  GROUP BY runner_orders.order_id
)

SELECT
  order_id,
  delivered_pizzas
FROM ranked_orders
WHERE rank = 1;

-- | order_id | delivered_pizzas |
-- |----------|------------------|
-- | 4        | 3                |
