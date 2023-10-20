/*
Comparing the closing balance of a customer’s first month and the closing balance from their second month, what percentage of customers:

- Have a negative first month balance?
- Have a positive first month balance?
- Increase their opening month’s positive closing balance by more than 5% in the following month?
- Reduce their opening month’s positive closing balance by more than 5% in the following month?
- Move from a positive balance in the first month to a negative balance in the second month?

*/

WITH cte_balances AS (
  SELECT
    customer_id,
    txn_date,
    DATE_TRUNC('mon', txn_date)::DATE AS month,
    SUM(
      CASE
        WHEN txn_type in ('purchase', 'withdrawal') THEN -txn_amount
        ELSE txn_amount
        END
    ) OVER (PARTITION BY customer_id ORDER BY txn_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS balance
  FROM data_bank.customer_transactions
  ORDER BY customer_id, month
),
cte_monthly_balances AS (
  SELECT DISTINCT
  customer_id, 
  month, 
  LAST_VALUE(balance) OVER (
  PARTITION BY customer_id, DATE_TRUNC('mon', txn_date)::DATE
  ORDER BY txn_date
  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
) AS balance FROM cte_balances
),
month_diff AS (
  SELECT
    customer_id,
    month,
    balance,
    (DATE_PART('month', AGE(LEAD(month) OVER (PARTITION BY customer_id ORDER BY month), month)) - 1)::INTEGER AS month_diff
  FROM cte_monthly_balances
),
missing_months AS (
  SELECT
    customer_id,
    (month + GENERATE_SERIES(0, month_diff) * INTERVAL '1 month')::DATE AS month,
    balance
  FROM month_diff
),
union_output AS (
  SELECT customer_id, month, balance FROM cte_monthly_balances
UNION
  SELECT * FROM missing_months
),
cte_monthly_aggregates AS (
  SELECT
    customer_id,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY month) AS month_number,
    balance,
    LAG(balance) OVER (
      PARTITION BY customer_id
      ORDER BY month
    ) AS previous_balance
  FROM union_output
),
cte_calculations AS (
  SELECT
    COUNT(DISTINCT customer_id) AS customer_count,
    SUM(CASE WHEN month_number = 1 AND balance > 0 THEN 1 ELSE 0 END) AS positive_first_month,
    SUM(CASE WHEN month_number = 1 AND balance < 0 THEN 1 ELSE 0 END) AS negative_first_month,
    SUM(
      CASE
        WHEN month_number = 2 AND previous_balance IS NOT NULL AND balance > 1.05 * previous_balance THEN 1
        ELSE 0
      END
    ) AS increase_count,
    SUM(
      CASE
        WHEN month_number = 2 AND previous_balance IS NOT NULL AND balance < 0.95 * previous_balance THEN 1
        ELSE 0
      END
    ) AS decrease_count,
    SUM(
      CASE
        WHEN month_number = 2 AND previous_balance IS NOT NULL AND previous_balance > 0 AND balance < 0 THEN 1
        ELSE 0
      END
    ) AS negative_count
  FROM cte_monthly_aggregates
  WHERE month_number IN (1, 2)
)
SELECT
  ROUND(100 * positive_first_month / customer_count, 2) AS positive_pc,
  ROUND(100 * negative_first_month / customer_count, 2) AS negative_pc,
  ROUND(100 * increase_count / customer_count, 2) AS increase_pc,
  ROUND(100 * decrease_count / customer_count, 2) AS decrease_pc,
  ROUND(100 * negative_count / customer_count, 2) AS negative_balance_pc
FROM cte_calculations;

/*
| positive_pc | negative_pc | increase_pc | decrease_pc | negative_balance_pc |
|-------------|-------------|-------------|-------------|---------------------|
| 68          | 31          | 38          | 53          | 22                  |
*/