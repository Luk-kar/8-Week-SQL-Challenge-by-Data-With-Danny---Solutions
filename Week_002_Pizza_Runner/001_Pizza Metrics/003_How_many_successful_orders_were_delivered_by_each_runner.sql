-- 3. How many successful orders were delivered by each runner?

SELECT
	runner_id,
	COUNT(order_id) AS successful_delivery
FROM pizza_runner_v.runner_orders
WHERE cancellation IS NULL
GROUP BY runner_id
ORDER BY successful_delivery
;

-- runner_id 	received_orders
-- 1 	4
-- 2 	3
-- 3 	1