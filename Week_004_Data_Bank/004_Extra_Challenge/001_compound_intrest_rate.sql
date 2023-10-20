/*
Data Bank wants to try another option which is a bit more difficult to implement 
- they want to calculate data growth using an interest calculation, 
just like in a traditional savings account you might have with a bank.

If the annual interest rate is set at 6% and the Data Bank team wants to 
reward its customers by increasing their data allocation based off the interest calculated 
on a daily basis at the end of each day, how much data would be required 
for this option on a monthly basis?

Special notes:

    Data Bank wants an initial calculation which does not allow for compounding interest, 
    however they may also be interested in a daily compounding interest calculation 
    so you can try to perform this calculation if you have the stamina!
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

WITH RECURSIVE daily_interest AS (
  SELECT
    b.customer_id,
    b.txn_date,
    b.balance,
    1 AS day,
    b.balance::numeric AS daily_balance -- Cast balance to numeric
  FROM
    balance_at_after_each_transaction b

  UNION ALL

  SELECT
    d.customer_id,
    d.txn_date,
    d.balance,
    d.day + 1,
    d.daily_balance * (1 + (SELECT annual_interest_rate / 36500 FROM data_bank.interest_settings))
  FROM
    daily_interest d
  JOIN
    balance_at_after_each_transaction b
  ON
    d.customer_id = b.customer_id AND d.txn_date < b.txn_date
)
SELECT
  d.customer_id,
  d.txn_date,
  d.balance,
  d.day,
  d.daily_balance
FROM
  daily_interest d
ORDER BY
  d.customer_id, d.txn_date
LIMIT
	100;

/*
https://www.db-fiddle.com/f/2GtQz4wZtuNNu7zXH5HtV4/3
Query Error: error: could not write to file "base/pgsql_tmp/pgsql_tmp848.0": No space left on device
*/