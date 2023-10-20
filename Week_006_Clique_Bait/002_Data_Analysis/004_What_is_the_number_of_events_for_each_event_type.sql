-- 4.What is the number of events for each event type?

WITH events_count AS (
    SELECT
        event_type,
        COUNT(*) AS _count
    FROM clique_bait.events
    GROUP BY event_type
)
SELECT
    events_count.event_type,
    event_name,
    _count
FROM events_count
JOIN LEFT clique_bait.event_identifier ON events_count.event_type = event_identifier.event_type
ORDER BY _count DESC
;