-- 9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead
-- it's better to not use, due to intermediate ROUND function

SELECT
    calendar_year,
    platform,
    CASE 
        WHEN SUM(transactions) = 0 THEN NULL
        ELSE ROUND(SUM(sales)::DECIMAL / SUM(transactions), 2)
    END AS avg_transaction
FROM data_mart_v.weekly_sales
GROUP BY calendar_year, platform
ORDER BY calendar_year, platform DESC
;

/*
| calendar_year  | platform  | avg_transaction |
|----------------|-----------|-----------------|
| 2018           | Shopify   | 192.48          |
| 2018           | Retail    | 36.56           |
| 2019           | Shopify   | 183.36          |
| 2019           | Retail    | 36.83           |
| 2020           | Shopify   | 179.03          |
| 2020           | Retail    | 36.56           |
*/

SELECT
  calendar_year,
  platform,
  AVG(avg_transaction) AS avg_avg_transaction,
  SUM(sales)::DECIMAL / SUM(transactions) AS avg_annual_transaction
FROM data_mart_v.weekly_sales
GROUP BY
  calendar_year,
  platform
ORDER BY
  calendar_year,
  platform;

/*
| calendar_year  | platform  | avg_avg_transaction   | avg_annual_transaction |
|----------------|-----------|-----------------------|------------------------|
| 2018           | Retail    | 42.9063690476190476   | 36.5626496695186973    |
| 2018           | Shopify   | 188.2792716396903589  | 192.4813117078147372   |
| 2019           | Retail    | 41.9680707282913165   | 36.8334548591869945    |
| 2019           | Shopify   | 177.5595617110799439  | 183.3610687231916155   |
| 2020           | Retail    | 40.6402310924369748   | 36.5565726600357209    |
| 2020           | Shopify   | 174.8735691768826620  | 179.0332102449060611   |
*/