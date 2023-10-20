/*
How many unique nodes are there on the Data Bank system?
*/

SELECT
	COUNT(DISTINCT (region_id::TEXT || node_id::TEXT)) AS "sum of unique nodes"
FROM
	data_bank.customer_nodes;

/*
| sum of unique nodes |
|---------------------|
| 25                  |
*/