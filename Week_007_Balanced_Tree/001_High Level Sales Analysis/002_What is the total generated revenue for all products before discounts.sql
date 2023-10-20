-- 2. What is the total generated revenue for all products before discounts?

SELECT SUM(qty * price) AS gross_before_discount FROM balanced_tree.sales;

/*
| gross_before_discount |
|-----------------------|
| 1289453               |
*/