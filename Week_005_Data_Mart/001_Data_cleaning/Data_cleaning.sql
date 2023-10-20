DROP SCHEMA IF EXISTS data_mart_v CASCADE;
CREATE SCHEMA data_mart_v;

DROP MATERIALIZED VIEW IF EXISTS data_mart_v.weekly_sales;
CREATE MATERIALIZED VIEW data_mart_v.weekly_sales AS
SELECT
  TO_DATE(week_date, 'DD/MM/YY') AS week_date,
  CEIL(EXTRACT(DOY FROM TO_DATE(week_date, 'DD/MM/YY')) / 7) AS week_number,
  CEIL(EXTRACT(MONTH FROM TO_DATE(week_date, 'DD/MM/YY'))) AS month_number,
  CEIL(EXTRACT(YEAR FROM TO_DATE(week_date, 'DD/MM/YY'))) AS calendar_year,
  region,
  platform,
  CASE
    WHEN segment = 'null' THEN 'Unknown'
    ELSE segment
    END AS segment,
  CASE 
    WHEN segment NOT IN ('unknown', '') AND segment IS NOT NULL THEN
        CASE 
            WHEN SUBSTRING(segment, 2, 1) = '1' THEN 'Young Adults'
            WHEN SUBSTRING(segment, 2, 1) = '2' THEN 'Middle Aged'
            WHEN SUBSTRING(segment, 2, 1) IN ('3', '4') THEN 'Retirees'
            ELSE NULL
        END
    ELSE NULL
  END AS age_band,
  CASE 
    WHEN segment NOT IN ('unknown', '') AND segment IS NOT NULL THEN
        CASE 
            WHEN SUBSTRING(segment, 1, 1) = 'C' THEN 'Couples'
            WHEN SUBSTRING(segment, 1, 1) = 'F' THEN 'Families'
            ELSE NULL
        END
    ELSE NULL
  END AS demographic,
  customer_type,
  transactions,
  sales,
  ROUND(sales::DECIMAL / transactions, 2) AS avg_transaction
FROM data_mart.weekly_sales;

SELECT
  *
FROM data_mart_v.weekly_sales
LIMIT 10
;

/*

| week_date                | week_number | month_number | calendar_year | region | platform | segment | age_band     | demographic | customer_type | transactions | sales    | avg_transaction |
| ------------------------ | ----------- | ------------ | ------------- | ------ | -------- | ------- | ------------ | ----------- | ------------- | ------------ | -------- | --------------- |
| 2020-08-31T00:00:00.000Z | 35          | 8            | 2020          | ASIA   | Retail   | C3      | Retirees     | Couples     | New           | 120631       | 3656163  | 30.31           |
| 2020-08-31T00:00:00.000Z | 35          | 8            | 2020          | ASIA   | Retail   | F1      | Young Adults | Families    | New           | 31574        | 996575   | 31.56           |
| 2020-08-31T00:00:00.000Z | 35          | 8            | 2020          | USA    | Retail   | null    |              |             | Guest         | 529151       | 16509610 | 31.20           |
| 2020-08-31T00:00:00.000Z | 35          | 8            | 2020          | EUROPE | Retail   | C1      | Young Adults | Couples     | New           | 4517         | 141942   | 31.42           |
| 2020-08-31T00:00:00.000Z | 35          | 8            | 2020          | AFRICA | Retail   | C2      | Middle Aged  | Couples     | New           | 58046        | 1758388  | 30.29           |
| 2020-08-31T00:00:00.000Z | 35          | 8            | 2020          | CANADA | Shopify  | F2      | Middle Aged  | Families    | Existing      | 1336         | 243878   | 182.54          |
| 2020-08-31T00:00:00.000Z | 35          | 8            | 2020          | AFRICA | Shopify  | F3      | Retirees     | Families    | Existing      | 2514         | 519502   | 206.64          |
| 2020-08-31T00:00:00.000Z | 35          | 8            | 2020          | ASIA   | Shopify  | F1      | Young Adults | Families    | Existing      | 2158         | 371417   | 172.11          |
| 2020-08-31T00:00:00.000Z | 35          | 8            | 2020          | AFRICA | Shopify  | F2      | Middle Aged  | Families    | New           | 318          | 49557    | 155.84          |
| 2020-08-31T00:00:00.000Z | 35          | 8            | 2020          | AFRICA | Retail   | C3      | Retirees     | Couples     | New           | 111032       | 3888162  | 35.02           |
*/