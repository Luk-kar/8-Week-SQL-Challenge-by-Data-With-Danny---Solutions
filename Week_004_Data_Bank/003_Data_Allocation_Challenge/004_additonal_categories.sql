/*
For this multi-part challenge question - 
you have been requested to generate the following data elements 
to help the Data Bank team estimate how much data will need to be provisioned for each option:

    running customer balance column that includes the impact each transaction
    customer balance at the end of each month
    minimum, average and maximum values of the running balance for each customer
*/

CREATE TEMP TABLE cash_flow_by_month_by_transaction AS (
  SELECT
      customer_id,
      EXTRACT(YEAR FROM txn_date) AS year,
      EXTRACT(MONTH FROM txn_date) AS month,
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

CREATE TEMP TABLE min_max_average_balance AS (
    SELECT
        *,
        MAX(balance) OVER (
            PARTITION BY customer_id ORDER BY txn_date) 
            AS balance_max,
        MIN(balance) OVER (
            PARTITION BY customer_id ORDER BY txn_date) 
            AS balance_min,
        ROUND(
          AVG(balance) OVER (
            PARTITION BY customer_id ORDER BY txn_date)
          )
            AS balance_avg

    FROM
        balance_at_after_each_transaction
    ORDER BY
        customer_id, txn_date
);


CREATE TEMP TABLE balance_in_current_month AS (
    SELECT
        customer_id,
        year,
        month,
        txn_date,
        SUM(cash_flow) OVER (
            PARTITION BY customer_id ORDER BY year, month) AS balance_the_monthly
    FROM
        cash_flow_by_month_by_transaction
    ORDER BY
        customer_id, year, month
);


SELECT
    min_max_average_balance.customer_id,
    min_max_average_balance.txn_date,
    cash_flow,
  	txn_type,
    balance,
    balance_max,
    balance_min,
    balance_avg,
    balance_the_monthly
FROM
    min_max_average_balance
JOIN
    balance_in_current_month ON balance_in_current_month.customer_id = min_max_average_balance.customer_id
    AND balance_in_current_month.txn_date = min_max_average_balance.txn_date;

/*
SELECT
    min_max_average_balance.customer_id,
    min_max_average_balance.txn_date,
    cash_flow,
  	txn_type,
    balance,
    balance_max,
    balance_min,
    balance_avg,
    balance_the_monthly
FROM
    min_max_average_balance
JOIN
    balance_in_current_month ON balance_in_current_month.customer_id = min_max_average_balance.customer_id
    AND balance_in_current_month.txn_date = min_max_average_balance.txn_date;
*/