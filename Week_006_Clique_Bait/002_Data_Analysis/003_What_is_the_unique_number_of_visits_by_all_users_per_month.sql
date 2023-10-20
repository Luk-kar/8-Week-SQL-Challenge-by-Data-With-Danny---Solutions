-- 3.What is the unique number of visits by all users per month?

SELECT 
    DATE_TRUNC('month', event_time) AS _month
    COUNT(visit_id) AS unique_visit_count
FROM clique_bait.events
GROUP BY _month
ORDER BY _month
;