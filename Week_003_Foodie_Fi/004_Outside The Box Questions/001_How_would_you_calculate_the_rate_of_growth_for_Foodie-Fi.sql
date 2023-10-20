-- How would you calculate the rate of growth for Foodie-Fi?

/*
The change of active users
*/

WITH active_users_by_month AS (
  SELECT
    EXTRACT(YEAR FROM start_date) AS year,
    EXTRACT(MONTH FROM start_date) AS month,
    SUM(CASE WHEN plan_id = 0 THEN 1 ELSE 0 END) AS new_user,
    SUM(CASE WHEN plan_id = 4 THEN 1 ELSE 0 END) AS churn_user
  FROM foodie_fi.subscriptions
  WHERE plan_id IN (0, 4)
  GROUP BY year, month
),
active_users_monthly AS (
  SELECT
  	year,
  	month,
  	SUM(new_user) OVER (ORDER BY year, month) - SUM(churn_user) OVER (ORDER BY year, month) AS active_users
  FROM
  	active_users_by_month
  ORDER BY year, month
)
SELECT
  *,
  ROUND(((active_users::DECIMAL / (LAG(active_users) OVER (ORDER BY year, month))::DECIMAL) - 1) * 100, 2) AS growth_rate
FROM active_users_monthly

/*
| year | month | active_users | growth_rate |
|------|-------|--------------|-------------|
| 2020 | 1     | 79           |             |
| 2020 | 2     | 138          | 74,68       |
| 2020 | 3     | 219          | 58,7        |
| 2020 | 4     | 282          | 28,77       |
| 2020 | 5     | 349          | 23,76       |
| 2020 | 6     | 409          | 17,19       |
| 2020 | 7     | 470          | 14,91       |
| 2020 | 8     | 545          | 15,96       |
| 2020 | 9     | 609          | 11,74       |
| 2020 | 10    | 662          | 8,7         |
| 2020 | 11    | 705          | 6,5         |
| 2020 | 12    | 764          | 8,37        |
| 2021 | 1     | 745          | -2,49       |
| 2021 | 2     | 727          | -2,42       |
| 2021 | 3     | 706          | -2,89       |
| 2021 | 4     | 693          | -1,84       |
*/

