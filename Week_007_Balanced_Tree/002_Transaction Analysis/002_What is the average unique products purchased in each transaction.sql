-- 2. What is the average unique products purchased in each transaction?

WITH unique_product_per_txn AS (
    SELECT
        txn_id,
        COUNT(DISTINCT prod_id) AS unique_products 
    FROM balanced_tree.sales
    GROUP BY txn_id
)
SELECT
   ROUND(AVG(unique_products), 1) AS average_unique_products_purchased_per_transaction
FROM unique_product_per_txn
;

/*
| average_unique_products_purchased_per_transaction |
|---------------------------------------------------|
| 6.00                                              |
*/