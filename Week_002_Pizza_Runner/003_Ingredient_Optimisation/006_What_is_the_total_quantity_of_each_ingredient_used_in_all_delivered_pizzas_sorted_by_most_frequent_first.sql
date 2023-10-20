-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

WITH orders AS (
  SELECT
    (
      SELECT array_agg(elem)
      FROM unnest(toppings) AS elem
      WHERE elem NOT IN (SELECT unnest(exclusions))
    ) || extras AS toppings_plus_extras_exclusions
  FROM pizza_runner_v.customer_orders
  LEFT JOIN pizza_runner_v.runner_orders ON runner_orders.order_id = customer_orders.order_id
  LEFT JOIN pizza_runner_v.pizza_recipes ON pizza_recipes.pizza_id = customer_orders.pizza_id
  WHERE runner_orders.cancellation IS NULL
),
counted_toppings_per_pizza AS (
  SELECT
      UNNEST(toppings_plus_extras_exclusions) AS topping_id,
      COUNT(*) AS count
  FROM orders
  GROUP BY
      topping_id
)
SELECT
  pt.topping_name,
  count
FROM counted_toppings_per_pizza AS ct
JOIN pizza_runner_v.pizza_toppings AS pt ON ct.topping_id = pt.topping_id
ORDER BY count DESC
;

-- | topping_name | count |
-- |--------------|-------|
-- | Bacon        | 12    |
-- | Mushrooms    | 11    |
-- | Cheese       | 10    |
-- | Pepperoni    | 9     |
-- | Salami       | 9     |
-- | Chicken      | 9     |
-- | Beef         | 9     |
-- | BBQ Sauce    | 8     |
-- | Tomato Sauce | 3     |
-- | Onions       | 3     |
-- | Peppers      | 3     |
-- | Tomatoes     | 3     |
