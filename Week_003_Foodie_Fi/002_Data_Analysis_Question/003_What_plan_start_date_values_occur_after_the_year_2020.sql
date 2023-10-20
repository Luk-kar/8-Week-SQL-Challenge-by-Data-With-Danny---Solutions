/*
What plan start_date values occur after the year 2020 for our dataset?
Show the breakdown by count of events for each plan_name
*/

SELECT
  plans.plan_id,
  plan_name,
  COUNT(*) AS events
FROM foodie_fi.subscriptions
INNER JOIN foodie_fi.plans
  ON foodie_fi.subscriptions.plan_id = plans.plan_id
WHERE start_date >= '2021-01-01'
GROUP BY plan_name, plans.plan_id
ORDER BY plan_id
;

/*
| plan_id | plan_name     | events |
|---------|---------------|--------|
| 1       | basic monthly | 8      |
| 2       | pro monthly   | 60     |
| 3       | pro annual    | 63     |
| 4       | churn         | 71     |
*/