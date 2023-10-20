-- 1. How many unique transactions were there?

SELECT 
    COUNT(DISTINCT txn_id) AS unique_transactions_count 
FROM balanced_tree.sales;

/*
| unique_transactions_count |
|---------------------------|
| 2500                      |
*/