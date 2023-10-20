 /*
 How many customers are allocated to each region?
 */
 
SELECT
    customer_nodes.region_id,
    region_name, 
    COUNT(DISTINCT customer_id) AS number_of_customers
FROM 
    data_bank.customer_nodes AS customer_nodes
JOIN
    data_bank.regions AS regions ON regions.region_id = customer_nodes.region_id
GROUP BY
    customer_nodes.region_id,
    regions.region_name
ORDER BY
    customer_nodes.region_id;

/*
region_id 	region_name 	number_of_customers
1 	Australia 	110
2 	America 	105
3 	Africa 	102
4 	Asia 	95
5 	Europe 	88
*/