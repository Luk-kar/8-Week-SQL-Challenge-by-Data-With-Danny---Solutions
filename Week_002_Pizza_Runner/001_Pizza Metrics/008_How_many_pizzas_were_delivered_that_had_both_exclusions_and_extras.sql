-- 8. How many pizzas were delivered that had both exclusions and extras?

SELECT
  COUNT(CASE WHEN ARRAY_LENGTH(customer_orders.extras, 1) > 0 AND ARRAY_LENGTH(customer_orders.exclusions, 1) > 0 THEN 1 END) AS number_of_pizzas_with_extras_and_exclusions
FROM pizza_runner_v.runner_orders
INNER JOIN pizza_runner_v.customer_orders ON runner_orders.order_id = customer_orders.order_id
WHERE
runner_orders.cancellation IS NULL
;

-- | number_of_pizzas_with_extras_and_exclusions |
-- |---------------------------------------------|
-- | 1                                           |
