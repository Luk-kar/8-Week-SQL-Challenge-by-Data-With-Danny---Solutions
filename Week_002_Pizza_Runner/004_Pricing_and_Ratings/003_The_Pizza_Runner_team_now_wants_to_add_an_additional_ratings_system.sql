-- The Pizza Runner team now wants to add an additional ratings system that allows customers
-- to rate their runner, how would you design an additional table for this new dataset 
-- generate a schema for this new table and insert your own data for ratings 
-- for each successful customer order between 1 to 5.

DROP TABLE IF EXISTS pizza_runner.runner_ratings;
CREATE TABLE pizza_runner.runner_ratings (
  "order_id" INTEGER PRIMARY KEY NOT NULL,
  "rating" INTEGER NOT NULL CHECK (rating >= 0 AND rating <= 5),
  "rating_time" TIMESTAMP NOT NULL
);
INSERT INTO pizza_runner.runner_ratings
  ("order_id", "rating", "rating_time")
VALUES
  (1, 1, '2020-01-01 18:18:34'),
  (3, 5, '2020-01-03 00:15:37'),
  (4, 4, '2020-01-04 13:53:03'),
  (7, 2, '2020-01-08 21:45:45'),
  (8, 2, '2020-01-10 00:20:02'),
  (10, 1, '2020-01-11 20:10:20');

-- query

SELECT
	*
FROM 
	pizza_runner.runner_ratings;

-- alternative

SELECT SETSEED(1);

DROP TABLE IF EXISTS pizza_runner.ratings;
CREATE TABLE pizza_runner.ratings (
  "order_id" INTEGER,
  "rating" INTEGER
);

INSERT INTO pizza_runner.ratings
SELECT
  order_id,
  FLOOR(1 + 5 * RANDOM()) AS rating
FROM pizza_runner.runner_orders
WHERE pickup_time IS NOT NULL;