/* 
1. Using the complete dataset - 
which are the top 10 and bottom 10 interests 
which have the largest composition values in any month_year? 
Only use the maximum composition value for each interest 
but you must keep the corresponding month_year
*/

WITH highest_occurence_by_composition AS (
    SELECT
        interest_id,
        composition,
        month_year,
  		ROW_NUMBER() OVER (PARTITION BY interest_id ORDER BY composition DESC) AS row_number
    FROM v_fresh_segments.interest_metrics
),
top_and_last_10 AS (
  SELECT
    interest_id,
    composition,
    month_year,
    RANK() OVER (ORDER BY composition, interest_id) AS ascending,
    RANK() OVER (ORDER BY composition DESC, interest_id) AS descending
  FROM highest_occurence_by_composition
  WHERE row_number = 1
)
SELECT
	tops.ascending,
    tops.descending,
    tops.interest_id,
    composition,
    imap.interest_name,
    imap.interest_summary,
    month_year
FROM top_and_last_10 AS tops
JOIN fresh_segments.interest_map AS imap ON tops.interest_id = imap.id
WHERE ascending <= 10 OR descending <= 10 
ORDER BY descending
;

/*
| ascending  | descending  | interest_id  | composition  | interest_name                         | interest_summary                                                                                                                                  | month_year               |
|------------|-------------|--------------|--------------|---------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------|
| 1202       | 1           | 21057        | 21.2         | Work Comes First Travelers            | People looking to book a hotel who travel frequently for business and vacation.                                                                   | 2018-12-01T00:00:00.000Z |
| 1201       | 2           | 6284         | 18.82        | Gym Equipment Owners                  | People researching and comparing fitness trends and techniques. These consumers are more likely to spend money on gym equipment for their homes.  | 2018-07-01T00:00:00.000Z |
| 1200       | 3           | 39           | 17.44        | Furniture Shoppers                    | Consumers shopping for major home furnishings.                                                                                                    | 2018-07-01T00:00:00.000Z |
| 1199       | 4           | 77           | 17.19        | Luxury Retail Shoppers                | Consumers shopping for high end fashion apparel and accessories.                                                                                  | 2018-07-01T00:00:00.000Z |
| 1198       | 5           | 12133        | 15.15        | Luxury Boutique Hotel Researchers     | Consumers comparing or purchasing accommodations at luxury, boutique hotels.                                                                      | 2018-10-01T00:00:00.000Z |
| 1197       | 6           | 5969         | 15.05        | Luxury Bedding Shoppers               | Consumers shopping for luxury bedding.                                                                                                            | 2018-12-01T00:00:00.000Z |
| 1196       | 7           | 171          | 14.91        | Shoe Shoppers                         | Consumers shopping for mass market shoes.                                                                                                         | 2018-07-01T00:00:00.000Z |
| 1195       | 8           | 4898         | 14.23        | Cosmetics and Beauty Shoppers         | Consumers comparing and shopping for cosmetics and beauty products.                                                                               | 2018-07-01T00:00:00.000Z |
| 1194       | 9           | 6286         | 14.1         | Luxury Hotel Guests                   | High income individuals researching and booking hotel rooms.                                                                                      | 2018-07-01T00:00:00.000Z |
| 1193       | 10          | 4            | 13.97        | Luxury Retail Researchers             | Consumers researching luxury product reviews and gift ideas.                                                                                      | 2018-07-01T00:00:00.000Z |
| 10         | 1193        | 17274        | 1.86         | Readers of Jamaican Content           | People reading news from Jamaican media sources.                                                                                                  | 2018-07-01T00:00:00.000Z |
| 9          | 1194        | 40701        | 1.84         | Automotive News Readers               | People reading news about automotive and the latest auto trends.                                                                                  | 2019-02-01T00:00:00.000Z |
| 8          | 1195        | 106          | 1.83         | Comedy Fans                           | Consumers of online comedy videos and articles.                                                                                                   | 2018-07-01T00:00:00.000Z |
| 7          | 1196        | 16198        | 1.82         | World of Warcraft Enthusiasts         | People researching World of Warcraft news and following gaming trends.                                                                            | 2019-08-01T00:00:00.000Z |
| 6          | 1197        | 33534        | 1.81         | Miami Heat Fans                       | People reading news about the Miami Heat and watching games. These consumers are more likely to spend money on team gear.                         | 2018-08-01T00:00:00.000Z |
| 5          | 1198        | 15882        | 1.73         | Online Role Playing Game Enthusiasts  | People researching role playing games and sharing with the community.                                                                             | 2018-07-01T00:00:00.000Z |
| 4          | 1199        | 42401        | 1.66         | Hearthstone Video Game Fans           | People reading Hearthstone news and following gaming trends.                                                                                      | 2019-08-01T00:00:00.000Z |
| 3          | 1200        | 34951        | 1.61         | Scifi Movie and TV Enthusiasts        | Consumers researching popular scifi movies and TV shows.                                                                                          | 2018-09-01T00:00:00.000Z |
| 2          | 1201        | 34950        | 1.59         | Action Movie and TV Enthusiasts       | Consumers researching popular action movies and TV shows.                                                                                         | 2018-09-01T00:00:00.000Z |
| 1          | 1202        | 42008        | 1.57         | The Sims Video Game Fans              | People reading The Sims news and following gaming trends.                                                                                         | 2019-03-01T00:00:00.000Z |
*/