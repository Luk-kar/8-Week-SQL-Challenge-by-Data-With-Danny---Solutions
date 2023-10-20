-- 2.How many cookies does each user have on average?

WITH cookier_per_user AS (

    SELECT 
        COUNT(cookie_id) AS cookie_count
    FROM clique_bait.users
    GROUP BY user_id
)
SELECT
    ROUND(AVG(cookie_count), 2) AS avg_number_of_cookies_per_user
FROM cookier_per_user
;