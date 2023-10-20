--  3. How many total transactions were there for each year in the dataset?

SELECT
	calendar_year,
    SUM(transactions) AS transactions
FROM data_mart_v.weekly_sales
GROUP BY calendar_year
ORDER BY calendar_year
;

/*
| calendar_year  | transactions |
|----------------|--------------|
| 2018           | 346406460    |
| 2019           | 365639285    |
| 2020           | 375813651    |
*/