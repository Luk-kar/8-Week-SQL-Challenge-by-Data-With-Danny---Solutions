-- 3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?

WITH unique_product_per_txn AS (
    SELECT
        txn_id,
        SUM(qty * price) AS revenue
    FROM balanced_tree.sales
    GROUP BY txn_id
)
SELECT
    '25th percentile' AS percentile,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY revenue) AS revenue
FROM unique_product_per_txn

UNION ALL

SELECT
    '50th percentile' AS percentile,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY revenue) AS revenue
FROM unique_product_per_txn

UNION ALL

SELECT
    '75th percentile' AS percentile,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY revenue) AS revenue
FROM unique_product_per_txn
;

/*
| percentile       | revenue |
|------------------|---------|
| 25th percentile  | 375.75  |
| 50th percentile  | 509.5   |
| 75th percentile  | 647     |
*/