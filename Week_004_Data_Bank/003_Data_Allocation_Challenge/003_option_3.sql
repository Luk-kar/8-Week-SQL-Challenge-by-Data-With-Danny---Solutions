/*
Option 3: data is updated real-time
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
  	  END AS cash_flow,
  	  txn_type
  FROM
      data_bank.customer_transactions
);

CREATE TEMP TABLE balance_at_after_each_transaction AS (
    SELECT
        customer_id,
        txn_date,
  		cash_flow,
  		txn_type,
        SUM(cash_flow) OVER (
            PARTITION BY customer_id ORDER BY txn_date) AS balance
    FROM
        cash_flow_by_month_by_transaction
    ORDER BY
        customer_id, txn_date
);

SELECT * FROM balance_at_after_each_transaction ORDER BY customer_id, txn_date;

/*
customer_id 	txn_date 	cash_flow 	txn_type 	balance
1 	2020-01-02T00:00:00.000Z 	312 	deposit 	312
1 	2020-03-05T00:00:00.000Z 	-612 	purchase 	-300
1 	2020-03-17T00:00:00.000Z 	324 	deposit 	24
1 	2020-03-19T00:00:00.000Z 	-664 	purchase 	-640
2 	2020-01-03T00:00:00.000Z 	549 	deposit 	549
2 	2020-03-24T00:00:00.000Z 	61 	deposit 	610
*/