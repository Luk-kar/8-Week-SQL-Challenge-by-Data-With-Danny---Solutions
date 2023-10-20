-- 1. What are the top 3 products by total revenue before discount?

WITH revenue_by_prod AS (
    SELECT
        prod_id,
        SUM(qty * price) AS revenue
    FROM balanced_tree.sales
    GROUP BY prod_id
    ORDER BY revenue DESC
    LIMIT 3
)
SELECT
	revenue_by_prod.prod_id,
    product_details.product_name,
    revenue
FROM revenue_by_prod
LEFT JOIN balanced_tree.product_details ON revenue_by_prod.prod_id = product_details.product_id
ORDER BY revenue DESC
;

/*
| prod_id  | product_name                  | revenue |
|----------|-------------------------------|---------|
| 2a2353   | Blue Polo Shirt - Mens        | 217683  |
| 9ec847   | Grey Fashion Jacket - Womens  | 209304  |
| 5d267b   | White Tee Shirt - Mens        | 152000  |
*/