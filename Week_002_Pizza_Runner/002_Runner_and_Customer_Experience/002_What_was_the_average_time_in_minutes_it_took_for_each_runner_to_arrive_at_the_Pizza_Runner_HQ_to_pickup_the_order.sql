-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

WITH cte_pickup_minutes AS (
  SELECT DISTINCT
    t1.order_id,
    DATE_PART('minutes', AGE(t1.pickup_time, t2.order_time))::INTEGER AS pickup_minutes
  FROM pizza_runner_v.runner_orders AS t1
  INNER JOIN pizza_runner_v.customer_orders AS t2
    ON t1.order_id = t2.order_id
  WHERE t1.cancellation IS NULL
)
SELECT
  ROUND(AVG(pickup_minutes), 3) AS avg_pickup_minutes
FROM cte_pickup_minutes
;

-- avg_pickup_minutes
-- 15.625
