/*
What is the customer count and percentage breakdown 
of all 5 plan_name values at 2020-12-31?
*/

WITH selected_period AS (
    SELECT
        customer_id,
        start_date,
        plan_name,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY start_date DESC) AS rn
    FROM foodie_fi.subscriptions AS subscriptions
    JOIN foodie_fi.plans AS plans ON plans.plan_id = subscriptions.plan_id
    WHERE start_date <= '2020-12-31'
),
last_plan AS (
  SELECT
      CASE WHEN plan_name = 'trial' THEN 1 ELSE 0 END AS trial,
      CASE WHEN plan_name = 'basic monthly' THEN 1 ELSE 0 END AS basic_monthly,
      CASE WHEN plan_name = 'pro monthly' THEN 1 ELSE 0 END AS pro_monthly,
      CASE WHEN plan_name = 'pro annual' THEN 1 ELSE 0 END AS pro_annual,
      CASE WHEN plan_name = 'churn' THEN 1 ELSE 0 END AS churn
  FROM 
      selected_period
  WHERE
    rn = 1
)
SELECT
    'trial' AS plan_name,
    SUM(trial) AS count,
    ROUND(100.0 * SUM(trial) / COUNT(*), 2) AS percent
FROM
    last_plan
UNION ALL
SELECT
    'basic monthly' AS plan_name,
    SUM(basic_monthly) AS count,
    ROUND(100.0 * SUM(basic_monthly) / COUNT(*), 2) AS percent
FROM
    last_plan
UNION ALL
SELECT
    'pro monthly' AS plan_name,
    SUM(pro_monthly) AS count,
    ROUND(100.0 * SUM(pro_monthly) / COUNT(*), 2) AS percent
FROM
    last_plan
UNION ALL
SELECT
    'pro annual' AS plan_name,
    SUM(pro_annual) AS count,
    ROUND(100.0 * SUM(pro_annual) / COUNT(*), 2) AS percent
FROM
    last_plan
UNION ALL
SELECT
    'churn' AS plan_name,
    SUM(churn) AS count,
    ROUND(100.0 * SUM(churn) / COUNT(*), 2) AS percent
FROM
    last_plan
;

/*
| plan_name     | count | percent |
|---------------|-------|---------|
| trial         | 19    | 1,9     |
| basic monthly | 224   | 22,4    |
| pro monthly   | 326   | 32,6    |
| pro annual    | 195   | 19,5    |
| churn         | 236   | 23,6    |
*/

WITH valid_subscriptions AS (
  SELECT
    customer_id,
    plan_id,
    start_date,
    ROW_NUMBER() OVER (
      PARTITION BY customer_id
      ORDER BY start_date DESC
    ) AS plan_rank
  FROM foodie_fi.subscriptions
  WHERE start_date <= '2020-12-31'
),
summarised_plans AS (
  SELECT
    plan_id,
    COUNT(DISTINCT customer_id) AS customers
  FROM valid_subscriptions
  WHERE plan_rank = 1
  GROUP BY plan_id
)
SELECT
  plans.plan_id,
  plans.plan_name,
  customers,
  ROUND(
    100 * customers /
    SUM(customers) OVER (),
    1
  ) AS percentage
FROM summarised_plans
INNER JOIN foodie_fi.plans
  ON summarised_plans.plan_id = plans.plan_id
ORDER BY plans.plan_id;

/*
| plan_id | plan_name     | customers | percentage |
|---------|---------------|-----------|------------|
| 0       | trial         | 19        | 1,9        |
| 1       | basic monthly | 224       | 22,4       |
| 2       | pro monthly   | 326       | 32,6       |
| 3       | pro annual    | 195       | 19,5       |
| 4       | churn         | 236       | 23,6       |
*/