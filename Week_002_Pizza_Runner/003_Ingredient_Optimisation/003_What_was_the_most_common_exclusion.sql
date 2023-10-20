-- 3. What was the most common exclusion?

SELECT
  pizza_toppings.topping_name AS exclusion,
  COUNT(pizza_toppings.topping_id) AS occurrence
FROM pizza_runner_v.customer_orders
JOIN pizza_runner_v.pizza_toppings ON pizza_toppings.topping_id = ANY(customer_orders.exclusions)
GROUP BY pizza_toppings.topping_name
ORDER BY occurrence DESC;

-- exclusion 	occurrence
-- Cheese 	    4
-- Mushrooms 	1
-- BBQ Sauce 	1