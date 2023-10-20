/*
For each month - how many Data Bank customers make more 
than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
*/

WITH transactions_by_month_by_id_by_type AS (
  SELECT
    EXTRACT(YEAR FROM txn_date) AS year,
    EXTRACT(MONTH FROM txn_date) AS month,
    customer_id,
    CASE 
    WHEN 
      COUNT(*) FILTER (WHERE txn_type = 'deposit') > 1 AND 
      COUNT(*) FILTER (WHERE txn_type IN ('purchase', 'withdrawal')) > 0 
    THEN 1
    ELSE 0
    END AS deposit_and_withdrawal_or_purchase
  FROM
    data_bank.customer_transactions
  GROUP BY
    year, month, customer_id
)
SELECT
	year, 
  month,
  SUM(deposit_and_withdrawal_or_purchase) AS clients_deposit_and_withdrawal_or_purchase
FROM
    transactions_by_month_by_id_by_type
GROUP BY
    year, month
ORDER BY
    year, month
;

/*
| year | month | clients_deposit_and_withdrawal_or_purchase |
|------|-------|--------------------------------------------|
| 2020 | 1     | 168                                        |
| 2020 | 2     | 181                                        |
| 2020 | 3     | 192                                        |
| 2020 | 4     | 70                                         |
*/

WITH cte_customer_months AS (
  SELECT
    DATE_TRUNC('mon', txn_date)::DATE AS month,
    customer_id,
    SUM(CASE WHEN txn_type = 'deposit' THEN 1 ELSE 0 END) AS deposit_count,
    SUM(CASE WHEN txn_type = 'purchase' THEN 1 ELSE 0 END) AS purchase_count,
    SUM(CASE WHEN txn_type = 'withdrawal' THEN 1 ELSE 0 END) AS withdrawal_count
  FROM data_bank.customer_transactions
  GROUP BY customer_id, month
)
SELECT
  month,
  COUNT(DISTINCT customer_id) AS customer_count
FROM cte_customer_months
WHERE deposit_count > 1 AND (
  purchase_count > 0 OR withdrawal_count > 0
)
GROUP BY month
ORDER BY month;