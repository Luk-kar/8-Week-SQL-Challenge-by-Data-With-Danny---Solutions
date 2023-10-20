-- 1. What was the total quantity sold for all products?

SELECT SUM(qty) AS items_sold FROM balanced_tree.sales;

/*
| items_sold   |
|--------------|
| 45216        |
*/

-- the alternative

SELECT 
    product_name,
    SUM(qty) AS total_quantity 
FROM balanced_tree.sales
LEFT JOIN balanced_tree.product_details ON sales.prod_id = product_details.product_id
GROUP BY product_name
ORDER BY total_quantity DESC
LIMIT 10;

/*
| product_name                      | total_quantity |
|-----------------------------------|----------------|
| Grey Fashion Jacket - Womens      | 3876           |
| Navy Oversized Jeans - Womens     | 3856           |
| Blue Polo Shirt - Mens            | 3819           |
| White Tee Shirt - Mens            | 3800           |
| Navy Solid Socks - Mens           | 3792           |
| Black Straight Jeans - Womens     | 3786           |
| Pink Fluro Polkadot Socks - Mens  | 3770           |
| Indigo Rain Jacket - Womens       | 3757           |
...
*/