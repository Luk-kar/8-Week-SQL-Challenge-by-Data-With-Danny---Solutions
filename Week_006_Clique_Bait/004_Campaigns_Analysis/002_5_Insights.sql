/*
B. Use the subsequent dataset to generate at least 5 insights for the Clique Bait team 
B. 1. - bonus: prepare a single A4 infographic that the team can use for their management reporting sessions, 
be sure to emphasis the most important points from your findings.
*/


DROP TABLE IF EXISTS event_metrics;
CREATE TEMP TABLE event_metrics AS (
    WITH visit_event AS (
        SELECT DISTINCT
            user_id,
            visit_id,
            FIRST_VALUE(event_time) OVER by_visit_by_time AS start_time,
            LAST_VALUE(event_time) OVER by_visit_by_time AS end_time,
            COUNT(CASE WHEN event_type = 1 THEN 1 END) OVER by_visit AS page_views,
            COUNT(CASE WHEN event_type = 2 THEN 1 END) OVER by_visit AS cart_adds,
            CASE 
                WHEN COUNT(CASE WHEN event_type = 3 THEN 1 END) OVER by_visit >= 1 THEN 1
                ELSE 0
            END AS is_purchase,
            COUNT(CASE WHEN event_type = 4 THEN 1 END) OVER by_visit AS impression,
            COUNT(CASE WHEN event_type = 5 THEN 1 END) OVER by_visit AS ad_click
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
        end_time,
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
;

-- 5 insights for the Clique Bait team

/*
1. Optimize Campaigns: If certain campaigns correlate with higher page_views and conversion rates, 
consider focusing marketing efforts on similar campaigns.

Q: Campaign Effectiveness: How does campaign_name correlate with metrics like 
page_views, cart_adds, and is_purchase?
*/

SELECT
    campaign_name,
    SUM(is_purchase) AS purchase_count,
    ROUND(SUM(is_purchase)::DECIMAL / COUNT(visit_id) * 100, 2) AS purchase_%,
    SUM(cart_adds) AS cart_adds_count,
    ROUND(SUM(cart_adds)::DECIMAL / COUNT(visit_id) * 100, 2) AS cart_adds_%,
    SUM(page_views) AS page_views_count
    ROUND(SUM(page_views)::DECIMAL / COUNT(visit_id) * 100, 2) AS page_views_%
FROM event_metrics
GROUP BY campaign_name
ORDER BY purchase_%, cart_adds_%, page_views_%
LIMIT 10
;

/*
2. User Behavior: Analyzing the average duration between start_time and end_time 
could provide insights into how much time users generally need before making a purchase. 
You could use this data to time promotional pop-ups or reminders.

Q: Time Spent per Visit: 
What is the average duration between start_time and end_time per visit? 
Does this time differ for visits with a purchase versus those without?
*/

WITH total_visits AS (

    SELECT 
        EXTRACT(epoch FROM SUM(end_time - start_time)) AS total_duration,
        COUNT(*) AS total_count
    FROM 
        event_metrics
),
purchased_visits AS (

    SELECT 
        EXTRACT(epoch FROM SUM(end_time - start_time)) AS total_duration,
        COUNT(*) AS total_count
    FROM 
        event_metrics
    WHERE 
        is_purchase = 1
),
non_purchased_visits AS (

    SELECT 
        EXTRACT(epoch FROM SUM(end_time - start_time)) AS total_duration,
        COUNT(*) AS total_count
    FROM 
        event_metrics
    WHERE 
        is_purchase = 0
),
average_durations AS (

    SELECT 
        total_duration / NULLIF(total_count, 0) AS avg_epoch_time_spent,
        total_duration / NULLIF(total_count, 0) AS avg_epoch_time_spent_on_purchase,
        total_duration / NULLIF(total_count, 0) AS avg_epoch_time_spent_without_purchase
    FROM 
        total_visits, purchased_visits, non_purchased_visits
)
-- Convert epoch times to INTERVAL type
SELECT 
    MAKE_INTERVAL(secs => avg_epoch_time_spent) AS average_time_spent_on_site,
    MAKE_INTERVAL(secs => avg_epoch_time_spent_on_purchase) AS average_time_spent_on_purchase,
    MAKE_INTERVAL(secs => avg_epoch_time_spent_without_purchase) AS average_time_spent_without_purchase
FROM 
    average_durations
;

/*
3. Ad Retargeting: If the impression to ad_click ratio is low,
it might be time to re-evaluate the relevance and positioning of the ads.

Q: Ad Metrics: How effective are the ads in terms of impression to ad_click ratios?
*/

SELECT
    EXTRACT('year' FROM start_time) AS "year",
    EXTRACT('month' FROM start_time) AS "month",
    SUM(impression) AS impressions,
    SUM(ad_click) AS ad_clicks,
    CASE 
        WHEN SUM(ad_click) = 0 THEN 0
        ELSE ROUND(SUM(ad_click)::DECIMAL / SUM(impression) * 100, 2)
    END AS ad_click_per_impression_ratio
FROM event_metrics
GROUP BY EXTRACT('year' FROM start_time), EXTRACT('month' FROM start_time)
ORDER BY "year", "month"
;

/*
4. Cart Recovery: 
If cart abandonment rates are high, consider implementing cart recovery strategies like 
reminder emails or special offers to incentivize completion of the purchase.

Q: Cart Abandonment: 
How many visits include adding an item to the cart 
(cart_adds >= 1) but do not result in a purchase (is_purchase = 0)?
*/

SELECT
    EXTRACT('year' FROM start_time) AS "year",
    EXTRACT('month' FROM start_time) AS "month",
    SUM(is_purchase) AS visit_ended_purchasing,
    ROUND(SUM(is_purchase)::DECIMAL / COUNT(*) * 100, 2) AS purchasing_%
    SUM(CASE WHEN cart_adds >= 1 AND is_purchase = 0 THEN 1 ELSE 0) AS visit_ended_cart_added_but_abandoned,
    ROUND(SUM(CASE WHEN cart_adds >= 1 AND is_purchase = 0 THEN 1 ELSE 0)::DECIMAL / COUNT(*) * 100, 2) AS abandoned_%
FROM event_metrics
GROUP BY EXTRACT('year' FROM start_time), EXTRACT('month' FROM start_time)
ORDER BY "year", "month"
;

/*
5. Visit frequency: 
If frequent visits don't lead to purchases, consider targeted offers or loyalty programs.

Q: User Retention: 
How many user_ids have multiple visit_ids? 
Does frequency of visits correlate with making a purchase?
*/

SELECT
    COUNT(visit_id)::DECIMAL / COUNT(DISTINCT user_id) AS average_visits_per_user,
    COUNT(CASE WHEN is_purchase = 1 THEN 1 END)::DECIMAL / COUNT(DISTINCT user_id) FILTER (WHERE is_purchase = 1) AS average_visits_per_purchase,
    COUNT(CASE WHEN is_purchase = 0 THEN 1 END)::DECIMAL / COUNT(DISTINCT user_id) FILTER (WHERE is_purchase = 0) AS average_visits_no_purchase
FROM event_metrics
;