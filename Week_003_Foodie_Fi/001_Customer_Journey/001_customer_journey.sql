-- This case study is split into an initial data understanding question before 
-- diving straight into data analysis questions before finishing with 1 single extension challenge.

SELECT 
  customer_id,
  start_date,
  plan_name,
  price,
  CASE 
    WHEN LEAD(start_date) OVER (PARTITION BY customer_id ORDER BY start_date) IS NULL THEN NULL
    ELSE 
      LEAD(start_date) OVER (PARTITION BY customer_id ORDER BY start_date) - start_date
  END AS plan_days,
  EXTRACT('month' FROM AGE(LEAD(start_date) OVER (PARTITION BY customer_id ORDER BY start_date), start_date)) AS plan_months,
  ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY start_date) - 1 AS plan_change
FROM foodie_fi.subscriptions
JOIN foodie_fi.plans ON plans.plan_id = subscriptions.plan_id
WHERE customer_id = ANY(ARRAY(SELECT GENERATE_SERIES(1, 8)))
ORDER BY customer_id, start_date
;

/*
| customer_id | start_date               | plan_name     | price  | plan_days | plan_months | plan_change |
| ----------- | ------------------------ | ------------- | ------ | --------- | ----------- | ----------- |
| 1           | 2020-08-01T00:00:00.000Z | trial         | 0.00   | 7         | 0           | 0           |
| 1           | 2020-08-08T00:00:00.000Z | basic monthly | 9.90   |           |             | 1           |
| 2           | 2020-09-20T00:00:00.000Z | trial         | 0.00   | 7         | 0           | 0           |
| 2           | 2020-09-27T00:00:00.000Z | pro annual    | 199.00 |           |             | 1           |
| 3           | 2020-01-13T00:00:00.000Z | trial         | 0.00   | 7         | 0           | 0           |
| 3           | 2020-01-20T00:00:00.000Z | basic monthly | 9.90   |           |             | 1           |
| 4           | 2020-01-17T00:00:00.000Z | trial         | 0.00   | 7         | 0           | 0           |
| 4           | 2020-01-24T00:00:00.000Z | basic monthly | 9.90   | 88        | 2           | 1           |
| 4           | 2020-04-21T00:00:00.000Z | churn         |        |           |             | 2           |
| 5           | 2020-08-03T00:00:00.000Z | trial         | 0.00   | 7         | 0           | 0           |
| 5           | 2020-08-10T00:00:00.000Z | basic monthly | 9.90   |           |             | 1           |
| 6           | 2020-12-23T00:00:00.000Z | trial         | 0.00   | 7         | 0           | 0           |
| 6           | 2020-12-30T00:00:00.000Z | basic monthly | 9.90   | 58        | 1           | 1           |
| 6           | 2021-02-26T00:00:00.000Z | churn         |        |           |             | 2           |
| 7           | 2020-02-05T00:00:00.000Z | trial         | 0.00   | 7         | 0           | 0           |
| 7           | 2020-02-12T00:00:00.000Z | basic monthly | 9.90   | 100       | 3           | 1           |
| 7           | 2020-05-22T00:00:00.000Z | pro monthly   | 19.90  |           |             | 2           |
| 8           | 2020-06-11T00:00:00.000Z | trial         | 0.00   | 7         | 0           | 0           |
| 8           | 2020-06-18T00:00:00.000Z | basic monthly | 9.90   | 46        | 1           | 1           |
| 8           | 2020-08-03T00:00:00.000Z | pro monthly   | 19.90  |           |             | 2           |
*/

-- The Journey

/*
Based on the 8 customers sample.

Five customers started with a trial period of 1 week and then switched to the basic monthly plan, which they are still on until today.
Five customers started with a trial period of 1 week and then switched yearly pro plan, which they are still on until today.
One customer churned after subscribing to the basic monthly plan for 2 months (88 days).
One customer churned after subscribing to the basic plan for 1 month (58 days).
One customer stayed on the basic plan for 3 months and then upgraded to the pro monthly plan.
Another customer started with the trial period, then upgraded to the pro monthly plan after 1 month on basic monthly.
*/