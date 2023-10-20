
DROP SCHEMA IF EXISTS pizza_runner_v CASCADE;
CREATE SCHEMA pizza_runner_v;

DROP MATERIALIZED VIEW IF EXISTS pizza_runner_v.runners;
CREATE MATERIALIZED VIEW pizza_runner_v.runners AS
SELECT
  *
FROM pizza_runner.runners;

DROP MATERIALIZED VIEW IF EXISTS pizza_runner_v.customer_orders;
CREATE MATERIALIZED VIEW pizza_runner_v.customer_orders AS
SELECT
  order_id,
  customer_id,
  pizza_id,
  CASE
    WHEN exclusions IS NOT NULL AND exclusions NOT IN ('NaN', '', 'null') THEN
      ARRAY(SELECT unnest(string_to_array(exclusions, ', '))::integer)
    ELSE
      NULL
  END AS exclusions,
  CASE
    WHEN extras IS NOT NULL AND extras NOT IN ('NaN', '', 'null') THEN
      ARRAY(SELECT unnest(string_to_array(extras, ', '))::integer)
    ELSE
      NULL
  END AS extras,
  order_time
FROM pizza_runner.customer_orders;

DROP MATERIALIZED VIEW IF EXISTS pizza_runner_v.runner_orders;
CREATE MATERIALIZED VIEW pizza_runner_v.runner_orders AS
SELECT
  order_id,
  runner_id,
  CASE
    WHEN pickup_time IS NOT NULL AND pickup_time NOT IN ('NaN', '', 'null') THEN
      pickup_time::timestamp without time zone
    ELSE
      NULL
  END AS pickup_time,
  CASE
    WHEN distance IS NOT NULL AND distance NOT IN ('NaN', '', 'null') THEN
      CASE
        WHEN distance ILIKE '%km%' THEN
          REGEXP_REPLACE(LOWER(distance), 'km| ', '', 'g')::NUMERIC
        ELSE
          distance::NUMERIC
      END
    ELSE
      NULL
  END AS distance,
  CASE
    WHEN duration IS NOT NULL AND duration NOT IN ('NaN', '', 'null') THEN
      (REGEXP_REPLACE(LOWER(duration), 'mins|minute|minutes| ', '', 'g')::NUMERIC * INTERVAL '1 minute')
    ELSE
      NULL
  END AS duration,
  CASE
    WHEN cancellation ILIKE '%cancellation%' THEN
      REGEXP_REPLACE(LOWER(cancellation), 'cancellation| ', '', 'g')
    ELSE
      NULL
  END AS cancellation
FROM pizza_runner.runner_orders;

DROP MATERIALIZED VIEW IF EXISTS pizza_runner_v.pizza_names;
CREATE MATERIALIZED VIEW pizza_runner_v.pizza_names AS
SELECT
  *
FROM pizza_runner.pizza_names;

DROP MATERIALIZED VIEW IF EXISTS pizza_runner_v.pizza_recipes;
CREATE MATERIALIZED VIEW pizza_runner_v.pizza_recipes AS
SELECT
  pizza_id,
  CASE
    WHEN toppings IS NOT NULL AND toppings NOT IN ('NaN', '', 'null') THEN
      ARRAY(SELECT unnest(string_to_array(toppings, ', '))::integer)
    ELSE
      NULL
  END AS toppings
FROM pizza_runner.pizza_recipes;

DROP MATERIALIZED VIEW IF EXISTS pizza_runner_v.pizza_toppings;
CREATE MATERIALIZED VIEW pizza_runner_v.pizza_toppings AS
SELECT
  *
FROM pizza_runner.pizza_toppings;