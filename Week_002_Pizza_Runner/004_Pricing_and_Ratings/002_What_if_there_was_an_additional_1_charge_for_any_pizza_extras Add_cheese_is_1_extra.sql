-- 2. What if there was an additional $1 charge for any pizza extras?

WITH earnings AS (
    SELECT
        customer_orders.pizza_id,
        CASE
            WHEN customer_orders.pizza_id = 1 THEN 12
            ELSE 10
        END AS pizza_price,
        CASE
            WHEN customer_orders.extras IS NOT NULL
            THEN ARRAY_LENGTH(customer_orders.extras, 1)
            ELSE 0
        END AS extras_price
    FROM
        pizza_runner_v.customer_orders
    JOIN pizza_runner_v.runner_orders
    ON runner_orders.order_id = customer_orders.order_id
    WHERE runner_orders.cancellation IS NULL
)
SELECT
    SUM(pizza_price) + SUM(extras_price) AS total_earnings
FROM
    earnings;

-- total_earnings
-- 142