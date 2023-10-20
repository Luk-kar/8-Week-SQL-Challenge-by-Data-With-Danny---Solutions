/*
9. What is the total transaction “penetration” for each product? 
(hint: penetration = number of transactions where at least 1 quantity of a product was pucphased 
divided by total number of transactions)
*/

WITH product_transactions AS (
  SELECT
    prod_id,
    COUNT(DISTINCT txn_id) AS product_transactions
  FROM balanced_tree.sales
  GROUP BY prod_id
),
total_transactions AS (
  SELECT
    COUNT(DISTINCT txn_id) AS total_transaction_count
  FROM balanced_tree.sales
)
SELECT
  DENSE_RANK() OVER (ORDER BY product_transactions.product_transactions DESC) AS ranked,
  product_details.product_id,
  product_details.product_name,
  ROUND(
      product_transactions.product_transactions::DECIMAL
      / total_transactions.total_transaction_count * 100,
    2
  ) AS penetration_percentage
FROM product_transactions
CROSS JOIN total_transactions
INNER JOIN balanced_tree.product_details
  ON product_transactions.prod_id = product_details.product_id
ORDER BY penetration_percentage DESC
;

/*
| ranked  | product_id  | product_name                      | penetration_percentage |
|---------|-------------|-----------------------------------|------------------------|
| 1       | f084eb      | Navy Solid Socks - Mens           | 51.24                  |
| 2       | 9ec847      | Grey Fashion Jacket - Womens      | 51.00                  |
| 3       | c4a632      | Navy Oversized Jeans - Womens     | 50.96                  |
| 4       | 5d267b      | White Tee Shirt - Mens            | 50.72                  |
| 4       | 2a2353      | Blue Polo Shirt - Mens            | 50.72                  |
| 5       | 2feb6b      | Pink Fluro Polkadot Socks - Mens  | 50.32                  |
| 6       | 72f5d4      | Indigo Rain Jacket - Womens       | 50.00                  |
| 7       | d5e9a6      | Khaki Suit Jacket - Womens        | 49.88                  |
| 8       | e83aa3      | Black Straight Jeans - Womens     | 49.84                  |
| 9       | e31d39      | Cream Relaxed Jeans - Womens      | 49.72                  |
| 9       | b9a74d      | White Striped Socks - Mens        | 49.72                  |
| 10      | c8d436      | Teal Button Up Shirt - Mens       | 49.68                  |
*/