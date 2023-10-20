/*
What key metrics would you recommend Foodie-Fi management to track over time to assess performance of their overall business?
*/

-- the active user growth rate (Customer Acquisition Rate)
-- churn rate 
-- Monthly Recurring Revenue (MRR)
-- Customer Lifetime Value (CLV) but as separate table

DROP TABLE IF EXISTS active_users_by_month;
CREATE TEMP TABLE active_users_by_month AS (
  WITH active_users_increment_descrease AS (
    SELECT
      EXTRACT(YEAR FROM start_date) AS year,
      EXTRACT(MONTH FROM start_date) AS month,
      SUM(CASE WHEN plan_id = 0 THEN 1 ELSE 0 END) AS new_user,
      SUM(CASE WHEN plan_id = 4 THEN 1 ELSE 0 END) AS churn_user
    FROM foodie_fi.subscriptions
    WHERE plan_id IN (0, 4)
    GROUP BY year, month
  )
  SELECT
    year,
    month,
    SUM(new_user) OVER (ORDER BY year, month) - SUM(churn_user) OVER (ORDER BY year, month) AS active_users
  FROM
    active_users_increment_descrease
  ORDER BY year, month
);

DROP TABLE IF EXISTS churn_by_month_count_and_percent_change;
CREATE TEMP TABLE churn_by_month_count_and_percent_change AS (
  SELECT
    EXTRACT(YEAR FROM start_date) AS year,
    EXTRACT(MONTH FROM start_date) AS month,
    COUNT(DISTINCT customer_id) AS churned_users
  FROM foodie_fi.subscriptions
  WHERE plan_id = 4
  GROUP BY year, month
);

DROP TABLE IF EXISTS temp_next_day;
CREATE TEMP TABLE temp_next_day AS (
    SELECT
        customer_id,
        start_date, 
        LEAD(start_date, 1) OVER (PARTITION BY customer_id ORDER BY start_date) AS next_start_date,
        plan_id
    FROM 
        foodie_fi.subscriptions
);

DROP TABLE IF EXISTS revenue;
CREATE TEMP TABLE revenue AS (
WITH RECURSIVE missing_monthly_plans AS (
  SELECT
    customer_id,
    start_date,
    CASE
        WHEN (start_date + INTERVAL '1 month') <= next_start_date 
        THEN
  		  COALESCE(
          start_date + INTERVAL '1 month',
          DATE_TRUNC('MONTH', next_start_date) - INTERVAL '1 day'
        )
        ELSE next_start_date
    END AS end_day,
    plan_id
  FROM 
    temp_next_day
  WHERE
    next_start_date IS NOT NULL AND
    plan_id IN (1, 2) -- IN ('basic monthly', 'pro monthly')
  
  UNION ALL

  SELECT 
    customer_id,
    (start_date + INTERVAL '1 month')::DATE AS start_date,
    end_day,
    plan_id
  FROM 
    missing_monthly_plans
  WHERE
    start_date::DATE < end_day
),
months_by_payment AS (
 SELECT 
      customer_id, start_date, plan_id
  FROM 
      missing_monthly_plans
  UNION
  SELECT 
      customer_id, start_date, plan_id
  FROM 
      foodie_fi.subscriptions
),
payment_plans AS (
  SELECT
    customer_id,
    m.plan_id,
    p.plan_name,
    m.start_date AS payment_date,
    CASE
      WHEN
        (
          LAG(m.plan_id) OVER (PARTITION BY m.customer_id ORDER BY m.start_date) = 1
          AND m.plan_id IN (2, 3)
        )
      THEN
        p.price - LAG(p.price) OVER (PARTITION BY m.customer_id ORDER BY m.start_date)
      ELSE
        p.price
    END AS amount,
    ROW_NUMBER() OVER (PARTITION BY m.customer_id ORDER BY m.start_date) AS payment_order
  FROM
    months_by_payment m
  JOIN
    foodie_fi.plans p ON p.plan_id = m.plan_id
)
SELECT
  EXTRACT(YEAR FROM payment_date) AS year,
  EXTRACT(MONTH FROM payment_date) AS month,
  SUM(amount) as revenue_USD
FROM payment_plans AS p
GROUP BY year, month
ORDER BY year, month
);
 
SELECT
  au.*,
  cm.churned_users,
  CASE
    WHEN au.active_users IS NOT NULL AND cm.churned_users IS NOT NULL THEN
      ROUND(
        ((au.active_users::DECIMAL / LAG(au.active_users, 1) OVER (ORDER BY au.year, au.month)) - 1.0) * 100,
        2
      )
    ELSE NULL
  END AS "%_monthly_user_growth",
  CASE
    WHEN au.active_users IS NOT NULL THEN
      ROUND(
        (cm.churned_users::DECIMAL / au.active_users)::DECIMAL * 100,
        2
      )
    ELSE NULL
  END AS "%_churn_rate",
  revenue_USD,
  CASE
    WHEN r.revenue_USD IS NOT NULL THEN
      ROUND(
        ((r.revenue_USD::DECIMAL / LAG(r.revenue_USD, 1) OVER (ORDER BY au.year, au.month)) - 1.0) * 100,
        2
      )
    ELSE NULL
  END AS "%_monthly_revenue_growth"
FROM
  active_users_by_month au
JOIN
  churn_by_month_count_and_percent_change cm ON au.year = cm.year AND au.month = cm.month
JOIN
  revenue r ON r.year = cm.year AND r.month = cm.month
;


/*
| year | month | active_users | churned_users | %_monthly_user_growth | %_churn_rate | revenue_usd | %_monthly_revenue_growth |
|------|-------|--------------|---------------|-----------------------|--------------|-------------|--------------------------|
| 2020 | 1     | 79           | 9             |                       | 11,39        | 1272,1      |                          |
| 2020 | 2     | 138          | 9             | 74,68                 | 6,52         | 2395,2      | 88,29                    |
| 2020 | 3     | 219          | 13            | 58,7                  | 5,94         | 3051,5      | 27,4                     |
| 2020 | 4     | 282          | 18            | 28,77                 | 6,38         | 3757,7      | 23,14                    |
| 2020 | 5     | 349          | 21            | 23,76                 | 6,02         | 4324,7      | 15,09                    |
| 2020 | 6     | 409          | 19            | 17,19                 | 4,65         | 5011,4      | 15,88                    |
| 2020 | 7     | 470          | 28            | 14,91                 | 5,96         | 5808        | 15,9                     |
| 2020 | 8     | 545          | 13            | 15,96                 | 2,39         | 6763,4      | 16,45                    |
| 2020 | 9     | 609          | 23            | 11,74                 | 3,78         | 6952,3      | 2,79                     |
| 2020 | 10    | 662          | 26            | 8,7                   | 3,93         | 8147,3      | 17,19                    |
| 2020 | 11    | 705          | 32            | 6,5                   | 4,54         | 5658,6      | -30,55                   |
| 2020 | 12    | 764          | 25            | 8,37                  | 3,27         | 5718,6      | 1,06                     |
| 2021 | 1     | 745          | 19            | -2,49                 | 2,55         | 5671        | -0,83                    |
| 2021 | 2     | 727          | 18            | -2,42                 | 2,48         | 3622,5      | -36,12                   |
| 2021 | 3     | 706          | 21            | -2,89                 | 2,97         | 1921,3      | -46,96                   |
| 2021 | 4     | 693          | 13            | -1,84                 | 1,88         | 2696,9      | 40,37                    |
*/

WITH RECURSIVE missing_monthly_plans AS (
  SELECT
    customer_id,
    start_date,
    CASE
        WHEN (start_date + INTERVAL '1 month') <= next_start_date 
        THEN
  		  COALESCE(
          start_date + INTERVAL '1 month',
          DATE_TRUNC('MONTH', next_start_date) - INTERVAL '1 day'
        )
        ELSE next_start_date
    END AS end_day,
    plan_id
  FROM 
    temp_next_day
  WHERE
    next_start_date IS NOT NULL AND
    plan_id IN (1, 2) -- IN ('basic monthly', 'pro monthly')
  
  UNION ALL

  SELECT 
    customer_id,
    (start_date + INTERVAL '1 month')::DATE AS start_date,
    end_day,
    plan_id
  FROM 
    missing_monthly_plans
  WHERE
    start_date::DATE < end_day
),
months_by_payment AS (
 SELECT 
      customer_id, start_date, plan_id
  FROM 
      missing_monthly_plans
  UNION
  SELECT 
      customer_id, start_date, plan_id
  FROM 
      foodie_fi.subscriptions
),
payment_plans AS (
  SELECT
    customer_id,
    m.plan_id,
    p.plan_name,
    m.start_date AS payment_date,
    CASE
      WHEN
        (
          LAG(m.plan_id) OVER (PARTITION BY m.customer_id ORDER BY m.start_date) = 1
          AND m.plan_id IN (2, 3)
        )
      THEN
        p.price - LAG(p.price) OVER (PARTITION BY m.customer_id ORDER BY m.start_date)
      ELSE
        p.price
    END AS amount,
    ROW_NUMBER() OVER (PARTITION BY m.customer_id ORDER BY m.start_date) AS payment_order
  FROM
    months_by_payment m
  JOIN
    foodie_fi.plans p ON p.plan_id = m.plan_id
),
clv_per_customer AS (
  SELECT
    p.customer_id,
    SUM(p.amount) AS clv
  FROM payment_plans p
  JOIN foodie_fi.subscriptions s ON p.customer_id = s.customer_id
  WHERE s.start_date >= (SELECT MIN(start_date) FROM foodie_fi.subscriptions)
  GROUP BY p.customer_id
)
SELECT
  'CLV 9.90' AS clv_range,
  COUNT(*) AS count_customers
FROM clv_per_customer
WHERE clv = 9.90

UNION ALL

SELECT
  'CLV 9.90 - 19.90' AS clv_range,
  COUNT(*) AS count_customers
FROM clv_per_customer
WHERE clv >= 9.90 AND clv <= 19.90

UNION ALL

SELECT
  'CLV 19.90 - 199' AS clv_range,
  COUNT(*) AS count_customers
FROM clv_per_customer
WHERE clv > 19.90 AND clv <= 199

UNION ALL

SELECT
  'CLV 199 - 600' AS clv_range,
  COUNT(*) AS count_customers
FROM clv_per_customer
WHERE clv > 199 AND clv <= 600

UNION ALL

SELECT
  'CLV 600 - 1000 ' AS clv_range,
  COUNT(*) AS count_customers
FROM clv_per_customer
WHERE clv > 600 AND clv <= 1000

UNION ALL

SELECT
  'CLV > 1000 ' AS clv_range,
  COUNT(*) AS count_customers
FROM clv_per_customer
WHERE clv > 1000;

/*
clv_range 	count_customers
CLV 9.90 	0
CLV 9.90 - 19.90 	120
CLV 19.90 - 199 	510
CLV 199 - 600 	111
CLV 600 - 1000 	140
CLV > 1000 	10
*/
