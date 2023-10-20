-- 5. What is the percentage split of all transactions for members vs non-members?

WITH is_membership_transactions AS (
    SELECT
        txn_id,
        MAX(CASE WHEN member = 't' THEN 1 ELSE 0 END) AS is_membership
    FROM balanced_tree.sales
    GROUP BY txn_id
)
SELECT
    ROUND(SUM(is_membership)::DECIMAL / COUNT(*) * 100, 2) AS "membership_%",
    ROUND(SUM(CASE WHEN is_membership = 0 THEN 1 END)::DECIMAL / COUNT(*) * 100, 2) AS "no_membership_%"
FROM is_membership_transactions
;

/*
| membership_%  | no_membership_% |
|---------------|-----------------|
| 60.20         | 39.80           |
*/

WITH cte_member_transactions AS (
  SELECT
    member,
    COUNT(DISTINCT txn_id) AS transactions
  FROM balanced_tree.sales
  GROUP BY member
)
SELECT
  member,
  transactions,
  ROUND(transactions::NUMERIC / (SELECT COUNT(DISTINCT txn_id) FROM balanced_tree.sales) * 100, 2) AS percentage
FROM cte_member_transactions
ORDER BY percentage DESC
;

/*
| member  | transactions  | percentage |
|---------|---------------|------------|
| true    | 1505          | 60.20      |
| false   | 995           | 39.80      |
*/