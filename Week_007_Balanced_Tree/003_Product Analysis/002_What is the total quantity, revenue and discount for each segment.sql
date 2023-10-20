-- 2. What is the total quantity, revenue and discount for each segment?

WITH txn_metrics AS (
    SELECT
        segment_id,
        segment_name,
        qty,
        discount AS "discount_%",
        ROUND((qty * sales.price)::DECIMAL * (sales.discount::DECIMAL / 100), 2) AS discount_value,
        (qty * sales.price) AS revenue
    FROM balanced_tree.sales
    LEFT JOIN balanced_tree.product_details ON sales.prod_id = product_details.product_id
)
SELECT
    segment_id,
    segment_name,
    SUM(revenue) AS revenue,
    SUM(qty) AS quantity,
    ROUND(AVG("discount_%"), 2) AS "avg_discount_%",
    SUM(discount_value) AS discount_value
FROM txn_metrics
GROUP BY segment_name, segment_id
ORDER BY revenue DESC, quantity DESC, "avg_discount_%", discount_value
LIMIT 10
;

/*
| segment_id  | segment_name  | revenue  | quantity  | avg_discount_%  | discount_value |
|-------------|---------------|----------|-----------|-----------------|----------------|
| 5           | Shirt         | 406143   | 11265     | 12.19           | 49594.27       |
| 4           | Jacket        | 366983   | 11385     | 12.05           | 44277.46       |
| 6           | Socks         | 307977   | 11217     | 12.02           | 37013.44       |
| 3           | Jeans         | 208350   | 11349     | 12.16           | 25343.97       |
*/