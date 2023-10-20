-- 7. What is the percentage of sales by demographic for each year in the dataset?

WITH transactions_per_calendar_year_per_demographic AS (
    SELECT
        calendar_year,
        CASE WHEN demographic IS NULL THEN 'Unknown' ELSE demographic END AS demographic,
        SUM(transactions) AS transactions
    FROM data_mart_v.weekly_sales
    GROUP BY calendar_year, demographic
),
transaction_per_year AS (
    SELECT
        calendar_year,
        SUM(transactions) AS total_transactions
    FROM data_mart_v.weekly_sales
    GROUP BY calendar_year
)
SELECT
    per_calendar_year_per_demographic.calendar_year,
    demographic,
    transactions,
    ROUND((transactions::DECIMAL / total_transactions * 100), 2) AS "transactions %"
FROM transactions_per_calendar_year_per_demographic AS per_calendar_year_per_demographic 
JOIN transaction_per_year ON 
transaction_per_year.calendar_year = per_calendar_year_per_demographic.calendar_year
ORDER BY per_calendar_year_per_demographic.calendar_year, demographic
;

/*
| calendar_year  | demographic  | transactions  | transactions % |
|----------------|--------------|---------------|----------------|
| 2018           | Couples      | 81114247      | 23.42          |
| 2018           | Families     | 76367224      | 22.05          |
| 2018           | null         | 188924989     | 54.54          |
| 2019           | Couples      | 90461484      | 24.74          |
| 2019           | Families     | 83963917      | 22.96          |
| 2019           | null         | 191213884     | 52.30          |
| 2020           | Couples      | 99942303      | 26.59          |
| 2020           | Families     | 89458049      | 23.80          |
| 2020           | null         | 186413299     | 49.60          |
*/

SELECT DISTINCT
  calendar_year,
  demographic,
  SUM(sales) OVER (PARTITION BY calendar_year, demographic) AS yearly_sales,
  ROUND(
    (
      (100 *  SUM(sales) OVER (PARTITION BY calendar_year))::DECIMAL /
        SUM(sales) OVER (PARTITION BY calendar_year, demographic)
    )::DECIMAL,
    2
  ) AS percentage
FROM data_mart_v.weekly_sales
ORDER BY
  calendar_year,
  demographic;