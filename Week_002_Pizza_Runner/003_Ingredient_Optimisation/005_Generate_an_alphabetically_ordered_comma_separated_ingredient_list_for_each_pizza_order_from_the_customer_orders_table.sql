-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients

WITH orders AS (
  SELECT
      customer_orders.pizza_id,
      order_id,
      (
        SELECT array_agg(elem)
        FROM unnest(toppings) AS elem
        WHERE elem NOT IN (SELECT unnest(exclusions))
      ) || extras AS toppings_plus_extras_exclusions,
      extras,
      order_time,
      ROW_NUMBER() OVER (ORDER BY order_id) AS row_number
  FROM pizza_runner_v.customer_orders
  JOIN pizza_runner_v.pizza_recipes ON pizza_recipes.pizza_id = customer_orders.pizza_id
),
counted_toppings_per_pizza AS (
  SELECT
      order_id,
      pizza_id,
      UNNEST(toppings_plus_extras_exclusions) AS topping_id,
      COUNT(*) AS count,
      order_time,
      row_number
  FROM orders
  GROUP BY
      row_number, pizza_id, topping_id, order_id, order_time
)
SELECT
  ct.order_id,
  CONCAT(
      pn.pizza_name,
      ': ',
      STRING_AGG(
          CASE
              WHEN ct.count > 1 THEN CONCAT(ct.count, 'x', pt.topping_name)
              ELSE pt.topping_name
          END,
          ', '
          ORDER BY pt.topping_id
      )
  ) AS pizza,
  ct.order_time
FROM
    counted_toppings_per_pizza AS ct
JOIN pizza_runner_v.pizza_toppings AS pt
ON ct.topping_id = pt.topping_id
JOIN pizza_runner_v.pizza_names AS pn
ON ct.pizza_id = pn.pizza_id
GROUP BY ct.row_number, pn.pizza_name, ct.order_id, ct.order_time
ORDER BY
row_number
;

-- | order_id | pizza                                                                               | order_time               |
-- |----------|-------------------------------------------------------------------------------------|--------------------------|
-- | 1        | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   | 2021-01-01T18:05:02.000Z |
-- | 2        | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   | 2021-01-01T19:00:52.000Z |
-- | 3        | Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce              | 2021-01-02T23:51:23.000Z |
-- | 3        | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   | 2021-01-02T23:51:23.000Z |
-- | 4        | Meatlovers: Bacon, BBQ Sauce, Beef, Chicken, Mushrooms, Pepperoni, Salami           | 2021-01-04T13:23:46.000Z |
-- | 4        | Meatlovers: Bacon, BBQ Sauce, Beef, Chicken, Mushrooms, Pepperoni, Salami           | 2021-01-04T13:23:46.000Z |
-- | 4        | Vegetarian: Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce                      | 2021-01-04T13:23:46.000Z |
-- | 5        | Meatlovers: 2xBacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami | 2021-01-08T21:00:29.000Z |
-- | 6        | Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce              | 2021-01-08T21:03:13.000Z |
-- | 7        | Vegetarian: Bacon, Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce       | 2021-01-08T21:20:29.000Z |
-- | 8        | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   | 2021-01-09T23:54:33.000Z |
-- | 9        | Meatlovers: 2xBacon, BBQ Sauce, Beef, 2xChicken, Mushrooms, Pepperoni, Salami       | 2021-01-10T11:22:59.000Z |
-- | 10       | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   | 2021-01-11T18:34:49.000Z |
-- | 10       | Meatlovers: 2xBacon, Beef, 2xCheese, Chicken, Pepperoni, Salami                     | 2021-01-11T18:34:49.000Z |
