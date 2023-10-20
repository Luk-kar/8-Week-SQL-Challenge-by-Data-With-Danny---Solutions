/*
2.
Additionally, create another table which further aggregates the data for the above points 
but this time for each product category instead of individual products.
*/

DROP TABLE IF EXISTS basic_metrics;
CREATE TEMP TABLE basic_metrics AS (
    WITH viewed_or_added AS (
        SELECT
            page_id,
            COUNT(CASE WHEN event_type = 1 THEN 1 END) AS view_count,
            COUNT(CASE WHEN event_type = 2 THEN 1 END) AS add_to_cart_count
        FROM clique_bait.events
        WHERE page_id IN (SELECT generate_series(1, 11))
        GROUP BY page_id
    ),
    visits_with_purchase AS (
        SELECT DISTINCT
            visit_id
        FROM clique_bait.events
        WHERE event_type = 3
    ),
    added_but_not_purchased AS (
        SELECT
            e.page_id,
            COUNT(*) AS added_but_not_purchased
        FROM clique_bait.events e
        WHERE e.page_id IN (SELECT generate_series(1, 11)) AND e.event_type = 2
        AND NOT EXISTS (
            SELECT 1
            FROM visits_with_purchase v
            WHERE e.visit_id = v.visit_id
        )
        GROUP BY e.page_id
    ),
    purchased AS (
        SELECT
            e.page_id,
            COUNT(*) AS purchased
        FROM clique_bait.events e
        WHERE e.page_id IN (SELECT generate_series(1, 11)) AND e.event_type = 3
        AND EXISTS (
            SELECT 1
            FROM visits_with_purchase v
            WHERE e.visit_id = v.visit_id
        )
        GROUP BY e.page_id
    )
    SELECT
        ph.page_name AS product_name,
        va.view_count,
        va.add_to_cart_count,
        anp.added_but_not_purchased,
        p.purchased
    FROM viewed_or_added va
    FULL JOIN added_but_not_purchased anp ON va.page_id = anp.page_id
    FULL JOIN purchased p ON va.page_id = p.page_id
    LEFT JOIN clique_bait.page_hierarchy ph ON va.page_id = ph.page_id
    ORDER BY va.page_id
)
;

/*
    Use your the new output table  TEMP TABLE basic_metrics
    - answer the following questions:

    1. Which product had the most views, cart adds and purchases?
    2. Which product was most likely to be abandoned?
    3. Which product had the highest view to purchase percentage?
    4. What is the average conversion rate from view to cart add?
    5. What is the average conversion rate from cart add to purchase?
*/

-- 1. Which product had the most views, cart adds and purchases?

SELECT
    product_name,
    view_count,
    add_to_cart_count,
    purchased
FROM basic_metrics
ORDER BY view_count DESC, add_to_cart_count DESC, purchased DESC
;

-- 2. Which product was most likely to be abandoned?

SELECT
    product_name,
    added_but_not_purchased AS abandoned,
    ROUND(abandoned::DECIMAL / cart_adds, 2) AS abandoned_likelihood
FROM basic_metrics
ORDER BY abandoned_likelihood DESC
LIMIT 3
;

-- 3. Which product had the highest view to purchase percentage?

SELECT
    product_name,
    view_count,
    purchased,
    ROUND(purchased::DECIMAL / view_count * 100, 2) AS view_to_purchase_percentage
FROM basic_metrics
ORDER BY view_to_purchase_percentage DESC
LIMIT 3 
;

-- 4. What is the average conversion rate from view to cart add?

SELECT
    ROUND(SUM(add_to_cart_count)::DECIMAL / SUM(view_count) * 100, 2) AS avg_view_to_cart_add_percentage
FROM basic_metrics
;

-- 5. What is the average conversion rate from cart add to purchase?

SELECT
    ROUND(SUM(purchased)::DECIMAL / SUM(add_to_cart_count) * 100, 2) AS avg_cart_add_to_purchase_percentage
FROM basic_metrics
;