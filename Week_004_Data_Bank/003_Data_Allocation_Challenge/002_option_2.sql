/*
Option 2: data is allocated on the average amount of money 
kept in the account in the previous 30 days
*/

CREATE TEMP TABLE cash_flow_by_month_by_transaction AS (
  SELECT
      customer_id,
      EXTRACT(month FROM txn_date) AS month,
      EXTRACT(year FROM txn_date) AS year,
      txn_date,
      CASE
  		WHEN txn_type = 'deposit' THEN txn_amount
  		WHEN txn_type in ('purchase', 'withdrawal') THEN -(txn_amount)
  		ELSE NULL
  	  END AS cash_flow
  FROM
      data_bank.customer_transactions
);

CREATE TEMP TABLE balance_transaction AS (
    SELECT distinct on (customer_id, txn_date)
        customer_id,
        year,
        month,
        SUM(cash_flow) OVER (
            PARTITION BY customer_id ORDER BY txn_date) AS balance
    FROM
        cash_flow_by_month_by_transaction
    ORDER BY
        customer_id, txn_date
);

CREATE TEMP TABLE balance_average_previous_30_days AS (
    SELECT
        customer_id,
        year,
        month,
        SUM(balance) AS balance,
        ROUND(AVG(balance)) AS balance_average
    FROM
  		balance_transaction
    GROUP BY
        customer_id, year, month
);

WITH RECURSIVE all_months AS (
    SELECT DISTINCT year, month
    FROM cash_flow_by_month_by_transaction
),
filled_months AS (
    SELECT
        c.customer_id,
        CONCAT(am.year, '-', LPAD((am.month)::TEXT, 2, '0'), '-01')::DATE + INTERVAL '1 month' AS month,
        COALESCE(b.balance, lag(b.balance) OVER (PARTITION BY c.customer_id ORDER BY am.year, am.month)) AS last_balance,
        COALESCE(b.balance_average, lag(b.balance) OVER (PARTITION BY c.customer_id ORDER BY am.year, am.month)) AS last_balance_average
    FROM
        (SELECT DISTINCT customer_id FROM cash_flow_by_month_by_transaction) c
    CROSS JOIN
        all_months am
    LEFT JOIN
        balance_average_previous_30_days b
    ON
        c.customer_id = b.customer_id AND am.year = b.year AND am.month = b.month
)
SELECT * FROM filled_months ORDER BY customer_id, month;

/*
customer_id 	month 	last_balance 	last_balance_average
1 	2020-02-01T00:00:00.000Z 	312 	312
1 	2020-03-01T00:00:00.000Z 	312 	312
1 	2020-04-01T00:00:00.000Z 	-916 	-305
1 	2020-05-01T00:00:00.000Z 	-916 	-916
2 	2020-02-01T00:00:00.000Z 	549 	549
2 	2020-03-01T00:00:00.000Z 	549 	549
2 	2020-04-01T00:00:00.000Z 	610 	610
2 	2020-05-01T00:00:00.000Z 	610 	610
*/