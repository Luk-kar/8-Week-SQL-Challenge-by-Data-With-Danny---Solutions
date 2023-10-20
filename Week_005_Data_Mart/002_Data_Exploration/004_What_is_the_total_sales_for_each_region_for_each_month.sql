--  4. What is the total sales for each region for each month?

SELECT
    region,
	calendar_year || '-' || LPAD(month_number::TEXT, 2, '0') AS month,
    SUM(transactions) AS transactions
FROM data_mart_v.weekly_sales
GROUP BY region, calendar_year, weekly_sales.month_number
ORDER BY month, region
;

/*
| region         | month    | transactions |
|----------------|----------|--------------|
| AFRICA         | 2018-03  | 3299215      |
| ASIA           | 2018-03  | 3663461      |
| CANADA         | 2018-03  | 894791       |
| EUROPE         | 2018-03  | 196817       |
| OCEANIA        | 2018-03  | 4796853      |
| SOUTH AMERICA  | 2018-03  | 413580       |
| USA            | 2018-03  | 1203251      |
| AFRICA         | 2018-04  | 16129215     |
| ASIA           | 2018-04  | 18440357     |
...
*/