/*
The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer in the subscriptions table with the following requirements:

    monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
    upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
    upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
    once a customer churns they will no longer make payments

Example outputs for this table might look like the following:
*/

/*
customer_id 	plan_id 	plan_name 	payment_date 	amount 	payment_order
1 	1 	basic monthly 	2020-08-08 	9.90 	1
1 	1 	basic monthly 	2020-09-08 	9.90 	2
1 	1 	basic monthly 	2020-10-08 	9.90 	3
1 	1 	basic monthly 	2020-11-08 	9.90 	4
1 	1 	basic monthly 	2020-12-08 	9.90 	5
*/

WITH lead_plans AS (
SELECT
  customer_id,
  plan_id,
  start_date,
  LEAD(plan_id) OVER (
      PARTITION BY customer_id
      ORDER BY start_date
    ) AS lead_plan_id,
  LEAD(start_date) OVER (
      PARTITION BY customer_id
      ORDER BY start_date
    ) AS lead_start_date
FROM foodie_fi.subscriptions
WHERE DATE_PART('year', start_date) < 2021
AND plan_id != 0
)
SELECT
  plan_id,
  lead_plan_id,
  COUNT(*) AS transition_count
FROM lead_plans
GROUP BY plan_id, lead_plan_id
ORDER BY plan_id, lead_plan_id;

/*
plan_id 	lead_plan_id 	transition_count
1 	2 	163
1 	3 	88
1 	4 	63
1 	null 	224
*/

/*
plan_id 	lead_plan_id 	transition_count
2 	3 	70
2 	4 	83
2 	null 	326
*/

/*
plan_id 	lead_plan_id 	transition_count
3 	null 	195
4 	null 	236
*/

-- first generate the lead plans as above
WITH lead_plans AS (
SELECT
  customer_id,
  plan_id,
  start_date,
  LEAD(plan_id) OVER (
      PARTITION BY customer_id
      ORDER BY start_date
    ) AS lead_plan_id,
  LEAD(start_date) OVER (
      PARTITION BY customer_id
      ORDER BY start_date
    ) AS lead_start_date
FROM foodie_fi.subscriptions
WHERE DATE_PART('year', start_date) < 2021
AND plan_id != 0
),
-- case 1: non churn monthly customers
case_1 AS (
SELECT
  customer_id,
  plan_id,
  start_date,
  DATE_PART('month', AGE('2020-12-31'::DATE, start_date))::INTEGER AS month_diff
FROM lead_plans
WHERE lead_plan_id is null
-- not churn and not annual customers
AND plan_id NOT IN (3, 4)
),
-- generate a series to add the months to each start_date
case_1_payments AS (
  SELECT
    customer_id,
    plan_id,
    (start_date + GENERATE_SERIES(0, month_diff) * INTERVAL '1 month')::DATE AS start_date
  FROM case_1
),
-- case 2: churn customers
case_2 AS (
  SELECT
    customer_id,
    plan_id,
    start_date,
    DATE_PART('month', AGE(lead_start_date - 1, start_date))::INTEGER AS month_diff
  FROM lead_plans
  -- churn accounts only
  WHERE lead_plan_id = 4
),
case_2_payments AS (
  SELECT
    customer_id,
    plan_id,
    (start_date + GENERATE_SERIES(0, month_diff) * INTERVAL '1 month')::DATE AS start_date
  from case_2
),
-- case 3: customers who move from basic to pro plans
case_3 AS (
  SELECT
    customer_id,
    plan_id,
    start_date,
    DATE_PART('month', AGE(lead_start_date - 1, start_date))::INTEGER AS month_diff
  FROM lead_plans
  WHERE plan_id = 1 AND lead_plan_id IN (2, 3)
),
case_3_payments AS (
  SELECT
    customer_id,
    plan_id,
    (start_date + GENERATE_SERIES(0, month_diff) * INTERVAL '1 month')::DATE AS start_date
  from case_3
),
-- case 4: pro monthly customers who move up to annual plans
case_4 AS (
  SELECT
    customer_id,
    plan_id,
    start_date,
    DATE_PART('month', AGE(lead_start_date - 1, start_date))::INTEGER AS month_diff
  FROM lead_plans
  WHERE plan_id = 2 AND lead_plan_id = 3
),
case_4_payments AS (
  SELECT
    customer_id,
    plan_id,
    (start_date + GENERATE_SERIES(0, month_diff) * INTERVAL '1 month')::DATE AS start_date
  from case_4
),
-- case 5: annual pro payments
case_5_payments AS (
  SELECT
    customer_id,
    plan_id,
    start_date
  FROM lead_plans
  WHERE plan_id = 3
),
-- union all where we union all parts
union_output AS (
  SELECT * FROM case_1_payments
UNION
  SELECT * FROM case_2_payments
UNION
  SELECT * FROM case_3_payments
UNION
  SELECT * FROM case_4_payments
UNION
  SELECT * FROM case_5_payments
)
SELECT
  customer_id,
  plans.plan_id,
  plans.plan_name,
  start_date AS payment_date,
  -- price deductions are applied here
  CASE
    WHEN union_output.plan_id IN (2, 3) AND
      LAG(union_output.plan_id) OVER w = 1
    THEN plans.price - 9.90
    ELSE plans.price
    END AS amount,
  RANK() OVER w AS payment_order
FROM union_output
INNER JOIN foodie_fi.plans
  ON union_output.plan_id = plans.plan_id
-- where filter for outputs for testing
WHERE customer_id IN (1, 2, 7, 11, 13, 15, 16, 18, 19, 25, 39)
WINDOW w AS (
  PARTITION BY union_output.customer_id
  ORDER BY start_date
);

/*
| customer_id | plan_id | plan_name     | payment_date             | amount | payment_order |
|-------------|---------|---------------|--------------------------|--------|---------------|
| 1           | 1       | basic monthly | 2020-08-08T00:00:00.000Z | 9,9    | 1             |
| 1           | 1       | basic monthly | 2020-09-08T00:00:00.000Z | 9,9    | 2             |
| 1           | 1       | basic monthly | 2020-10-08T00:00:00.000Z | 9,9    | 3             |
| 1           | 1       | basic monthly | 2020-11-08T00:00:00.000Z | 9,9    | 4             |
| 1           | 1       | basic monthly | 2020-12-08T00:00:00.000Z | 9,9    | 5             |
| 2           | 3       | pro annual    | 2020-09-27T00:00:00.000Z | 199    | 1             |
| 7           | 1       | basic monthly | 2020-02-12T00:00:00.000Z | 9,9    | 1             |
| 7           | 1       | basic monthly | 2020-03-12T00:00:00.000Z | 9,9    | 2             |
| 7           | 1       | basic monthly | 2020-04-12T00:00:00.000Z | 9,9    | 3             |
| 7           | 1       | basic monthly | 2020-05-12T00:00:00.000Z | 9,9    | 4             |
| 7           | 2       | pro monthly   | 2020-05-22T00:00:00.000Z | 10     | 5             |
| 7           | 2       | pro monthly   | 2020-06-22T00:00:00.000Z | 19,9   | 6             |
| 7           | 2       | pro monthly   | 2020-07-22T00:00:00.000Z | 19,9   | 7             |
| 7           | 2       | pro monthly   | 2020-08-22T00:00:00.000Z | 19,9   | 8             |
| 7           | 2       | pro monthly   | 2020-09-22T00:00:00.000Z | 19,9   | 9             |
| 7           | 2       | pro monthly   | 2020-10-22T00:00:00.000Z | 19,9   | 10            |
| 7           | 2       | pro monthly   | 2020-11-22T00:00:00.000Z | 19,9   | 11            |
| 7           | 2       | pro monthly   | 2020-12-22T00:00:00.000Z | 19,9   | 12            |
| 13          | 1       | basic monthly | 2020-12-22T00:00:00.000Z | 9,9    | 1             |
| 15          | 2       | pro monthly   | 2020-03-24T00:00:00.000Z | 19,9   | 1             |
| 15          | 2       | pro monthly   | 2020-04-24T00:00:00.000Z | 19,9   | 2             |
| 16          | 1       | basic monthly | 2020-06-07T00:00:00.000Z | 9,9    | 1             |
| 16          | 1       | basic monthly | 2020-07-07T00:00:00.000Z | 9,9    | 2             |
| 16          | 1       | basic monthly | 2020-08-07T00:00:00.000Z | 9,9    | 3             |
...
*/