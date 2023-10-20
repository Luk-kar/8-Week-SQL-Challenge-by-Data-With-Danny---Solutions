/*
1.

Using a single SQL query - create a new output table which has the following details:

    1. How many times was each product viewed?
    2. How many times was each product added to cart?
    3. How many times was each product added to a cart but not purchased (abandoned)?
    4. How many times was each product purchased?

Create it as TEMP TABLE
*/

-- 1. How many times was each product viewed?
-- 2. How many times was each product added to cart?
WITH viewed_or_added AS (
    SELECT
        page_id,
        COUNT(CASE WHEN event_type = 1 THEN 1 END) AS view_count,
        COUNT(CASE WHEN event_type = 2 THEN 1 END) AS add_to_cart_count
    FROM clique_bait.events
    WHERE page_id IN (SELECT generate_series(1, 11))
    GROUP BY page_id
),
-- 3. How many times was each product added to a cart but not purchased (abandoned)?
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
-- 4. How many times was each product purchased?
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
-- 5. Summary
SELECT
    ph.page_name,
    va.view_count,
    va.add_to_cart_count,
    anp.added_but_not_purchased,
    p.purchased
FROM viewed_or_added va
FULL JOIN added_but_not_purchased anp ON va.page_id = anp.page_id
FULL JOIN purchased p ON va.page_id = p.page_id
LEFT JOIN clique_bait.page_hierarchy ph ON va.page_id = ph.page_id
ORDER BY va.page_id;

-- different approach

DROP TABLE IF EXISTS product_info;
CREATE TEMP TABLE product_info AS
WITH cte_product_page_events AS (
  SELECT
    events.visit_id,
    page_hierarchy.product_id,
    page_hierarchy.page_name,
    page_hierarchy.product_category,
    SUM(CASE WHEN event_type = 3 THEN 1 ELSE 0 END) AS page_view,
    SUM(CASE WHEN event_type = 1 THEN 1 ELSE 0 END) AS cart_add
  FROM clique_bait.events
  INNER JOIN clique_bait.page_hierarchy
    ON events.page_id = page_hierarchy.page_id
  WHERE page_hierarchy.product_id IS NOT NULL
  GROUP BY
    events.visit_id,
    page_hierarchy.product_id,
    page_hierarchy.page_name,
    page_hierarchy.product_category
),
cte_visit_purchase AS (
  SELECT DISTINCT
    visit_id
  FROM clique_bait.events
  WHERE event_type = 3
),
cte_combined_product_events AS (
  SELECT
    t1.visit_id,
    t1.product_id,
    t1.page_name,
    t1.product_category,
    t1.page_view,
    t1.cart_add,
    CASE WHEN t2.visit_id IS NULL THEN 1 ELSE 0 END as purchase
  FROM cte_product_page_events AS t1
  LEFT JOIN cte_visit_purchase AS t2
    ON t1.visit_id = t2.visit_id
)
SELECT
  product_id,
  page_name AS product,
  product_category,
  SUM(page_view) AS page_views,
  SUM(cart_add) AS cart_adds,
  SUM(CASE WHEN cart_add = 0 AND purchase = 0 THEN 1 ELSE 0 END) AS abandoned,
  SUM(CASE WHEN cart_add = 0 AND purchase = 1 THEN 1 ELSE 0 END) AS purchases
FROM cte_combined_product_events
GROUP BY product_id, product, product_category;

-- you can further aggregate this output for the product_category
DROP TABLE IF EXISTS product_category_info;
CREATE TEMP TABLE product_category_info AS
SELECT
  product_category,
  SUM(page_views) AS page_views,
  SUM(cart_adds) AS cart_adds,
  SUM(abandoned) AS abandoned,
  SUM(purchases) AS purchases
FROM product_info
GROUP BY product_category;

SELECT * FROM product_info ORDER BY product_id;
SELECT * FROM product_category_info ORDER BY product_category;