-- 6.What is the percentage of visits which view the checkout page but do not have a purchase event?

-- A
WITH events_count AS (
    SELECT
        MAX(CASE WHEN event_type = 1 AND page_id = 12 THEN 1 ELSE 0 END) AS checkout_flag,
        MAX(CASE WHEN event_type = 3 THEN 1 ELSE 0 END) AS purchase_flag
    FROM clique_bait.events
    GROUP BY visit_id
)
SELECT
    ROUND(
        (SUM(CASE WHEN purchase_flag = 0 THEN 1 ELSE 0)::DECIMAL / COUNT(*)) * 100,
        2) AS checkout_but_not_purchase_%
FROM events_count
WHERE checkout_flag = 1
;

