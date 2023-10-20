/*
C. Some ideas you might want to investigate further include:

 1. Identifying users who have received impressions during each campaign period and 
    comparing each metric with other users who did not have an impression event
 2. Does clicking on an impression lead to higher purchase rates?
    What is the uplift in purchase rate when comparing users who 
    click on a campaign impression versus users who do not receive an impression? 
 3. What if we compare them with users who just an impression but do not click?
 4. What metrics can you use to quantify the success or failure of each campaign compared to each other?
*/

-- SELECT
--    user_id,
--    visit_id,
--    start_time,
--    end_time,
--    campaign_name,
--    page_views,
--    cart_adds,
--    is_purchase,
--    impression,
--    ad_click,
--    purchased_list
-- FROM event_metrics;

/*
 1. Identifying users who have received impressions during each campaign period and 
    comparing each metric with other users who did not have an impression event
*/

WITH during_campaigns AS (
   SELECT
      campaign_name,
      visit_id,
      user_id,
      page_views,
      cart_adds,
      is_purchase,
      impression
   FROM event_metrics
   WHERE campaign_name IS NOT NULL
),
received_impressions AS (
   SELECT
      'received_impressions' AS condition,
      campaign_name,
      ROUND( SUM(visit_id)::DECIMAL / COUNT(DISTINCT user_id), 1) AS visits_per_user,
      ROUND( SUM(page_views)::DECIMAL / COUNT(DISTINCT user_id), 1) AS page_views_per_user,
      ROUND( SUM(cart_adds)::DECIMAL / COUNT(DISTINCT user_id), 1) AS cart_adds_per_user,
      ROUND( SUM(is_purchase)::DECIMAL / COUNT(DISTINCT user_id), 1) AS visits_with_purchase_per_user
   FROM during_campaigns
   WHERE impression >= 1
   GROUP BY campaign_name
),
not_received_impressions AS (
   SELECT
      'not_received_impressions' AS condition,
      campaign_name,
      ROUND( SUM(visit_id)::DECIMAL / COUNT(DISTINCT user_id), 1) AS visits_per_user,
      ROUND( SUM(page_views)::DECIMAL / COUNT(DISTINCT user_id), 1) AS page_views_per_user,
      ROUND( SUM(cart_adds)::DECIMAL / COUNT(DISTINCT user_id), 1) AS cart_adds_per_user,
      ROUND( SUM(is_purchase)::DECIMAL / COUNT(DISTINCT user_id), 1) AS visits_with_purchase_per_user
   FROM during_campaigns
   WHERE impression = 0
   GROUP BY campaign_name
)
SELECT * FROM received_impressions

UNION ALL

SELECT * FROM not_received_impressions
;

/*
 2. Does clicking on an impression lead to higher purchase rates?
    What is the uplift in purchase rate when comparing users who 
    click on a campaign impression versus users who do not receive an impression? 
*/

WITH during_campaigns AS (
   SELECT
      user_id,
      is_purchase,
      impression
   FROM event_metrics
   WHERE campaign_name IS NOT NULL
),
metric_per_user AS (
   SELECT
      user_id,
      SUM(is_purchase) AS visits_with_purchase,
      SUM(impression) AS impression
   FROM during_campaigns
   GROUP BY user_id
)
SELECT
   ROUND(SUM(CASE WHEN impression >= 1 THEN visits_with_purchase ELSE 0 END)::DECIMAL / COUNT(DISTINCT user_id) FILTER (WHERE visits_with_purchase >= 1), 1) AS purchase_user_with_impressions,
   ROUND(SUM(CASE WHEN impression = 0 THEN visits_with_purchase ELSE 0 END)::DECIMAL / COUNT(DISTINCT user_id) FILTER (WHERE visits_with_purchase = 0), 1) AS purchase_user_no_impressions
FROM metric_per_user
;

/*
 3. What if we compare them with users who just an impression but do not click?
*/

WITH during_campaigns AS (
   SELECT
      user_id,
      is_purchase,
      impression,
      ad_click
   FROM event_metrics
   WHERE campaign_name IS NOT NULL
),
metric_per_user AS (
   SELECT
      user_id,
      SUM(is_purchase) AS visits_with_purchase,
      SUM(impression) AS impression,
      SUM(ad_click) AS clicks
   FROM during_campaigns
   GROUP BY user_id
)
SELECT
   ROUND(SUM(CASE WHEN impression >= 1 AND clicks >= 1 THEN visits_with_purchase ELSE 0 END)::DECIMAL / COUNT(DISTINCT user_id) FILTER (WHERE impression >= 1 AND clicks >= 1), 1) AS purchase_user_with_impressions,
   ROUND(SUM(CASE WHEN impression >= 1 AND clicks = 0 THEN visits_with_purchase ELSE 0 END)::DECIMAL / COUNT(DISTINCT user_id) FILTER (WHERE impression >= 1 AND clicks = 0), 1) AS purchase_user_no_impressions
FROM metric_per_user

/*
 4. What metrics can you use to quantify the success or failure of each campaign compared to each other?

 -- purchase_success_rate_per_visit
 -- cart_adds_per_visit
 -- impression_per_visit
 -- ad_click_per_visit
 */

SELECT
   campaign_name,
   ROUND(SUM(is_purchase)::DECIMAL / COUNT(visit_id) * 100, 2) AS purchase_success_rate_per_visit,
   COUNT(visit_id)::DECIMAL / SUM(cart_adds) AS cart_adds_per_visit,
   COUNT(visit_id)::DECIMAL / SUM(impression) AS impression_per_visit,
   COUNT(visit_id)::DECIMAL / SUM(ad_click) AS ad_click_per_visit
FROM event_metrics
GROUP BY campaign_name