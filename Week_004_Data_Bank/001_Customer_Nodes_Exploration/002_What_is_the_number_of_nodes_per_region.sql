/*
What is the number of nodes per region?
*/

WITH nodes_per_region AS (
    SELECT
        region_id, 
        COUNT(DISTINCT node_id) AS unique_nodes
    FROM 
        data_bank.customer_nodes
    GROUP BY
        region_id
)
SELECT
  regions.region_id,
  region_name,
  unique_nodes
FROM nodes_per_region
JOIN data_bank.regions ON regions.region_id = nodes_per_region.region_id

/*
| region_id | region_name | unique_nodes |
|-----------|-------------|--------------|
| 1         | Australia   | 5            |
| 2         | America     | 5            |
| 3         | Africa      | 5            |
| 4         | Asia        | 5            |
| 5         | Europe      | 5            |
*/