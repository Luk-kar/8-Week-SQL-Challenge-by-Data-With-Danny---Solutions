/*
How many customers have churned straight after their initial free trial
 - what percentage is this rounded to the nearest whole number?
*/

WITH churn_cases AS (
    SELECT DISTINCT
  		customer_id,
        CASE 
            WHEN LAG(plan_name) OVER (PARTITION BY customer_id ORDER BY start_date) = 'trial'
                 AND plan_name = 'churn'
            THEN 1
            ELSE 0
        END AS churn_after_trial_case
    FROM foodie_fi.subscriptions AS subscriptions
    JOIN foodie_fi.plans AS plans ON plans.plan_id = subscriptions.plan_id
)
SELECT 
    SUM(churn_after_trial_case) AS churned,
	ROUND((SUM(churn_after_trial_case)::DECIMAL / COUNT(DISTINCT customer_id)::DECIMAL) * 100, 1) AS "total churn %"
FROM churn_cases
;

/*
| churned | total churn % |
|---------|---------------|
| 92      | 9,2           |
*/ 