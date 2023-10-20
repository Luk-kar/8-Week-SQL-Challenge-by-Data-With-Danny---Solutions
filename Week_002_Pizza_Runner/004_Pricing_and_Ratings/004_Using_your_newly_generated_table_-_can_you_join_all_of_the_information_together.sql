-- 4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?

--     customer_id
--     order_id
--     runner_id
--     rating
--     order_time
--     pickup_time
--     Time between order and pickup
--     Delivery duration
--     Average speed
--     Total number of pizzas

SELECT DISTINCT
    customer_orders.customer_id,
    customer_orders.order_id,
    runner_orders.runner_id,
    runner_ratings.rating,
    customer_orders.order_time,
    runner_orders.pickup_time,
    runner_orders.pickup_time - customer_orders.order_time AS order_receiving_time,
    runner_orders.duration AS delivery_time,
    ROUND((distance / (EXTRACT(EPOCH FROM duration)::NUMERIC / 3600)), 1) AS avg_speed,
    COUNT(customer_orders.pizza_id) OVER (PARTITION BY runner_orders.order_id) AS pizzas_delivered_total
FROM
    pizza_runner_v.customer_orders
    LEFT JOIN pizza_runner_v.runner_orders ON runner_orders.order_id = customer_orders.order_id
    LEFT JOIN pizza_runner.runner_ratings ON runner_ratings.order_id = customer_orders.order_id
WHERE
    runner_orders.cancellation IS NULL;

-- | customer_id | order_id | runner_id | rating | order_time               | pickup_time              | order_receiving_time | delivery_time   | avg_speed | pizzas_delivered_total |
-- |-------------|----------|-----------|--------|--------------------------|--------------------------|----------------------|-----------------|-----------|------------------------|
-- | 101         | 1        | 1         | 1      | 2021-01-01T18:05:02.000Z | 2021-01-01T18:15:34.000Z | { "minutes": 10, "seconds": 32 }      | { "minutes": 32 } | 37,5      | 1                      |
-- | 101         | 2        | 1         |        | 2021-01-01T19:00:52.000Z | 2021-01-01T19:10:54.000Z | { "minutes": 10, "seconds": 2 }      | { "minutes": 27 } | 44,4      | 1                      |
-- ...