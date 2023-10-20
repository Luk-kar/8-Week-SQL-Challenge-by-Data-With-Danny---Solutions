/*
C. Before & After Analysis

This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.

Taking the week_date value of `2020-06-15` as the baseline week where the Data Mart sustainable packaging changes came into effect.

We would include all week_date values for `2020-06-15` as the start of the period after the change and the previous week_date values would be before

Using this analysis approach - answer the following questions:

*/

/*
1. What is the total sales for the 4 weeks before and after `2020-06-15`? 
What is the growth or reduction rate in actual values and percentage of sales?
2. What about the entire 12 weeks before and after?
3. How do the sale metrics for these 2 periods before and after 
compare with the previous years in 2018 and 2019?
*/


WITH calculated_sales AS (

    SELECT
        3 AS record,
        '2020-05-18 - 2020-06-14 (4 weeks before)' AS periods,
        SUM(sales) AS sales
    FROM data_mart_v.weekly_sales
    WHERE
    week_date >= '2020-06-15'::DATE - INTERVAL '4 weeks' AND
    week_date < '2020-06-15'::DATE

    UNION ALL

    SELECT
        4 AS record,
        '2020-06-15 - 2020-07-12 (4 weeks after)' AS periods,
        SUM(sales) AS sales
    FROM data_mart_v.weekly_sales
    WHERE
    week_date >= '2020-06-15'::DATE AND
    week_date < '2020-06-15'::DATE + INTERVAL '4 weeks'
),
calculated_diffs_4_weeks AS (
    SELECT
        periods,
        sales - LAG(sales) OVER (ORDER BY record) AS sales_diff,
        CASE 
            WHEN periods = '2020-06-15 - 2020-07-12 (4 weeks after)'
                THEN ROUND((sales::DECIMAL / LAG(sales) OVER (ORDER BY record) - 1) * 100, 2)
                ELSE null
            END AS "change_%"
    FROM calculated_sales
    ORDER BY record
)
SELECT sales_diff, "change_%" FROM calculated_diffs_4_weeks WHERE "change_%" IS NOT NULL
;

/*
| sales_diff  | change_% |
|-------------|----------|
| -26884188   | -1.15    |
*/


WITH calculated_sales AS (

    SELECT
        1 AS record,
        '2020-03-23 - 2020-06-14 (12 weeks before)' AS periods,
        SUM(sales) AS sales
    FROM data_mart_v.weekly_sales
    WHERE
    week_date >= '2020-06-15'::DATE - INTERVAL '12 weeks' AND
    week_date < '2020-06-15'::DATE

    UNION ALL

    SELECT
        2 AS record,
        '2020-06-15 - 2020-09-06 (12 weeks after)' AS periods,
        SUM(sales) AS sales
    FROM data_mart_v.weekly_sales
    WHERE
    week_date >= '2020-06-15'::DATE AND
    week_date < '2020-06-15'::DATE + INTERVAL '12 weeks'
),
calculated_diffs_12_weeks AS (
    SELECT
        periods,
        sales - LAG(sales) OVER (ORDER BY record) AS sales_diff,
        CASE 
            WHEN periods = '2020-06-15 - 2020-09-06 (12 weeks after)'
                THEN ROUND((sales::DECIMAL / LAG(sales) OVER (ORDER BY record) - 1) * 100, 2)
                ELSE null
            END AS "change_%"
    FROM calculated_sales
    ORDER BY record
)
SELECT sales_diff, "change_%" FROM calculated_diffs_12_weeks WHERE "change_%" IS NOT NULL
;

/*
| sales_diff  | change_% |
|-------------|----------|
| -152325394  | -2.14    |
*/

WITH cte_4weeks AS (
  SELECT
    calendar_year,
    CASE
      WHEN week_number BETWEEN 21 AND 24 THEN '1.Before'
      WHEN week_number BETWEEN 25 AND 28 THEN '2.After'
    END AS period_name,
    SUM(sales) AS total_sales,
    SUM(transactions) AS total_transactions,
    SUM(sales)::DECIMAL / SUM(transactions) AS avg_transaction_size
  FROM data_mart_v.weekly_sales
  WHERE week_number BETWEEN 21 and 28
  GROUP BY
    calendar_year,
    period_name
),
cte_calculations AS (
  SELECT
    calendar_year,
    period_name,
    total_sales - LAG(total_sales) OVER (
      PARTITION BY calendar_year
      ORDER BY period_name
    ) AS sales_diff,
    ROUND(
      100 * ((total_sales::DECIMAL / LAG(total_sales) OVER (
        PARTITION BY calendar_year
        ORDER BY period_name
      )) - 1),
      2
    ) AS sales_change
  FROM cte_4weeks
)
SELECT
  calendar_year,
  sales_diff,
  sales_change
FROM cte_calculations
WHERE sales_diff IS NOT NULL
ORDER BY calendar_year;

/*
output:

| calendar_year  | sales_diff  | sales_change |
|----------------|-------------|--------------|
| 2018           | 4102105     | 0.19         |
| 2019           | 16519108    | 0.73         |
| 2020           | 4009608     | 0.17         |
*/

WITH cte_12weeks AS (
  SELECT
    calendar_year,
    CASE
      WHEN week_number BETWEEN 13 AND 24 THEN '1.Before'
      WHEN week_number BETWEEN 25 AND 36 THEN '2.After'
      END AS period_name,
    SUM(sales) AS total_sales,
    SUM(transactions) AS total_transactions,
    SUM(sales)::DECIMAL / SUM(transactions) AS avg_transaction_size
  FROM data_mart_v.weekly_sales
  WHERE week_number BETWEEN 13 and 36
  GROUP BY
    calendar_year,
    period_name
),
cte_calculations AS (
  SELECT
    calendar_year,
    period_name,
    total_sales - LAG(total_sales) OVER (
      PARTITION BY calendar_year
      ORDER BY period_name
    ) AS sales_diff,
    ROUND(
      100 * ((total_sales::DECIMAL / LAG(total_sales) OVER (
        PARTITION BY calendar_year
        ORDER BY period_name
      )) - 1),
      2
    ) AS sales_change
  FROM cte_12weeks
)
SELECT
  calendar_year,
  sales_diff,
  sales_change
FROM cte_calculations
WHERE sales_diff IS NOT NULL
ORDER BY calendar_year;

/*
| calendar_year  | sales_diff  | sales_change |
|----------------|-------------|--------------|
| 2018           | 104256193   | 1.63         |
| 2019           | -557600876  | -8.13        |
| 2020           | -654178584  | -9.27        |
*/