/*
What is the unique count and total amount for each transaction type?
*/

SELECT
  txn_type,
  COUNT(*) AS txn_count,
  SUM(customer_id) AS total_amount
FROM data_bank.customer_transactions
GROUP BY txn_type;

/*
transaction txn_count 	total_amount
deposit 	2671 	1359168
purchase 	1617 	806537
withdrawal 	1580 	793003
*/