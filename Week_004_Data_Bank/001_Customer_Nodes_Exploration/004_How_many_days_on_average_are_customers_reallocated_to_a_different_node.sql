/*
How many days on average are customers reallocated to a different node?
*/

WITH nodes_duration_in_days AS (
  SELECT
  	customer_id, 
    region_id, 
    node_id,
    start_date,
    end_date,
    end_date - start_date AS days
    FROM 
        data_bank.customer_nodes
  	WHERE
  		end_date != '9999-12-31T00:00:00.000Z' -- Node lasting until today
)
SELECT
	ROUND(AVG(days)) AS "average node duration in days"
FROM
	nodes_duration_in_days
;

/*
average node duration in days
15
*/

-- step 1: create a table with row numbers and duration
DROP TABLE IF EXISTS ranked_customer_nodes;
CREATE TEMP TABLE ranked_customer_nodes AS
SELECT
  customer_id,
  node_id,
  region_id,
  DATE_PART('day', AGE(end_date, start_date))::INTEGER AS duration,
  ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY start_date) AS rn
FROM data_bank.customer_nodes;

WITH RECURSIVE output_table AS (
  SELECT
    customer_id,
    node_id,
    duration,
    rn,
    1 AS run_id
  FROM ranked_customer_nodes
  WHERE rn = 1

  UNION ALL

  SELECT
    t1.customer_id,
    t2.node_id,
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
    SUM(duration) AS node_duration
  FROM output_table
  GROUP BY
    customer_id,
    run_id
)
SELECT
  ROUND(AVG(node_duration)) AS average_node_duration
FROM cte_customer_nodes;

/*
average_node_duration
17
*/