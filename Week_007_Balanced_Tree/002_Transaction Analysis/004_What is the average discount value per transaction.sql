-- 4. What is the average discount value per transaction?

WITH unique_product_per_txn AS (
    SELECT
        txn_id,
        SUM((qty * price)::DECIMAL * (discount::DECIMAL / 100)) AS discount_value
    FROM balanced_tree.sales
    GROUP BY txn_id
)
SELECT
    ROUND(AVG(discount_value), 2) AS average_discount_value_per_transaction
FROM unique_product_per_txn
;

/*
| average_discount_value_per_transaction |
|----------------------------------------|
| 62.49                                  |
*/