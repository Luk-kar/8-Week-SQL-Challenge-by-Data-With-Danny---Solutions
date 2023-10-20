/*
What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
*/

WITH customer_id_churn_identity AS (
  SELECT
    customer_id,
    CASE WHEN plan_id = 4 THEN 1 ELSE 0 END AS churned
  FROM foodie_fi.subscriptions
  WHERE plan_id = 0 OR plan_id = 4
  GROUP BY customer_id, plan_id -- we assume that customer could be churned more than once
)
SELECT
  COUNT(DISTINCT customer_id) AS total_customers,
  SUM(churned) AS total_churned,
  ROUND((SUM(churned)::DECIMAL / COUNT(DISTINCT customer_id)::DECIMAL) * 100, 1) AS "churn_%_rate"
FROM customer_id_churn_identity
;

/*
| total_customers | total_churned | churn_%_rate |
|-----------------|---------------|--------------|
| 1000            | 307           | 30,7         |
*/

SELECT
  SUM(CASE WHEN plan_id = 4 THEN 1 ELSE 0 END) AS churn_customers,
  ROUND(
    (SUM(CASE WHEN plan_id = 4 THEN 1 ELSE 0 END)::DECIMAL /
    COUNT(DISTINCT customer_id))
    * 100,
    1
  ) AS percentage
FROM foodie_fi.subscriptions;

/*
| churn_customers | percentage |
|-----------------|------------|
| 307             | 30,7       |
*/