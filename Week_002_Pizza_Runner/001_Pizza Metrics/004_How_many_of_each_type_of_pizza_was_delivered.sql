-- 4. How many of each type of pizza was delivered?

SELECT
	pizza_names.pizza_name,
  COUNT(customer_orders.pizza_id) orders_delivered
FROM pizza_runner_v.runner_orders AS runner_orders
INNER JOIN pizza_runner_v.customer_orders AS customer_orders ON customer_orders.order_id = runner_orders.order_id
INNER JOIN pizza_runner_v.pizza_names AS pizza_names ON pizza_names.pizza_id = customer_orders.pizza_id
WHERE
runner_orders.cancellation IS NULL
GROUP BY pizza_names.pizza_name
ORDER BY orders_delivered DESC

-- pizza_id 	received_orders
-- Meatlovers 	9
-- Vegetarian 	3