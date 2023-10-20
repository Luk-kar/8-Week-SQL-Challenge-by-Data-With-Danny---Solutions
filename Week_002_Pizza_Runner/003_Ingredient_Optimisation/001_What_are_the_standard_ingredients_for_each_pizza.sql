-- 1. What are the standard ingredients for each pizza?

SELECT
  pizza_names.pizza_name,
  STRING_AGG(pizza_toppings.topping_name, ', ') AS toppings
FROM pizza_runner_v.pizza_names
JOIN pizza_runner_v.pizza_recipes ON pizza_names.pizza_id = pizza_recipes.pizza_id
JOIN pizza_runner_v.pizza_toppings ON pizza_toppings.topping_id = ANY(pizza_recipes.toppings)
GROUP BY pizza_names.pizza_name
ORDER BY pizza_names.pizza_name;

-- pizza_name 	toppings
-- Meatlovers 	Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami
-- Vegetarian 	Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce
