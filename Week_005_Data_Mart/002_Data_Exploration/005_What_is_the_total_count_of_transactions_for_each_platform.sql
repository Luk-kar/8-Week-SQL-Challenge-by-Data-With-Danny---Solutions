-- 5. What is the total count of transactions for each platform

WITH transactions_all AS (
    SELECT
        SUM(transactions) AS total_transactions
    FROM data_mart_v.weekly_sales
),
transaction_platform AS (
    SELECT
        platform,
        SUM(transactions) AS total_transactions
    FROM data_mart_v.weekly_sales
    GROUP BY platform
)
SELECT
    platform,
    platform.transactions,
    ROUND((platform.total_transactions::DECIMAL / all.total_transactions * 100), 2) AS "transactions %"
FROM transaction_platform AS platform
CROSS JOIN transactions_all AS all
ORDER BY platform
;

/*
| platform  | platform_transactions  | transactions % |
|-----------|------------------------|----------------|
| Retail    | 1081934227             | 99.46          |
| Shopify   | 5925169                | 0.54           |

*/