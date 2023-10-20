--  6. What is the percentage of sales for Retail vs Shopify for each month?

WITH transactions_per_month_per_platform AS (
    SELECT
        month_number,
        platform,
        SUM(transactions) AS transactions
    FROM data_mart_v.weekly_sales
    GROUP BY month_number, platform
),
transaction_per_month AS (
    SELECT
        month_number,
        SUM(transactions) AS total_transactions
    FROM data_mart_v.weekly_sales
    GROUP BY month_number
)
SELECT
    trim(to_char(TO_DATE('2000-' || per_month_per_platform.month_number || '-01', 'YYYY-MM-DD'), 'Month')) AS month_name,
    platform,
    transactions,
    ROUND((transactions::DECIMAL / total_transactions * 100), 2) AS "transactions %"
FROM transactions_per_month_per_platform AS per_month_per_platform
JOIN transaction_per_month ON 
transaction_per_month.month_number = per_month_per_platform.month_number
ORDER BY per_month_per_platform.month_number, platform
;

/*
| month_name  | platform  | transactions  | transactions % |
|-------------|-----------|---------------|----------------|
| March       | Retail    | 61002121      | 99.49          |
| March       | Shopify   | 315710        | 0.51           |
| April       | Retail    | 208262398     | 99.51          |
| April       | Shopify   | 1024067       | 0.49           |
| May         | Retail    | 181068926     | 99.44          |
*/

WITH cte_monthly_platform_sales AS (
  SELECT
    DATE_TRUNC('week', week_date)::DATE AS _month,
    platform,
    SUM(sales) AS monthly_sales
  FROM data_mart_v.weekly_sales
  GROUP BY _month, platform
)
SELECT
  _month,
  ROUND(
    100 * SUM(CASE WHEN platform = 'Retail' THEN monthly_sales ELSE NULL END)::DECIMAL /
      SUM(monthly_sales),
    2
  ) AS retail_percentage,
  ROUND(
    100 * SUM(CASE WHEN platform = 'Shopify' THEN monthly_sales ELSE NULL END)::DECIMAL /
      SUM(monthly_sales),
    2
  ) AS shopify_percentage
FROM cte_monthly_platform_sales
GROUP BY _month
ORDER BY _month;

/*
| _month                    | retail_percentage  | shopify_percentage |
|---------------------------|--------------------|--------------------|
| 2018-03-26T00:00:00.000Z  | 97.92              | 2.08               |
| 2018-04-02T00:00:00.000Z  | 97.96              | 2.04               |
| 2018-04-09T00:00:00.000Z  | 97.99              | 2.01               |
| 2018-04-16T00:00:00.000Z  | 97.93              | 2.07               |
| 2018-04-23T00:00:00.000Z  | 97.84              | 2.16               |
...
*/