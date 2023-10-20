-- 8. Which age_band and demographic values contribute the most to Retail sales?

WITH transactions_per_segment AS (
    SELECT
        age_band,
        demographic,
        SUM(transactions) AS transactions
    FROM data_mart_v.weekly_sales
    WHERE platform = 'Retail'
    GROUP BY age_band, demographic
),
transaction_in_retail AS (
    SELECT
        SUM(transactions) AS total_transactions
    FROM data_mart_v.weekly_sales
    WHERE platform = 'Retail'
)
SELECT
    DENSE_RANK() OVER (ORDER BY transactions DESC) AS rank_retail,
    CASE WHEN per_segment.age_band IS NULL THEN 'Unknown' ELSE per_segment.age_band END AS age_band,
    CASE WHEN per_segment.demographic IS NULL THEN 'Unknown' ELSE per_segment.demographic END AS demographic,
    transactions,
    ROUND((transactions::DECIMAL / total_transactions * 100), 2) AS "transactions %"
FROM transactions_per_segment AS per_segment 
CROSS JOIN
   transaction_in_retail
ORDER BY rank_retail
;

/*
| rank_retail  | age_band      | demographic  | transactions  | transactions % |
|--------------|---------------|--------------|---------------|----------------|
| 1            | Unknown       | Unknown      | 565005327     | 52.22          |
| 2            | Retirees      | Couples      | 140087609     | 12.95          |
| 3            | Retirees      | Families     | 125782497     | 11.63          |
| 4            | Middle Aged   | Families     | 85793524      | 7.93           |
| 5            | Young Adults  | Couples      | 79744122      | 7.37           |
| 6            | Middle Aged   | Couples      | 49629208      | 4.59           |
| 7            | Young Adults  | Families     | 35891940      | 3.32           |
*/

-- age band only
SELECT
  CASE WHEN age_band IS NULL THEN 'Unknown' ELSE age_band END AS age_band,
  SUM(sales) AS total_sales,
  ROUND(100 * SUM(sales) / (SELECT SUM(sales) FROM data_mart_v.weekly_sales)::DECIMAL) AS sales_percentage
FROM data_mart_v.weekly_sales
WHERE platform = 'Retail'
GROUP BY age_band
ORDER BY sales_percentage DESC
;
-- demographic only
SELECT
  CASE WHEN demographic IS NULL THEN 'Unknown' ELSE demographic END AS demographic,
  SUM(sales) AS total_sales,
  ROUND(100 * SUM(sales) / (SELECT SUM(sales) FROM data_mart_v.weekly_sales)::DECIMAL) AS sales_percentage
FROM data_mart_v.weekly_sales
WHERE platform = 'Retail'
GROUP BY demographic
ORDER BY sales_percentage DESC
;
-- both age and demographic
SELECT
  CASE WHEN age_band IS NULL THEN 'Unknown' ELSE age_band END AS age_band,
  CASE WHEN demographic IS NULL THEN 'Unknown' ELSE demographic END AS demographic,
  SUM(sales) AS total_sales,
  ROUND(100 * SUM(sales) / (SELECT SUM(sales) FROM data_mart_v.weekly_sales)::DECIMAL) AS sales_percentage
FROM data_mart_v.weekly_sales
WHERE platform = 'Retail'
GROUP BY age_band, demographic
ORDER BY sales_percentage DESC
;

/*
| age_band      | total_sales  | sales_percentage |
|---------------|--------------|------------------|
| Unknown       | 16067285533  | 39               |
| Retirees      | 13005266930  | 32               |
| Middle Aged   | 6208251884   | 15               |
| Young Adults  | 4373812090   | 11               |

| demographic  | total_sales  | sales_percentage |
|--------------|--------------|------------------|
| Unknown      | 16067285533  | 39               |
| Families     | 12759667763  | 31               |
| Couples      | 10827663141  | 27               |

| age_band      | demographic  | total_sales  | sales_percentage |
|---------------|--------------|--------------|------------------|
| Unknown       | Unknown      | 16067285533  | 39               |
| Retirees      | Couples      | 6370580014   | 16               |
| Retirees      | Families     | 6634686916   | 16               |
| Middle Aged   | Families     | 4354091554   | 11               |
| Young Adults  | Couples      | 2602922797   | 6                |
| Middle Aged   | Couples      | 1854160330   | 5                |
| Young Adults  | Families     | 1770889293   | 4                |
*/