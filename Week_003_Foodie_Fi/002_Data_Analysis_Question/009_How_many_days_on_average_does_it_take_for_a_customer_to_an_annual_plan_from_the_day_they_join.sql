/*
How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
*/
WITH pro_annual_registrations AS (
    SELECT
        customer_id,
        start_date,
        plan_name
    FROM foodie_fi.subscriptions
    JOIN foodie_fi.plans ON plans.plan_id = subscriptions.plan_id
    WHERE plan_name IN ('trial', 'pro annual')
),
days_from_trail_to_pro_annual AS (
  SELECT
      *,
      CASE 
        WHEN LAG(start_date) OVER (PARTITION BY customer_id ORDER BY start_date) IS NULL THEN NULL
        ELSE start_date - (LAG(start_date) OVER (PARTITION BY customer_id ORDER BY start_date))
      END AS days_to_upgrade_since_trial
  FROM 
      pro_annual_registrations
)
SELECT
	ROUND(AVG(days_to_upgrade_since_trial)) AS "average days from trial to pro annual"
FROM
	days_from_trail_to_pro_annual

/*
average days from trial to pro annual
105
*/

WITH annual_plan AS (
  SELECT
    customer_id,
    start_date,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY start_date) AS rank_plan
  FROM foodie_fi.subscriptions
  WHERE plan_id = 3
),
trial AS (
  SELECT
    customer_id,
    start_date,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY start_date) AS rank_plan
  FROM foodie_fi.subscriptions
  WHERE plan_id = 0
)
SELECT
  ROUND(AVG(
    (annual_plan.start_date::DATE - trial.start_date::DATE)
  )) AS "average days from trial to pro annual"
FROM annual_plan
INNER JOIN trial ON annual_plan.customer_id = trial.customer_id
WHERE annual_plan.rank_plan = 1 AND trial.rank_plan = 1
;
