-- 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras 
-- and each runner is paid $0.30 per kilometre traveled - 
-- how much money does Pizza Runner have left over after these deliveries?

WITH orders AS (
    SELECT
        customer_orders.order_id,
        runner_orders.distance,
        CASE
            WHEN customer_orders.pizza_id = 1 THEN 12
            ELSE 10
        END AS price
    FROM
        pizza_runner_v.customer_orders
    JOIN pizza_runner_v.runner_orders
    ON runner_orders.order_id = customer_orders.order_id
    WHERE runner_orders.cancellation IS NULL
),
earned_by_order AS (
  SELECT 
    order_id,
    SUM(price),
    distance
  FROM
    orders
  GROUP BY
    order_id, distance
)
SELECT
  SUM(sum) - (SUM(distance) * 0.3) AS total_earnings 
FROM earned_by_order
;

-- total_earnings
-- 94.44