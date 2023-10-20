/*
Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
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
),
"30_days_periods" AS (
  SELECT
    CONCAT(
      LPAD((CEIL(days_to_upgrade_since_trial::DECIMAL / 30.0) * 30 - 30)::TEXT, 3, ' '), 
      ' - ',
      CEIL(days_to_upgrade_since_trial::DECIMAL / 30.0) * 30
		) AS periods,
		CEIL(days_to_upgrade_since_trial::DECIMAL / 30.0) AS row_number
  FROM
      days_from_trail_to_pro_annual
  WHERE
      days_to_upgrade_since_trial IS NOT NULL
)
SELECT
	periods,
	COUNT(*) AS "days from registration to get pro annual plan"
FROM
	"30_days_periods"
GROUP BY
	periods, row_number
ORDER BY
	row_number
	
/*
| periods   | days from registration to get pro annual plan |
|-----------|-----------------------------------------------|
|   0 - 30  | 49                                            |
|  30 - 60  | 24                                            |
|  60 - 90  | 34                                            |
|  90 - 120 | 35                                            |
| 120 - 150 | 42                                            |
| 150 - 180 | 36                                            |
| 180 - 210 | 26                                            |
| 210 - 240 | 4                                             |
| 240 - 270 | 5                                             |
| 270 - 300 | 1                                             |
| 300 - 330 | 1                                             |
| 330 - 360 | 1                                             |
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
),
annual_days AS (
  SELECT
    annual_plan.start_date::DATE - trial.start_date::DATE AS duration
  FROM annual_plan
  INNER JOIN trial ON annual_plan.customer_id = trial.customer_id
  WHERE annual_plan.rank_plan = 1 AND trial.rank_plan = 1
),
breakdown_periods AS (
  SELECT
    (CEIL(duration::DECIMAL / 30.0) * 30 - 30) || ' - ' || CEIL(duration::DECIMAL / 30.0) * 30 AS breakdown_period,
  	CEIL(duration::DECIMAL / 30.0) AS row_number,
    COUNT(*) AS customers
  FROM annual_days
  GROUP BY breakdown_period, row_number

)
SELECT
  breakdown_period,
  customers
FROM breakdown_periods
ORDER BY breakdown_period;
