-- 5.What is the percentage of visits which have a purchase event?

WITH purchase_count AS (
    SELECT
        COUNT(*) AS purchase_count
    FROM clique_bait.events
    WHERE event_type = 3
)
SELECT
    purchase_count,
    ROUND(((purchase_count::DECIMAL / COUNT(*)) * 100, 2) AS purchase_percent
FROM clique_bait.events
CROSS JOIN purchase_count
;

-- faster

WITH cte_visits_with_purchase_flag AS (
  SELECT
    visit_id,
    MAX(CASE WHEN event_type = 3 THEN 1 ELSE 0 END) AS purchase_flag --smart efficient way
  FROM clique_bait.events
  GROUP BY visit_id
)
SELECT
  ROUND(SUM(purchase_flag)::DECIMAL / COUNT(*) * 100, 2) AS purchase_percentage
FROM cte_visits_with_purchase_flag;