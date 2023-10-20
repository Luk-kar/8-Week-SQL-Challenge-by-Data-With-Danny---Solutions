-- 8. What is the percentage split of total revenue by category?

WITH cte_product_revenue AS (
  SELECT
    product_details.category_id,
    product_details.category_name,
    SUM(sales.qty * sales.price) AS product_revenue
  FROM balanced_tree.sales
  INNER JOIN balanced_tree.product_details
    ON sales.prod_id = product_details.product_id
  GROUP BY
    product_details.category_id,
    product_details.category_name
)
SELECT
  *,
  ROUND(
    product_revenue::DECIMAL /
    (SELECT SUM(product_revenue) FROM cte_product_revenue) * 100,
    2
  ) AS category_percentage
FROM cte_product_revenue
ORDER BY category_id, category_percentage DESC
;


/*
| category_id  | category_name  | product_revenue  | category_percentage |
|--------------|----------------|------------------|---------------------|
| 1            | Womens         | 575333           | 44.62               |
| 2            | Mens           | 714120           | 55.38               |
*/