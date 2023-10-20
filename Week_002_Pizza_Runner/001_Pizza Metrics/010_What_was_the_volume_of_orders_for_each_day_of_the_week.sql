-- 10. What was the volume of orders for each day of the week?

SELECT
  TO_CHAR(order_time, 'Day') AS weekday,
  COUNT(*) AS total_orders
FROM pizza_runner_v.customer_orders
GROUP BY weekday, DATE_PART('dow', order_time)
ORDER BY DATE_PART('dow', order_time)
;

-- | weekday | total_orders |
-- |---------|--------------|
-- | Sunday       | 1            |
-- | Monday       | 5            |
-- | Friday       | 5            |
-- | Saturday       | 3            |