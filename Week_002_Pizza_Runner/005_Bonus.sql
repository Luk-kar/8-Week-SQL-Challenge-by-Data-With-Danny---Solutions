-- 5. BONUS If Danny wants to expand his range of pizzas - 
-- how would this impact the existing data design? 
-- Write an INSERT statement to demonstrate what would happen 
-- if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?

DROP TABLE IF EXISTS temp_pizza_names;

CREATE TEMP TABLE temp_pizza_names AS
SELECT * FROM pizza_runner.pizza_names;

INSERT INTO temp_pizza_names
  ("pizza_id", "pizza_name")
VALUE
  (3, 'Supreme');

SELECT
  *
FROM temp_pizza_names

DROP TABLE IF EXISTS temp_pizza_recipes;
CREATE TEMP TABLE temp_pizza_recipes AS
SELECT * FROM pizza_runner.pizza_recipes;

INSERT INTO temp_pizza_recipes ("pizza_id", "toppings")
SELECT 3, STRING_AGG(topping_id::TEXT, ', ')
FROM pizza_runner.pizza_toppings;

SELECT * FROM temp_pizza_recipes;
