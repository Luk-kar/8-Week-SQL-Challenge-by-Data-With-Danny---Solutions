/*
5. Summarise the id values in the `fresh_segments.interest_map` by its total record count in this table
*/

WITH cte_id_records AS (
    SELECT
    id,
    COUNT(*) AS record_count
    FROM fresh_segments.interest_map
    GROUP BY id
)
SELECT
  record_count,
  COUNT(*) AS id_count
FROM cte_id_records
GROUP BY record_count
ORDER BY id_count
;

/*
| record_count  | id_count |
|---------------|----------|
| 1             | 1209     |
*/