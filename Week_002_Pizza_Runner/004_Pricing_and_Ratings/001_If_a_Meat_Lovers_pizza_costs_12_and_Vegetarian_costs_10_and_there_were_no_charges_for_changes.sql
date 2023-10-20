-- 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

SELECT
  SUM(
    CASE
      WHEN pizza_id = 1 THEN 12
      WHEN pizza_id = 2 THEN 10
    END
  ) AS revenue
FROM pizza_runner_v.customer_orders
JOIN pizza_runner_v.runner_orders
  ON runner_orders.order_id = customer_orders.order_id
WHERE runner_orders.cancellation IS NULL
;

-- revenue
-- 138
