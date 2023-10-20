-- 3. What is the top selling product for each segment?

WITH products_by_segments AS (
    SELECT
        product_details.segment_id,
        product_details.segment_name,
        sales.prod_id,
        product_details.product_name,
        SUM(qty) AS quantity,
        RANK() OVER (PARTITION BY product_details.segment_name ORDER BY SUM(qty) DESC) AS ranked
    FROM balanced_tree.sales
    LEFT JOIN balanced_tree.product_details ON sales.prod_id = product_details.product_id
    GROUP BY 
        product_details.segment_id, 
        product_details.segment_name, 
        sales.prod_id, 
        product_details.product_name
)
SELECT
    segment_id,
    segment_name,
    prod_id,
    product_name,
    quantity
FROM products_by_segments
WHERE ranked = 1
ORDER BY quantity DESC
;

/*
| segment_id  | segment_name  | prod_id  | product_name                   | quantity |
|-------------|---------------|----------|--------------------------------|----------|
| 4           | Jacket        | 9ec847   | Grey Fashion Jacket - Womens   | 3876     |
| 3           | Jeans         | c4a632   | Navy Oversized Jeans - Womens  | 3856     |
| 5           | Shirt         | 2a2353   | Blue Polo Shirt - Mens         | 3819     |
| 6           | Socks         | f084eb   | Navy Solid Socks - Mens        | 3792     |
*/