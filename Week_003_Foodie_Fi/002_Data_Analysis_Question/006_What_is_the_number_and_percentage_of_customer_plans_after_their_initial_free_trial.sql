/*
What is the number and percentage of customer plans after their initial free trial?
*/

/*
How many customers have churned straight after their initial free trial
 - what percentage is this rounded to the nearest whole number?
*/

WITH after_trial_plans_count AS (
    SELECT DISTINCT
  		customer_id,
      CASE 
          WHEN LAG(plan_name) OVER (PARTITION BY customer_id ORDER BY start_date) = 'trial'
               AND plan_name = 'basic monthly'
          THEN 1
          ELSE 0
      END AS after_trial_basic_monthly,
  		CASE 
            WHEN LAG(plan_name) OVER (PARTITION BY customer_id ORDER BY start_date) = 'trial'
                 AND plan_name = 'pro monthly'
            THEN 1
            ELSE 0
        END AS after_trial_pro_monthly,
    	CASE 
            WHEN LAG(plan_name) OVER (PARTITION BY customer_id ORDER BY start_date) = 'trial'
                 AND plan_name = 'pro annual'
            THEN 1
            ELSE 0
      END AS after_trial_pro_annual,
      CASE 
          WHEN LAG(plan_name) OVER (PARTITION BY customer_id ORDER BY start_date) = 'trial'
               AND plan_name = 'churn'
          THEN 1
          ELSE 0
      END AS after_trial_churn
    FROM foodie_fi.subscriptions AS subscriptions
    JOIN foodie_fi.plans AS plans ON plans.plan_id = subscriptions.plan_id
)
SELECT 
	ROUND((SUM(after_trial_basic_monthly)::DECIMAL / (COUNT(DISTINCT customer_id) - SUM(after_trial_churn))::DECIMAL) * 100, 2) AS "basic monthly %",
    ROUND((SUM(after_trial_pro_monthly)::DECIMAL / (COUNT(DISTINCT customer_id) - SUM(after_trial_churn))::DECIMAL) * 100, 2) AS "pro monthly %",
    ROUND((SUM(after_trial_pro_annual)::DECIMAL / (COUNT(DISTINCT customer_id) - SUM(after_trial_churn))::DECIMAL) * 100, 2) AS "pro annual %"
FROM after_trial_plans_count
;

/*
| basic monthly % | pro monthly % | pro annual % |
|-----------------|---------------|--------------|
| 60.13           | 35.79         | 4.07         |
*/

WITH ranked_plans AS (
  SELECT
    customer_id,
    plan_id,
    ROW_NUMBER() OVER (
      PARTITION BY customer_id
      ORDER BY start_date
    ) AS plan_rank
  FROM foodie_fi.subscriptions
)
SELECT
  plans.plan_id,
  plans.plan_name,
  COUNT(*) AS customer_count,
  ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER ()) AS percentage
FROM ranked_plans
INNER JOIN foodie_fi.plans
  ON ranked_plans.plan_id = plans.plan_id
WHERE plan_rank = 2
GROUP BY plans.plan_id, plans.plan_name
ORDER BY plans.plan_id;

/*
| plan_id | plan_name     | customer_count | percentage |
|---------|---------------|----------------|------------|
| 1       | basic monthly | 546            | 55         |
| 2       | pro monthly   | 325            | 33         |
| 3       | pro annual    | 37             | 4          |
| 4       | churn         | 92             | 9          |
*/