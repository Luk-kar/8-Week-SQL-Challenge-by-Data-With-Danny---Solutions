/* 
2. Which 5 interests had the lowest average ranking value?
*/

WITH ranked AS (
    SELECT
        interest_id,
        RANK() OVER (ORDER BY AVG(ranking) DESC) AS ranked
    FROM v_fresh_segments.interest_metrics
    GROUP BY interest_id
)
SELECT
    DENSE_RANK() OVER (ORDER BY AVG(im.ranking) DESC) AS ranked,
    ROUND(AVG(im.ranking)::DECIMAL, 1) AS avg_ranking,
    COUNT(*) AS months_count,
    im.interest_id,
    imap.interest_name,
    imap.interest_summary
FROM v_fresh_segments.interest_metrics im
JOIN ranked r ON im.interest_id = r.interest_id
JOIN fresh_segments.interest_map imap ON
r.interest_id = imap.id
WHERE r.ranked <= 5 AND r.ranked IS NOT NULL
GROUP BY im.interest_id, imap.interest_name, imap.interest_summary
ORDER BY ranked, months_count DESC
;

/*
| ranked  | avg_ranking  | months_count  | interest_id  | interest_name                     | interest_summary                                                                      |
|---------|--------------|---------------|--------------|-----------------------------------|---------------------------------------------------------------------------------------|
| 1       | 1141.0       | 1             | 42401        | Hearthstone Video Game Fans       | People reading Hearthstone news and following gaming trends.                          |
| 2       | 1135.0       | 1             | 42008        | The Sims Video Game Fans          | People reading The Sims news and following gaming trends.                             |
| 3       | 1110.0       | 4             | 45522        | Hair Color Shoppers               | Consumers shopping for hair color products and services.                              |
| 3       | 1110.0       | 2             | 43552        | Grand Theft Auto Video Game Fans  | People reading Grand Theft Auto news and following gaming trends                      |
| 4       | 1078.0       | 2             | 46567        | Bigfoot Folklore Enthusiasts      | People reading about Bigfoot folklore and other mystical creatures and urban legends. |
*/
