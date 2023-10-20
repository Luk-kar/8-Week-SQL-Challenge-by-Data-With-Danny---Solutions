-- 7. What is the percentage split of revenue by segment for each category?

WITH cte_product_revenue AS (
  SELECT
    product_details.category_id,
    product_details.category_name,
    product_details.segment_id,
    product_details.segment_name,
    SUM(sales.qty * sales.price) AS product_revenue
  FROM balanced_tree.sales
  INNER JOIN balanced_tree.product_details
    ON sales.prod_id = product_details.product_id
  GROUP BY
    product_details.category_id,
    product_details.category_name,
    product_details.segment_id,
    product_details.segment_name
)
SELECT
  *,
  ROUND(
    SUM(product_revenue) OVER (PARTITION BY category_id, segment_id)::DECIMAL /
    SUM(product_revenue) OVER (PARTITION BY category_id) * 100,
    2
  ) AS category_segment_percentage
FROM cte_product_revenue
ORDER BY category_id, category_segment_percentage DESC
;

/*
| category_id  | category_name  | segment_id  | segment_name  | product_revenue  | category_segment_percentage |
|--------------|----------------|-------------|---------------|------------------|-----------------------------|
| 1            | Womens         | 4           | Jacket        | 366983           | 63.79                       |
| 1            | Womens         | 3           | Jeans         | 208350           | 36.21                       |
| 2            | Mens           | 5           | Shirt         | 406143           | 56.87                       |
| 2            | Mens           | 6           | Socks         | 307977           | 43.13                       |
*/