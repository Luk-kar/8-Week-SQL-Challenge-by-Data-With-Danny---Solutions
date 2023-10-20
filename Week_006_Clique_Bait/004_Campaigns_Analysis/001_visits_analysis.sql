/*
Campaigns Analysis

A. Generate a table that has 1 single row for every unique visit_id record and has the following columns:

 - user_id
 - visit_id
 - visit_start_time: the earliest event_time for each visit
 - page_views: count of page views for each visit
 - cart_adds: count of product cart add events for each visit
 - purchase: 1/0 flag if a purchase event exists for each visit
 x- campaign_name: map the visit to a campaign if the visit_start_time falls between the start_date and end_date
 - impression: count of ad impressions for each visit
 - click: count of ad clicks for each visit
 x- (Optional column) cart_products: a comma separated text value with products added to the cart sorted by the order they were added to the cart (hint: use the sequence_number)

*/

SELECT
  users.user_id,
  events.visit_id,
  MIN(events.event_time) AS visit_start_time,
  SUM(CASE WHEN events.event_type = 1 THEN 0 ELSE 1 END) AS page_views,
  SUM(CASE WHEN events.event_type = 2 THEN 0 ELSE 1 END) AS cart_adds,
  MAX(CASE WHEN events.event_type = 3 THEN 0 ELSE 1 END) AS purchase,
  campaign_identifier.campaign_name,
  MAX(CASE WHEN events.event_type = 4 THEN 0 ELSE 1 END) AS impression,
  MAX(CASE WHEN events.event_type = 5 THEN 0 ELSE 1 END) AS click,
  STRING_AGG(
    CASE
      WHEN page_hierarchy.product_id IS NOT NULL AND event_type = 2
        THEN page_hierarchy.page_name
      ELSE NULL END,
    ', ' ORDER BY events.sequence_number
  ) AS cart_products
FROM clique_bait.events
INNER JOIN clique_bait.users
  ON events.cookie_id = users.cookie_id
LEFT JOIN clique_bait.campaign_identifier
  ON events.event_time BETWEEN campaign_identifier.start_date AND campaign_identifier.end_date
LEFT JOIN clique_bait.page_hierarchy
  ON events.page_id = page_hierarchy.page_id
GROUP BY
  users.user_id,
  events.visit_id,
  campaign_identifier.campaign_name;

-- other solution

DROP TABLE IF EXISTS event_metrics;
CREATE TEMP TABLE event_metrics AS (
    WITH visit_event AS (
        SELECT DISTINCT
            user_id,
            visit_id,
            FIRST_VALUE(event_time) OVER by_visit_by_time AS start_time,
            LAST_VALUE(event_time) OVER by_visit_by_time AS end_time,
            COUNT(CASE WHEN event_type = 1 THEN 1 ELSE 0 END) OVER by_visit AS page_views,
            COUNT(CASE WHEN event_type = 2 THEN 1 ELSE 0 END) OVER by_visit AS cart_adds,
            CASE 
                WHEN COUNT(CASE WHEN event_type = 3 THEN 1 ELSE 0 END) OVER by_visit >= 1 THEN 1
                ELSE 0
            END AS is_purchase,
            COUNT(CASE WHEN event_type = 4 THEN 1 ELSE 0 END) OVER by_visit AS impression,
            COUNT(CASE WHEN event_type = 5 THEN 1 ELSE 0 END) OVER by_visit AS ad_click
        FROM clique_bait.events
        WINDOW
            by_visit AS (PARTITION BY visit_id),
            by_visit_by_time AS (PARTITION BY visit_id ORDER BY event_time)
    ),
    visits_with_purchase AS (
        SELECT DISTINCT
            visit_id
        FROM clique_bait.events
        WHERE event_type = 3
    ),
    visit_bought_products AS (
        SELECT
            visit_id,
            page_name AS purchased,
            sequence_number
        FROM clique_bait.events
        LEFT JOIN clique_bait.page_hierarchy ON events.page_id = page_hierarchy.page_id
        WHERE events.page_id IN (SELECT generate_series(1, 11)) AND events.event_type = 3
        AND EXISTS (
            SELECT 1
            FROM visits_with_purchase v
            WHERE events.visit_id = v.visit_id
        )
        GROUP BY events.page_id
    ),
    visit_bought_list AS (
        SELECT
            visit_id,
            STRING_AGG(purchased, ', ' ORDER BY sequence_number) AS purchased_list
        FROM visit_bought_products
        GROUP BY visit_id
    )
    SELECT
        user_id,
        visit_id,
        start_time,
        campaign_name,
        page_views,
        cart_adds,
        is_purchase,
        impression,
        ad_click,
        purchased_list
    FROM visit_event
    LEFT JOIN campaign_identifier AS campaign ON 
    visit_event.start_time >= campaign.start_time AND 
    visit_event.start_time < campaign.end_time
    LEFT JOIN visit_bought_list AS list ON
    visit_event.visit_id = list.visit_id
    ORDER BY start_time, user_id
)
RETURNING * LIMIT 20;
