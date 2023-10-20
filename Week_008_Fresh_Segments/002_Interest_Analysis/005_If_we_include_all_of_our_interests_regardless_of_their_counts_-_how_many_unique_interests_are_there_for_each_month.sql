/*
5. If we include all of our interests regardless of their counts - 
how many unique interests are there for each month?
*/

SELECT
    month_year,
    COUNT(DISTINCT interest_id) AS interest_count
FROM fresh_segments.interest_metrics
WHERE interest_id IS NOT NULL AND month_year IS NOT NULL
GROUP BY month_year
ORDER BY month_year
;

/*
| month_year  | interest_count |
|-------------|----------------|
| 01-2019     | 973            |
| 02-2019     | 1121           |
| 03-2019     | 1136           |
| 04-2019     | 1099           |
| 05-2019     | 857            |
| 06-2019     | 824            |
| 07-2018     | 729            |
| 07-2019     | 864            |
| 08-2018     | 767            |
| 08-2019     | 1149           |
| 09-2018     | 780            |
| 10-2018     | 857            |
| 11-2018     | 928            |
| 12-2018     | 995            |
*/

SELECT
    month_year,
    COUNT(DISTINCT interest_id) AS interest_count
FROM fresh_segments.interest_metrics
WHERE interest_id IS NOT NULL AND month_year IS NOT NULL
GROUP BY month_year
ORDER BY interest_count DESC
;

/*
| month_year  | interest_count |
|-------------|----------------|
| 08-2019     | 1149           |
| 03-2019     | 1136           |
| 02-2019     | 1121           |
| 04-2019     | 1099           |
| 12-2018     | 995            |
| 01-2019     | 973            |
| 11-2018     | 928            |
| 07-2019     | 864            |
| 10-2018     | 857            |
| 05-2019     | 857            |
| 06-2019     | 824            |
| 09-2018     | 780            |
| 08-2018     | 767            |
| 07-2018     | 729            |
*/