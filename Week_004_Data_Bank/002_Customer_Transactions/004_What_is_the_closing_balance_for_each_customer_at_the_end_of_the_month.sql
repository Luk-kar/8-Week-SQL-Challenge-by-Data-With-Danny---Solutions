/*
What is the closing balance for each customer at the end of the month?
*/

WITH balance AS (
  SELECT
      customer_id,
      DATE_TRUNC('month', txn_date) AS month,
      SUM(
        CASE
      		WHEN txn_type = 'deposit' THEN txn_amount
      		WHEN txn_type in ('purchase', 'withdrawal') THEN -txn_amount
      		ELSE NULL
    	  END
      ) OVER (PARTITION BY customer_id ORDER BY txn_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS balance,
      ROW_NUMBER() OVER (PARTITION BY customer_id, TO_CHAR(txn_date, 'YYYY-MM') ORDER BY txn_date DESC) AS transaction_order_by_month_descending
  FROM
      data_bank.customer_transactions
),
balance_at_the_end_of_month AS (
  SELECT customer_id, month, balance FROM balance WHERE transaction_order_by_month_descending = 1
),
month_diff AS (
  SELECT
    customer_id,
    month,
    balance,
    (DATE_PART('month', AGE(LEAD(month) OVER (PARTITION BY customer_id ORDER BY month), month)) - 1)::INTEGER AS month_diff
  FROM balance_at_the_end_of_month
),
missing_months AS (
  SELECT
    customer_id,
    (month + GENERATE_SERIES(0, month_diff) * INTERVAL '1 month')::DATE AS month,
    balance
  FROM month_diff
),
union_output AS (
  SELECT customer_id, month, balance FROM balance_at_the_end_of_month
UNION
  SELECT * FROM missing_months
)
SELECT
  *,
  ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY month) AS client_month
FROM union_output
ORDER BY customer_id, month
LIMIT 20


/*
| customer_id | month   | balance | client_month |
|-------------|---------|---------|--------------|
| 1           | 2020-01 | 312     | 1            |
| 1           | 2020-02 | 312     | 2            |
| 1           | 2020-03 | -640    | 3            |
| 2           | 2020-01 | 549     | 1            |
| 2           | 2020-02 | 549     | 2            |
| 2           | 2020-03 | 610     | 3            |
| 3           | 2020-01 | 144     | 1            |
| 3           | 2020-02 | -821    | 2            |
| 3           | 2020-03 | -1222   | 3            |
| 3           | 2020-04 | -729    | 4            |
| 4           | 2020-01 | 848     | 1            |
| 4           | 2020-02 | 848     | 2            |
| 4           | 2020-03 | 655     | 3            |
| 5           | 2020-01 | 954     | 1            |
| 5           | 2020-02 | 954     | 2            |
| 5           | 2020-03 | -1923   | 3            |
| 5           | 2020-04 | -2413   | 4            |
| 6           | 2020-01 | 733     | 1            |
| 6           | 2020-02 | 117     | 2            |
| 6           | 2020-03 | 340     | 3            |
*/ 

