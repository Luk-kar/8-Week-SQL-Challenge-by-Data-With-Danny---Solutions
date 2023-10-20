-- 2. How many unique customer orders were made?

SELECT
	COUNT(DISTINCT customer_id) AS total_customers
FROM pizza_runner_v.customer_orders

-- total_customers 5