-- 3. Generate an order item for each record in the customers_orders table in the format of one of the following:

  -- Meat Lovers
  -- Meat Lovers - Exclude Beef
  -- Meat Lovers - Extra Bacon
  -- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

WITH orders AS (
  SELECT
    pizza_names.pizza_name AS pizza,
    customer_orders.order_id,
    customer_orders.customer_id,
    customer_orders.order_time,
    ARRAY_TO_STRING(ARRAY(SELECT topping_name FROM pizza_runner_v.pizza_toppings WHERE topping_id = ANY(customer_orders.extras)), ', ') AS extras,
    ARRAY_TO_STRING(ARRAY(SELECT topping_name FROM pizza_runner_v.pizza_toppings WHERE topping_id = ANY(customer_orders.exclusions)), ', ') AS exclusions
  FROM pizza_runner_v.customer_orders AS customer_orders
  JOIN pizza_runner_v.pizza_names AS pizza_names ON pizza_names.pizza_id = customer_orders.pizza_id
)
SELECT
   order_id,
   customer_id,
	 CONCAT(
	  CASE
      WHEN pizza = 'Meatlovers' THEN ' Meat Lovers' ELSE pizza END, 
    CASE
    	WHEN exclusions != '' THEN ' - Exclude ' ELSE '' END, 
    exclusions, 
    CASE
    	WHEN extras != '' THEN ' - Extra ' ELSE '' END, 
    extras
    )
   AS pizza,
   order_time
FROM orders

-- | order_id | customer_id | pizza                                                             | order_time               |
-- |----------|-------------|-------------------------------------------------------------------|--------------------------|
-- | 10       | 104         |  Meat Lovers - Exclude BBQ Sauce, Mushrooms - Extra Bacon, Cheese | 2021-01-11T18:34:49.000Z |
-- | 10       | 104         |  Meat Lovers                                                      | 2021-01-11T18:34:49.000Z |
-- | 9        | 103         |  Meat Lovers - Exclude Cheese - Extra Bacon, Chicken              | 2021-01-10T11:22:59.000Z |
-- | 8        | 102         |  Meat Lovers                                                      | 2021-01-09T23:54:33.000Z |
-- | 5        | 104         |  Meat Lovers - Extra Bacon                                        | 2021-01-08T21:00:29.000Z |
-- | 4        | 103         |  Meat Lovers - Exclude Cheese                                     | 2021-01-04T13:23:46.000Z |
-- | 4        | 103         |  Meat Lovers - Exclude Cheese                                     | 2021-01-04T13:23:46.000Z |
-- | 3        | 102         |  Meat Lovers                                                      | 2021-01-02T23:51:23.000Z |
-- | 2        | 101         |  Meat Lovers                                                      | 2021-01-01T19:00:52.000Z |
-- | 1        | 101         |  Meat Lovers                                                      | 2021-01-01T18:05:02.000Z |
-- | 7        | 105         | Vegetarian - Extra Bacon                                          | 2021-01-08T21:20:29.000Z |
-- | 6        | 101         | Vegetarian                                                        | 2021-01-08T21:03:13.000Z |
-- | 4        | 103         | Vegetarian - Exclude Cheese                                       | 2021-01-04T13:23:46.000Z |
-- | 3        | 102         | Vegetarian                                                        | 2021-01-02T23:51:23.000Z |
