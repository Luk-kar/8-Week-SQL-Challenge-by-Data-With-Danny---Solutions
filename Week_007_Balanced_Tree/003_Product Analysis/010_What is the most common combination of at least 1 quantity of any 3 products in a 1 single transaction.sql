-- 9. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?  
-- Super bonus - what are the quantity, revenue, discount and net revenue from the top 3 products 
-- in the transactions where all 3 were purchased?

/*
Here are the algorithmic steps for the following SQL query you will need to debug - hold onto your keyboard!

    Use a recursive CTE to generate all combinations of 3 products with no duplicates
    Create an array with all of the products in each transaction
    Perform a cross join and check if each 3 product combination is contained within each transaction’s group of products using <@ array operation notation
    Check if there are any equivalent ranking by transaction count
    Split out the array type back into row format so it can be joined back onto product details
    Final calculations for the question (phew we got there!)

*/

-- step 1: check the product_counter...
DROP TABLE IF EXISTS temp_product_combos;
CREATE TEMP TABLE temp_product_combos AS
WITH RECURSIVE input(product) AS (
  SELECT product_id::TEXT FROM balanced_tree.product_details
),
output_table AS (
   SELECT 
    ARRAY[product] AS combo,
    product,
    1 AS product_counter
   FROM input
  
   UNION

   SELECT
    ARRAY_APPEND(output_table.combo, input.product),
    input.product,
    product_counter + 1
   FROM output_table
   INNER JOIN input ON input.product > output_table.product
   WHERE output_table.product_counter <= 3
   )
SELECT * from output_table
WHERE product_counter = 3;

-- step 2
WITH cte_transaction_products AS (
  SELECT
    txn_id,
    ARRAY_AGG(prod_id::TEXT ORDER BY prod_id) AS products
  FROM balanced_tree.sales
  GROUP BY txn_id
),
-- step 3
cte_combo_transactions AS (
  SELECT
    txn_id,
    combo,
    products
  FROM cte_transaction_products
  CROSS JOIN temp_product_combos  -- previously created temp table above!
  WHERE combo <@ products  -- combo is contained in products
),
-- step 4
cte_ranked_combos AS (
  SELECT
    combo,
    COUNT(DISTINCT txn_id) AS transaction_count,
    RANK() OVER (ORDER BY COUNT(DISTINCT txn_id) DESC) AS combo_rank,
    ROW_NUMBER() OVER (ORDER BY COUNT(DISTINCT txn_id) DESC) AS combo_id
  FROM cte_combo_transactions
  GROUP BY combo
),
-- step 5
cte_most_common_combo_product_transactions AS (
  SELECT
    cte_combo_transactions.txn_id,
    cte_ranked_combos.combo_id,
    UNNEST(cte_ranked_combos.combo) AS prod_id
  FROM cte_combo_transactions
  INNER JOIN cte_ranked_combos
    ON cte_combo_transactions.combo = cte_ranked_combos.combo
  WHERE cte_ranked_combos.combo_rank = 1
)
-- step 6
SELECT
  product_details.product_id,
  product_details.product_name,
  COUNT(DISTINCT sales.txn_id) AS combo_transaction_count,
  SUM(sales.qty) AS quantity,
  SUM(sales.qty * sales.price) AS revenue,
  ROUND(
    SUM(sales.qty * sales.price * sales.discount / 100),
    2
  ) AS discount,
  ROUND(
    SUM(sales.qty * sales.price * (1 - sales.discount / 100)),
    2
  ) AS net_revenue
FROM balanced_tree.sales
INNER JOIN cte_most_common_combo_product_transactions AS top_combo
  ON sales.txn_id = top_combo.txn_id
  AND sales.prod_id = top_combo.prod_id
INNER JOIN balanced_tree.product_details
  ON sales.prod_id = product_details.product_id
GROUP BY product_details.product_id, product_details.product_name
ORDER BY revenue DESC, quantity DESC, net_revenue DESC, discount
;

/*
| product_id  | product_name                  | combo_transaction_count  | quantity  | revenue  | discount  | net_revenue |
|-------------|-------------------------------|--------------------------|-----------|----------|-----------|-------------|
| 9ec847      | Grey Fashion Jacket - Womens  | 352                      | 1062      | 57348    | 6830.00   | 57348.00    |
| 5d267b      | White Tee Shirt - Mens        | 352                      | 1007      | 40280    | 4929.00   | 40280.00    |
| c8d436      | Teal Button Up Shirt - Mens   | 352                      | 1054      | 10540    | 1192.00   | 10540.00    |
*/