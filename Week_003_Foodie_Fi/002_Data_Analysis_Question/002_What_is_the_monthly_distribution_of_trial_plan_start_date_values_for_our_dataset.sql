-- What is the monthly distribution of trial plan start_date values for our dataset 
--  - use the start of the month as the group by value

SELECT 
  TO_CHAR(start_date, 'YYYY-MM') AS month,
  COUNT(*)
FROM foodie_fi.subscriptions
JOIN foodie_fi.plans ON plans.plan_id = subscriptions.plan_id
WHERE plan_name = 'trial'
GROUP BY month
ORDER BY month
;

/*
month 	trials_started
2020-01 	88
2020-02 	68
2020-03 	94
2020-04 	81
2020-05 	88
2020-06 	79
2020-07 	89
2020-08 	88
2020-09 	87
2020-10 	79
2020-11 	75
2020-12 	84
*/