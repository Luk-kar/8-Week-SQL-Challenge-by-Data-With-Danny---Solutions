/*
5. Provide a possible reason why the max average composition 
might change from month to month? 
Could it signal something is not quite right with the overall business model for Fresh Segments?
*/

CREATE TEMP TABLE main_query_temp AS
WITH ranked AS (
    SELECT
        RANK() OVER (PARTITION BY month_year ORDER BY composition DESC) AS ranked,
        month_year,
        composition,
        composition::DECIMAL / index_value AS index_composition
    FROM v_fresh_segments.interest_metrics
),
top_10_monthly AS (
  SELECT
      month_year,
      AVG(composition) AS unrounded_avg_composition_top_10,
      AVG(index_composition) AS unrounded_avg_index_composition_top_10
  FROM ranked
  WHERE ranked <= 10
  GROUP BY month_year
),
interests_per_month AS (
    SELECT
        month_year,
        COUNT(*) AS _count
    FROM v_fresh_segments.interest_metrics
    GROUP BY month_year
)
SELECT
    _top.month_year,
    ROUND(_top.unrounded_avg_composition_top_10::DECIMAL, 2) AS avg_composition_top_10,
    ROUND(
      (_top.unrounded_avg_composition_top_10 - LAG(_top.unrounded_avg_composition_top_10, 1) 
      OVER (ORDER BY _top.month_year))::DECIMAL, 
      2) AS comp_diff,
    ROUND(_top.unrounded_avg_index_composition_top_10::DECIMAL, 2) AS avg_index_composition_top_10,
    ROUND(
      (_top.unrounded_avg_index_composition_top_10 - LAG(_top.unrounded_avg_index_composition_top_10, 1) 
      OVER (ORDER BY _top.month_year))::DECIMAL, 
      2) AS index_diff,
    ipm._count,
    ipm._count - LAG(ipm._count, 1) OVER (ORDER BY _top.month_year) AS count_diff,
    ROUND((ipm._count::DECIMAL / LAG(ipm._count, 1) OVER (ORDER BY _top.month_year) - 1) * 100, 2) AS "count_diff_%"
FROM top_10_monthly _top
JOIN interests_per_month ipm ON _top.month_year = ipm.month_year
;

SELECT * FROM main_query_temp ORDER BY month_year
;

/*
| month_year                | avg_composition_top_10  | comp_diff  | avg_index_composition_top_10  | index_diff  | _count  | count_diff  | count_diff_% |
|---------------------------|-------------------------|------------|-------------------------------|-------------|---------|-------------|--------------|
| 2018-07-01T00:00:00.000Z  | 15.06                   | null       | 4.82                          | null        | 729     | null        | null         |
| 2018-08-01T00:00:00.000Z  | 10.82                   | -4.25      | 4.93                          | 0.11        | 767     | 38          | 5.21         |
| 2018-09-01T00:00:00.000Z  | 12.20                   | 1.39       | 6.24                          | 1.31        | 780     | 13          | 1.69         |
| 2018-10-01T00:00:00.000Z  | 13.67                   | 1.47       | 6.40                          | 0.16        | 857     | 77          | 9.87         |
| 2018-11-01T00:00:00.000Z  | 12.26                   | -1.41      | 5.83                          | -0.57       | 928     | 71          | 8.28         |
| 2018-12-01T00:00:00.000Z  | 13.22                   | 0.96       | 5.83                          | 0.00        | 995     | 67          | 7.22         |
| 2019-01-01T00:00:00.000Z  | 12.11                   | -1.11      | 5.66                          | -0.17       | 973     | -22         | -2.21        |
| 2019-02-01T00:00:00.000Z  | 12.54                   | 0.42       | 5.80                          | 0.14        | 1121    | 148         | 15.21        |
| 2019-03-01T00:00:00.000Z  | 10.89                   | -1.65      | 5.40                          | -0.41       | 1136    | 15          | 1.34         |
| 2019-04-01T00:00:00.000Z  | 9.55                    | -1.33      | 4.84                          | -0.56       | 1099    | -37         | -3.26        |
| 2019-05-01T00:00:00.000Z  | 6.38                    | -3.17      | 2.72                          | -2.12       | 857     | -242        | -22.02       |
| 2019-06-01T00:00:00.000Z  | 5.11                    | -1.28      | 1.96                          | -0.76       | 824     | -33         | -3.85        |
| 2019-07-01T00:00:00.000Z  | 5.73                    | 0.62       | 2.08                          | 0.11        | 864     | 40          | 4.85         |
| 2019-08-01T00:00:00.000Z  | 6.25                    | 0.52       | 1.96                          | -0.11       | 1149    | 285         | 32.99        |
*/

SELECT 
ROUND(corr(comp_diff, "count_diff_%")::DECIMAL, 3) AS composition_correlation_coefficient,
ROUND(corr(index_diff, "count_diff_%")::DECIMAL, 3) AS index_correlation_coefficient
FROM main_query_temp
WHERE 
    comp_diff IS NOT NULL AND "count_diff_%" IS NOT NULL AND
    index_diff IS NOT NULL AND "count_diff_%" IS NOT NULL
;

/*
| composition_correlation_coefficient  | index_correlation_coefficient |
|--------------------------------------|-------------------------------|
| 0.504                                | 0.540                         |
*/

/*
The correlation coefficient of 0.504 
suggests a moderate positive relationship between `comp_diff_%` and `index_diff_%` to `count_diff_%`, 
meaning that as one tends to increase, the other is also likely to increase to some extent.
So, the more metrics, the higher the chance that `composition` and `index` for each will fall.
*/