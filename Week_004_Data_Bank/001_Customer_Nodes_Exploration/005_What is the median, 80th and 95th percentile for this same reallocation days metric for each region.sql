/*
What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
*/


WITH RECURSIVE output_table AS (
  SELECT
    customer_id,
    node_id,
    region_id,
    duration,
    rn,
    1 AS run_id
  FROM ranked_customer_nodes  -- using the temp table we created previously
  WHERE rn = 1

  UNION ALL

  SELECT
    t1.customer_id,
    t2.node_id,
    t2.region_id,
    t2.duration,
    t2.rn,
    -- update run_id if the node_id values do not match
    CASE
      WHEN t1.node_id != t2.node_id THEN t1.run_id + 1
      ELSE t1.run_id
      END AS run_id
  FROM output_table t1
  INNER JOIN ranked_customer_nodes t2
    ON t1.rn + 1 = t2.rn
    AND t1.customer_id = t2.customer_id
    And t2.rn > 1
),
cte_customer_nodes AS (
  SELECT
    customer_id,
    run_id,
    region_id,
    SUM(duration) AS node_duration
  FROM output_table
  GROUP BY
    customer_id,
    run_id,
    region_id
)
SELECT
  regions.region_name,
  ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY node_duration)) AS median_node_duration,
  ROUND(PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY node_duration)) AS pct80_node_duration,
  ROUND(PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY node_duration)) AS pct95_node_duration
FROM cte_customer_nodes
INNER JOIN data_bank.regions
  ON cte_customer_nodes.region_id = regions.region_id
GROUP BY regions.region_name, regions.region_id
ORDER BY regions.region_id;

/*
| region_name | median_node_duration | pct80_node_duration | pct95_node_duration |
|-------------|----------------------|---------------------|---------------------|
| Australia   | 17                   | 25                  | 38                  |
| America     | 17                   | 26                  | 35                  |
| Africa      | 17                   | 27                  | 40                  |
| Asia        | 17                   | 26                  | 40                  |
| Europe      | 17                   | 27                  | 37                  |
*/