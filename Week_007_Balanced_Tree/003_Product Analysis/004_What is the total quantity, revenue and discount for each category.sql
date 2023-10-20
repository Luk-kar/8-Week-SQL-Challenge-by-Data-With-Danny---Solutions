-- 4. What is the total quantity, revenue and discount for each category?

SELECT
  product_details.category_id,
  product_details.category_name,
  SUM(sales.qty) AS total_quantity,
  SUM(sales.qty * sales.price) AS total_revenue,
  ROUND(
    SUM((sales.qty * sales.price * sales.discount)::DECIMAL / 100),
    2
  ) AS total_discount
FROM balanced_tree.sales
INNER JOIN balanced_tree.product_details
  ON sales.prod_id = product_details.product_id
GROUP BY category_id, category_name
ORDER BY total_revenue DESC
;

/*
| category_id  | category_name  | total_quantity  | total_revenue  | total_discount |
|--------------|----------------|-----------------|----------------|----------------|
| 2            | Mens           | 22482           | 714120         | 86607.71       |
| 1            | Womens         | 22734           | 575333         | 69621.43       |
*/