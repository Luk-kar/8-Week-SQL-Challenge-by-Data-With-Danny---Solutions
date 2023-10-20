/*
How many customers have upgraded to an annual plan in 2020?
*/

WITH pro_annual_registrations AS (
    SELECT DISTINCT
        customer_id,
        plan_name
    FROM foodie_fi.subscriptions AS subscriptions
    JOIN foodie_fi.plans AS plans ON plans.plan_id = subscriptions.plan_id
    WHERE 
  		start_date >= '2020-01-01'AND
  		start_date < '2021-01-01' AND
  		plan_name = 'pro annual'
)
SELECT
    COUNT(*) AS "upgrades to pro annual in 2020"
FROM 
    pro_annual_registrations

/*
upgrades to pro annual in 2020
195
*/

SELECT
  COUNT(DISTINCT customer_id) AS "upgrades to pro annual in 2020"
FROM foodie_fi.subscriptions
WHERE plan_id = 3 AND
  		start_date >= '2020-01-01'AND
  		start_date < '2021-01-01'
;