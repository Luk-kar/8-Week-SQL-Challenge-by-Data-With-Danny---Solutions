-- 6. What is the average revenue for member transactions and non-member transactions?

WITH revenue_per_transaction AS (
    SELECT
        txn_id,
  		member,
        SUM(qty * price) AS revenue
    FROM balanced_tree.sales
    GROUP BY txn_id, member
)
SELECT
    member,
    ROUND(AVG(revenue), 2) AS average_revenue
FROM revenue_per_transaction
GROUP BY member
ORDER BY average_revenue DESC
;

/*
| member  | average_revenue |
|---------|-----------------|
| true    | 516.27          |
| false   | 515.04          |
*/