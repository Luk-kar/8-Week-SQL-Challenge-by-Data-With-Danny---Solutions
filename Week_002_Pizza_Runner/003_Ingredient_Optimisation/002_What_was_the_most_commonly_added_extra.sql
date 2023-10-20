-- 2. What was the most commonly added extra?

WITH most_commonly_added_extra AS (
  SELECT
    pizza_toppings.topping_name AS extras,
    COUNT(pizza_toppings.topping_id) AS occurrence,
    RANK() OVER (ORDER BY COUNT(pizza_toppings.topping_id) DESC) AS ranked
  FROM pizza_runner_v.customer_orders
  JOIN pizza_runner_v.pizza_toppings ON pizza_toppings.topping_id = ANY(customer_orders.extras)
  GROUP BY pizza_toppings.topping_name
)
SELECT
  extras,
  occurrence
FROM most_commonly_added_extra
WHERE ranked = 1
;

-- extras 	occurrence
-- Bacon 	4