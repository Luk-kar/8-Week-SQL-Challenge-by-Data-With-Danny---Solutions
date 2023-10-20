-- 9. What are the top 3 products by purchases?

WITH visits_with_purchase AS (
    SELECT DISTINCT
        visit_id
    FROM clique_bait.events
    WHERE page_id = 13 AND event_type = 3
),
products_added_to_cart AS (
    SELECT
        visit_id,
        page_id
    FROM clique_bait.events
    WHERE event_type = 2 AND page_id IN (SELECT generate_series(1, 11))
)
SELECT
    page_id AS product_id,
    page_name AS product_name,
    COUNT(*) AS _count,
    ROUND((COUNT(*)::DECIMAL / (SELECT COUNT(*) FROM visits_with_purchase)) * 100, 2) AS percent
FROM products_added_to_cart
LEFT JOIN clique_bait.page_hierarchy ON products_added_to_cart.page_id = page_hierarchy.page_id
WHERE EXISTS (
  SELECT 1
  FROM visits_with_purchase
  WHERE products_added_to_cart.visit_id = visits_with_purchase.visit_id
)
GROUP BY page_name
ORDER BY _count DESC
LIMIT 3;
