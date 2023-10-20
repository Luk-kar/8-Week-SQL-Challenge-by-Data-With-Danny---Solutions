-- 5. What is the top selling product for each category?

WITH cte_ranked_category_product_quantity AS (
SELECT
  product_details.category_id,
  product_details.category_name,
  sales.prod_id,
  product_details.product_name,
  SUM(sales.qty) AS product_quantity,
  RANK() OVER (
    PARTITION BY product_details.category_id
    ORDER BY SUM(sales.qty) DESC
  ) AS category_quantity_rank
FROM balanced_tree.sales
INNER JOIN balanced_tree.product_details
  ON sales.prod_id = product_details.product_id
GROUP BY
  product_details.category_id,
  product_details.category_name,
  sales.prod_id,
  product_details.product_name
)
SELECT
  category_id,
  category_name,
  prod_id,
  product_name,
  product_quantity
FROM cte_ranked_category_product_quantity
WHERE category_quantity_rank = 1
ORDER BY product_quantity DESC;

/*
| category_id  | category_name  | prod_id  | product_name                  | product_quantity |
|--------------|----------------|----------|-------------------------------|------------------|
| 1            | Womens         | 9ec847   | Grey Fashion Jacket - Womens  | 3876             |
| 2            | Mens           | 2a2353   | Blue Polo Shirt - Mens        | 3819             |
*/