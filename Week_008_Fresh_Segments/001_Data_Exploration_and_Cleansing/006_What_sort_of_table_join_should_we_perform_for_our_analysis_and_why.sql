/*
6. What sort of table join should we perform for our analysis and why? 
Check your logic by checking the rows where `interest_id = 21246` 
in your joined output and include all columns `from fresh_segments`.
interest_metrics and all columns `from fresh_segments`.interest_map except from the id column.
*/

/*
Since we know all of the records from the interest_details table exists in the interest_map and 
there are no duplicate records on the id column in the fresh_segments.interest_map -
 we can use either LEFT JOIN or INNER JOIN for the analysis, 
 however it depends on the order of the tables specified in the join.

If we use the fresh_segments.interest_metrics as our base - we can use either join. 
However if we use the fresh_segments.interest_map table as the base, 
we must use INNER JOIN to remove all records in the metrics table 
which do not have a relevant interest_id value.

Additionally - if you want to be as strict as possible - 
using an INNER JOIN is the best solution 
as you will also remove the missing interest_id values from the fresh_segments.interest_metrics table - 
but you will still need to deal with the single record which has a valid interest_id value.
*/

SELECT *
FROM fresh_segments.interest_metrics
WHERE interest_id IS NOT NULL AND month_year IS NULL
;

-- OR

SELECT *
FROM fresh_segments.interest_metrics
WHERE interest_id = 21246
;

/*
| _month  | _year  | month_year  | interest_id  | composition  | index_value  | ranking  | percentile_ranking |
|---------|--------|-------------|--------------|--------------|--------------|----------|--------------------|
| null    | null   | null        | 21246        | 1.61         | 0.68         | 1191     | 0.25               |
*/

SELECT 
    *
FROM v_fresh_segments.interest_metrics
JOIN fresh_segments.interest_map ON
interest_metrics.interest_id = interest_map.id
LIMIT 10
;

/*
| _month  | _year  | month_year                | interest_id  | composition  | index_value  | ranking  | percentile_ranking  | id     | interest_name                              | interest_summary                                                      | created_at                | last_modified            |
|---------|--------|---------------------------|--------------|--------------|--------------|----------|---------------------|--------|--------------------------------------------|-----------------------------------------------------------------------|---------------------------|--------------------------|
| 7       | 2018   | 2018-07-01T00:00:00.000Z  | 32486        | 11.89        | 6.19         | 1        | 99.86               | 32486  | Vacation Rental Accommodation Researchers  | People researching and booking rentals accommodations for vacations.  | 2018-06-29T12:55:03.000Z  | 2018-06-29T12:55:03.000Z |
| 7       | 2018   | 2018-07-01T00:00:00.000Z  | 6106         | 9.93         | 5.31         | 2        | 99.73               | 6106   | Luxury Second Home Owners                  | High income individuals with more than one home.                      | 2017-03-27T16:59:29.000Z  | 2018-05-23T11:30:12.000Z |
| 7       | 2018   | 2018-07-01T00:00:00.000Z  | 18923        | 10.85        | 5.29         | 3        | 99.59               | 18923  | Online Home Decor Shoppers                 | Consumers shopping online for home decor available for delivery.      | 2018-04-19T18:25:02.000Z  | 2018-04-19T18:25:02.000Z |
*/