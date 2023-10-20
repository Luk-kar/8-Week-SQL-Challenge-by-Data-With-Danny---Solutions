/*
How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
*/

WITH ranked_plans AS (
SELECT
  customer_id,
  plan_id,
  start_date,
  LAG(plan_id) OVER (
      PARTITION BY customer_id
      ORDER BY start_date
  ) AS lag_plan_id
FROM foodie_fi.subscriptions
)
SELECT
  COUNT(DISTINCT customer_id)
FROM ranked_plans
WHERE lag_plan_id = 1 AND plan_id = 2
AND DATE_PART('year', start_date) = 2020
;

/*
count
163
*/