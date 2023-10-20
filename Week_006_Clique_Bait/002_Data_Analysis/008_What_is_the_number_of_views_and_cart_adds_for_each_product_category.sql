-- 8.What is the number of views and cart adds for each product category?

SELECT
    page_name AS product_name,
    SUM(CASE WHEN event_type = 1 THEN 0 ELSE 1 END) AS page_views,
    SUM(CASE WHEN event_type = 2 THEN 0 ELSE 1 END) AS cart_adds,
    COUNT(*) AS _count
FROM clique_bait.events
LEFT JOIN clique_bait.page_hierarchy ON events.page_id = page_hierarchy.page_id
WHERE event_type IN (1, 2) AND page_id IN (SELECT generate_series(1, 11))
GROUP BY product_name
ORDER BY page_views DESC, cart_adds DESC
