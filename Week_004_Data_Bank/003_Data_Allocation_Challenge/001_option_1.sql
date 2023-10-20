/*
Option 1: data is allocated based off the amount of money at the end of the previous month
*/

CREATE TEMP TABLE cash_flow_by_month_by_transaction AS (
  SELECT
      customer_id,
      EXTRACT(YEAR FROM txn_date) AS year,
      EXTRACT(MONTH FROM txn_date) AS month,
      CASE
  		WHEN txn_type = 'deposit' THEN txn_amount
  		WHEN txn_type in ('purchase', 'withdrawal') THEN -(txn_amount)
  		ELSE NULL
  	  END AS cash_flow
  FROM
      data_bank.customer_transactions
);

CREATE TEMP TABLE balance_at_end_of_previous_month AS (
    SELECT distinct on (customer_id, year, month)
        customer_id,
        year,
        month,
        SUM(cash_flow) OVER (
            PARTITION BY customer_id ORDER BY year, month) AS balance
    FROM
        cash_flow_by_month_by_transaction
    ORDER BY
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
  		-- next month
        COALESCE(b.balance, lag(b.balance) OVER (PARTITION BY c.customer_id ORDER BY am.year, am.month)) AS balance -- previous existing month
    FROM
        (SELECT DISTINCT customer_id FROM cash_flow_by_month_by_transaction) c
    CROSS JOIN
        all_months am
    LEFT JOIN
        balance_at_end_of_previous_month b
    ON
        c.customer_id = b.customer_id AND am.year = b.year AND am.month = b.month
)
SELECT * FROM filled_months ORDER BY customer_id, month;

/*
customer_id 	month 	balance
1 	2020-02-01T00:00:00.000Z 	312
1 	2020-03-01T00:00:00.000Z 	312
1 	2020-04-01T00:00:00.000Z 	-640
1 	2020-05-01T00:00:00.000Z 	-640
2 	2020-02-01T00:00:00.000Z 	549
2 	2020-03-01T00:00:00.000Z 	549
2 	2020-04-01T00:00:00.000Z 	610
2 	2020-05-01T00:00:00.000Z 	610
3 	2020-02-01T00:00:00.000Z 	144
3 	2020-03-01T00:00:00.000Z 	-821
3 	2020-04-01T00:00:00.000Z 	-1222
3 	2020-05-01T00:00:00.000Z 	-729
*/