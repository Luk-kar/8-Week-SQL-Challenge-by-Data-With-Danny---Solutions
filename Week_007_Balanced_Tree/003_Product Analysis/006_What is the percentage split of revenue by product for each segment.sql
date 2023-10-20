-- 6. What is the percentage split of revenue by product for each segment?

WITH cte_product_revenue AS (
  SELECT
    product_details.segment_id,
    product_details.segment_name,
    product_details.product_id,
    product_details.product_name,
    SUM(sales.qty * sales.price) AS product_revenue
  FROM balanced_tree.sales
  INNER JOIN balanced_tree.product_details
    ON sales.prod_id = product_details.product_id
  GROUP BY
    product_details.segment_id,
    product_details.segment_name,
    product_details.product_id,
    product_details.product_name
)
SELECT
  *,
  ROUND(
     product_revenue::DECIMAL /
      SUM(product_revenue) OVER (
        PARTITION BY segment_id
      ) * 100,
    2
  ) AS segment_product_percentage
FROM cte_product_revenue
ORDER BY segment_id, segment_product_percentage DESC
;

/*
| segment_id  | segment_name  | product_id  | product_name                   | product_revenue  | segment_product_percentage |
|-------------|---------------|-------------|--------------------------------|------------------|----------------------------|
| 3           | Jeans         | e83aa3      | Black Straight Jeans - Womens  | 121152           | 58.15                      |
| 3           | Jeans         | c4a632      | Navy Oversized Jeans - Womens  | 50128            | 24.06                      |
| 3           | Jeans         | e31d39      | Cream Relaxed Jeans - Womens   | 37070            | 17.79                      |
| 4           | Jacket        | 9ec847      | Grey Fashion Jacket - Womens   | 209304           | 57.03                      |
| 4           | Jacket        | d5e9a6      | Khaki Suit Jacket - Womens     | 86296            | 23.51                      |
| 4           | Jacket        | 72f5d4      | Indigo Rain Jacket - Womens    | 71383            | 19.45                      |
*/