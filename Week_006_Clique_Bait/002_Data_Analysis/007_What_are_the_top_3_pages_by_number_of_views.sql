-- 7.What are the top 3 pages by number of views?

SELECT
    page_name,
    COUNT(*) AS _count
FROM clique_bait.events
LEFT JOIN clique_bait.page_hierarchy ON events.page_id = page_hierarchy.page_id
WHERE event_type = 1
GROUP BY page_name
ORDER BY _count DESC
LIMIT 3
