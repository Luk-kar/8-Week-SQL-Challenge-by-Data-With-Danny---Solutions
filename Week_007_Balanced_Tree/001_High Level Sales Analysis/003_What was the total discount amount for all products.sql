-- 3. What was the total discount amount for all products?

SELECT 
    SUM(
    CASE 
        WHEN discount > 0 
        THEN ROUND((qty * price)::DECIMAL * (discount::DECIMAL / 100), 2) 
    END) AS total_discount_amount 
FROM balanced_tree.sales;

/*
| total_discount_amount |
|-----------------------|
| 156229.14             |
*/