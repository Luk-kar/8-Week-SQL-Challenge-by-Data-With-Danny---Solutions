/*
2. What is count of records in the `fresh_segments.interest_metrics` 
for each `month_year` value sorted in chronological order (earliest to latest) 
with the null values appearing first?
*/

SELECT 
    month_year,
    COUNT(*)
FROM fresh_segments.interest_metrics
GROUP BY month_year
ORDER BY month_year NULLS FIRST
;

/*
| month_year  | count |
|-------------|-------|
| null        | 1194  |
| 01-2019     | 973   |
| 02-2019     | 1121  |
| 03-2019     | 1136  |
| 04-2019     | 1099  |
| 05-2019     | 857   |
| 06-2019     | 824   |
| 07-2018     | 729   |
| 07-2019     | 864   |
| 08-2018     | 767   |
| 08-2019     | 1149  |
| 09-2018     | 780   |
| 10-2018     | 857   |
| 11-2018     | 928   |
| 12-2018     | 995   |
*/