/*
What is the average total historical deposit counts and amounts for all customers?
*/

SELECT
	ROUND((COUNT(*)::DECIMAL / COUNT(DISTINCT customer_id)::DECIMAL), 1)
    AS "average number of deposit transactions",
	ROUND(AVG(txn_amount), 2)
    AS "average amount of deposit transaction"
FROM
	data_bank.customer_transactions
WHERE
	txn_type = 'deposit';

/*
average number of deposit transactions | average amount of deposit transaction
5.3 	508.86
*/