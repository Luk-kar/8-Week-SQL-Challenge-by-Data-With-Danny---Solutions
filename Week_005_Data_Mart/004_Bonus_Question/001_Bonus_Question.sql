/*
D. Bonus Question

Which areas of the business have the highest negative impact in sales metrics performance 
in 2020 for the 12 week before and after period?

-- region
-- platform
-- age_band
-- demographic
-- customer_type

Do you have any further recommendations for Danny’s team at Data Mart
or any interesting insights based off this analysis?
*/

WITH cte_12weeks AS (
  SELECT
    calendar_year,
    region,
    CASE
      WHEN week_number BETWEEN 13 AND 24 THEN '1.Before'
      WHEN week_number BETWEEN 25 AND 36 THEN '2.After'
      END AS period_name,
    SUM(sales) AS total_sales,
    SUM(transactions) AS total_transactions,
    SUM(sales)::DECIMAL / SUM(transactions) AS avg_transaction_size
  FROM data_mart_v.weekly_sales
  WHERE week_number BETWEEN 13 AND 36
  GROUP BY
    calendar_year,
    region,
    period_name
),
cte_results AS (
  SELECT
    calendar_year,
    region,
    total_sales,
    total_sales - LAG(total_sales) OVER (
      PARTITION BY calendar_year, region
      ORDER BY period_name
    ) AS sales_diff,
    ROUND(
      100 * ((total_sales::DECIMAL / LAG(total_sales) OVER (
        PARTITION BY calendar_year, region
        ORDER BY period_name
      )) - 1),
      2
    ) AS sales_change
  FROM cte_12weeks
)
SELECT * FROM cte_results
WHERE sales_diff IS NOT NULL
ORDER BY sales_diff
LIMIT 10;

/*
| calendar_year  | region   | total_sales  | sales_diff  | sales_change |
|----------------|----------|--------------|-------------|--------------|
| 2020           | OCEANIA  | 2096183557   | -231336165  | -9.94        |
| 2019           | OCEANIA  | 2067614028   | -183419774  | -8.15        |
| 2020           | ASIA     | 1454048362   | -165984008  | -10.25       |
| 2019           | ASIA     | 1402516880   | -140568460  | -9.11        |
...
*/

-- platform

WITH cte_12weeks AS (
  SELECT
    calendar_year,
    platform,
    CASE
      WHEN week_number BETWEEN 13 AND 24 THEN '1.Before'
      WHEN week_number BETWEEN 25 AND 36 THEN '2.After'
      END AS period_name,
    SUM(sales) AS total_sales,
    SUM(transactions) AS total_transactions,
    SUM(sales)::DECIMAL / SUM(transactions) AS avg_transaction_size
  FROM data_mart_v.weekly_sales
  WHERE week_number BETWEEN 13 AND 36
  GROUP BY
    calendar_year,
    platform,
    period_name
),
cte_results AS (
  SELECT
    calendar_year,
    platform,
    total_sales,
    total_sales - LAG(total_sales) OVER (
      PARTITION BY calendar_year, platform
      ORDER BY period_name
    ) AS sales_diff,
    ROUND(
      100 * ((total_sales::DECIMAL / LAG(total_sales) OVER (
        PARTITION BY calendar_year, platform
        ORDER BY period_name
      )) - 1),
      2
    ) AS sales_change
  FROM cte_12weeks
)
SELECT * FROM cte_results
WHERE sales_diff IS NOT NULL
ORDER BY sales_diff
LIMIT 10;

/*
| calendar_year  | platform  | total_sales  | sales_diff  | sales_change |
|----------------|-----------|--------------|-------------|--------------|
| 2020           | Retail    | 6188030612   | -646516138  | -9.46        |
| 2019           | Retail    | 6131803982   | -566213905  | -8.45        |
| 2020           | Shopify   | 215891793    | -7662446    | -3.43        |
| 2018           | Shopify   | 147391000    | 8572491     | 6.18         |
...
*/

-- age_band

WITH cte_12weeks AS (
  SELECT
    calendar_year,
    age_band,
    CASE
      WHEN week_number BETWEEN 13 AND 24 THEN '1.Before'
      WHEN week_number BETWEEN 25 AND 36 THEN '2.After'
      END AS period_name,
    SUM(sales) AS total_sales,
    SUM(transactions) AS total_transactions,
    SUM(sales)::DECIMAL / SUM(transactions) AS avg_transaction_size
  FROM data_mart_v.weekly_sales
  WHERE week_number BETWEEN 13 AND 36
  GROUP BY
    calendar_year,
    age_band,
    period_name
),
cte_results AS (
  SELECT
    calendar_year,
    CASE WHEN age_band IS NULL THEN 'Unknown' ELSE age_band END AS age_band,
    total_sales,
    total_sales - LAG(total_sales) OVER (
      PARTITION BY calendar_year, age_band
      ORDER BY period_name
    ) AS sales_diff,
    ROUND(
      100 * ((total_sales::DECIMAL / LAG(total_sales) OVER (
        PARTITION BY calendar_year, age_band
        ORDER BY period_name
      )) - 1),
      2
    ) AS sales_change
  FROM cte_12weeks
)
SELECT * FROM cte_results
WHERE sales_diff IS NOT NULL
ORDER BY sales_diff
LIMIT 10;

/*
| calendar_year  | age_band  | total_sales  | sales_diff  | sales_change |
|----------------|-----------|--------------|-------------|--------------|
| 2020           | Unknown      | 2455309572   | -282211293  | -10.31       |
| 2019           | Unknown      | 2543121432   | -212774520  | -7.72        |
| 2020           | Retirees  | 2171707896   | -196696484  | -8.31        |
| 2019           | Retirees  | 2044511045   | -196157153  | -8.75        |
...
*/
-- demographic

WITH cte_12weeks AS (
  SELECT
    calendar_year,
    demographic,
    CASE
      WHEN week_number BETWEEN 13 AND 24 THEN '1.Before'
      WHEN week_number BETWEEN 25 AND 36 THEN '2.After'
      END AS period_name,
    SUM(sales) AS total_sales,
    SUM(transactions) AS total_transactions,
    SUM(sales)::DECIMAL / SUM(transactions) AS avg_transaction_size
  FROM data_mart_v.weekly_sales
  WHERE week_number BETWEEN 13 AND 36
  GROUP BY
    calendar_year,
    demographic,
    period_name
),
cte_results AS (
  SELECT
    calendar_year,
    CASE WHEN demographic IS NULL THEN 'Unknown' ELSE demographic END AS demographic,
    total_sales,
    total_sales - LAG(total_sales) OVER (
      PARTITION BY calendar_year, demographic
      ORDER BY period_name
    ) AS sales_diff,
    ROUND(
      100 * ((total_sales::DECIMAL / LAG(total_sales) OVER (
        PARTITION BY calendar_year, demographic
        ORDER BY period_name
      )) - 1),
      2
    ) AS sales_change
  FROM cte_12weeks
)
SELECT * FROM cte_results
WHERE sales_diff IS NOT NULL
ORDER BY sales_diff
LIMIT 10;

/*
| calendar_year  | demographic  | total_sales  | sales_diff  | sales_change |
|----------------|--------------|--------------|-------------|--------------|
| 2020           | Unknown      | 2455309572   | -282211293  | -10.31       |
| 2019           | Unknown      | 2543121432   | -212774520  | -7.72        |
| 2020           | Families     | 2096951469   | -211927351  | -9.18        |
| 2019           | Families     | 2047950539   | -181300450  | -8.13        |
...
*/

-- customer_type

WITH cte_12weeks AS (
  SELECT
    calendar_year,
    customer_type,
    CASE
      WHEN week_number BETWEEN 13 AND 24 THEN '1.Before'
      WHEN week_number BETWEEN 25 AND 36 THEN '2.After'
      END AS period_name,
    SUM(sales) AS total_sales,
    SUM(transactions) AS total_transactions,
    SUM(sales)::DECIMAL / SUM(transactions) AS avg_transaction_size
  FROM data_mart_v.weekly_sales
  WHERE week_number BETWEEN 13 AND 36
  GROUP BY
    calendar_year,
    customer_type,
    period_name
),
cte_results AS (
  SELECT
    calendar_year,
    CASE WHEN customer_type IS NULL THEN 'Unknown' ELSE customer_type END AS customer_type,
    total_sales,
    total_sales - LAG(total_sales) OVER (
      PARTITION BY calendar_year, customer_type
      ORDER BY period_name
    ) AS sales_diff,
    ROUND(
      100 * ((total_sales::DECIMAL / LAG(total_sales) OVER (
        PARTITION BY calendar_year, customer_type
        ORDER BY period_name
      )) - 1),
      2
    ) AS sales_change
  FROM cte_12weeks
)
SELECT * FROM cte_results
WHERE sales_diff IS NOT NULL
ORDER BY sales_diff
LIMIT 10;

/*
calendar_year 	customer_type 	total_sales 	sales_diff 	sales_change
2020 	Existing 	3308618627 	-348703636 	-9.53
2019 	Existing 	3131335830 	-297003283 	-8.66
2020 	Guest 	2292350880 	-258979106 	-10.15
2019 	Guest 	2357893147 	-206743290 	-8.06
2019 	New 	814328308 	-53854303 	-6.20
...
*/