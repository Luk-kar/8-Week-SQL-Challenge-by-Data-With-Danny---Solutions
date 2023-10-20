-- 1. What is the total amount each customer spent at the restaurant?
-- customer_id 	sum

-- Example Query:

SELECT
	dannys_diner.sales.customer_id AS customer_id,
  	SUM(dannys_diner.menu.price) AS total_spent
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu ON dannys_diner.sales.product_id=dannys_diner.menu.product_id
GROUP BY customer_id
ORDER BY total_spent DESC;

-- A 	76
-- B 	74
-- C 	36

-- 2. How many days has each customer visited the restaurant?
-- customer_id 	days_visited

SELECT 
sales.customer_id AS customer_id, 
COUNT(DISTINCT sales.order_date) AS number_of_days_visited
FROM dannys_diner.sales AS sales
GROUP BY customer_id
ORDER BY customer_id;

-- A 	4
-- B 	6
-- C 	2

-- 3. What was the first item from the menu purchased by each customer?

SELECT DISTINCT
    sales.customer_id AS customer_id,
    FIRST_VALUE(menu.product_name) OVER ordered_sales AS dish,
    (FIRST_VALUE(sales.order_date) OVER ordered_sales)::DATE AS order_date

FROM dannys_diner.sales AS sales
INNER JOIN dannys_diner.menu AS menu ON sales.product_id = menu.product_id
WINDOW
  ordered_sales AS (PARTITION BY sales.customer_id ORDER BY sales.order_date)
ORDER BY customer_id;

-- | customer_id | dish  | order_date |
-- |-------------|-------|------------|
-- | A           | curry | 2021-01-01 |
-- | B           | curry | 2021-01-01 |
-- | C           | ramen | 2021-01-01 |


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT
	menu.product_name AS product_name,
	COUNT(menu.product_name) as total_orders
FROM dannys_diner.sales AS sales
INNER JOIN dannys_diner.menu AS menu ON sales.product_id = menu.product_id
GROUP BY product_name
ORDER BY total_orders DESC
LIMIT 1;

-- | product_name | total_orders |
-- |--------------|--------------|
-- | ramen        | 8            |

-- 5. Which item was the most popular for each customer?

WITH products_per_customer_count AS (
    SELECT
        sales.customer_id AS customer_id,
        menu.product_name AS product_name,
        COUNT(menu.product_name) as total_orders
    FROM dannys_diner.sales AS sales
    INNER JOIN dannys_diner.menu AS menu ON sales.product_id = menu.product_id
    GROUP BY customer_id, product_name
),
ordered_products_per_customer_count AS (
    SELECT
        *,
        RANK() OVER (PARTITION BY customer_id ORDER BY total_orders DESC) AS row_num
    FROM products_per_customer_count
)
SELECT
    customer_id,
    product_name,
    total_orders
FROM ordered_products_per_customer_count
WHERE row_num = 1
ORDER BY customer_id, product_name;

-- | customer_id | product_name | total_orders |
-- |-------------|--------------|--------------|
-- | A           | ramen        | 3            |
-- | B           | curry        | 2            |
-- | B           | ramen        | 2            |
-- | B           | sushi        | 2            |
-- | C           | ramen        | 3            |

-- 6. Which item was purchased first by the customer after they became a member?
-- customer_id 	product_name

WITH members_products_order_dates AS (
  SELECT
      sales.customer_id,
      menu.product_name,
      sales.order_date,
      members.join_date,
      RANK() OVER (PARTITION BY sales.customer_id ORDER BY sales.order_date) AS order_buy
  FROM dannys_diner.sales AS sales
  LEFT JOIN dannys_diner.menu AS menu ON sales.product_id = menu.product_id
  LEFT JOIN dannys_diner.members AS members ON sales.customer_id = members.customer_id
  WHERE sales.order_date >= members.join_date
)
SELECT
    customer_id,
    order_date,
    product_name
FROM members_products_order_dates
WHERE order_buy = 1
ORDER BY customer_id;

-- | customer_id | order_date               | product_name |
-- |-------------|--------------------------|--------------|
-- | A           | 2021-01-07T00:00:00.000Z | curry        |
-- | B           | 2021-01-11T00:00:00.000Z | sushi        |

-- 7. Which item was purchased just before the customer became a member?
-- customer_id 	product_name

WITH members_products_order_dates AS (
  SELECT
      sales.customer_id,
      menu.product_name,
      sales.order_date,
      members.join_date,
      RANK() OVER (PARTITION BY sales.customer_id ORDER BY sales.order_date DESC) AS order_buy
  FROM dannys_diner.sales AS sales
  LEFT JOIN dannys_diner.menu AS menu ON sales.product_id = menu.product_id
  LEFT JOIN dannys_diner.members AS members ON sales.customer_id = members.customer_id
  WHERE sales.order_date < members.join_date
)
SELECT
    customer_id,
    product_name
FROM members_products_order_dates
WHERE order_buy = 1
ORDER BY customer_id, product_name;

-- | customer_id | product_name | order_date               |
-- |-------------|--------------|--------------------------|
-- | A           | curry        | 2021-01-01T00:00:00.000Z |
-- | A           | sushi        | 2021-01-01T00:00:00.000Z |
-- | B           | sushi        | 2021-01-04T00:00:00.000Z |

-- 8. What is the total items and amount spent for each member before they became a member?

  SELECT
      sales.customer_id,
      SUM(menu.price) AS total_spent,
      COUNT(menu.product_id) AS number_of_orders
  FROM dannys_diner.sales AS sales
  LEFT JOIN dannys_diner.menu AS menu ON sales.product_id = menu.product_id
  LEFT JOIN dannys_diner.members AS members ON members.customer_id = sales.customer_id
  WHERE sales.order_date < members.join_date
  GROUP BY sales.customer_id
  ORDER BY sales.customer_id
  
-- | customer_id | total_spent | number_of_orders |
-- |-------------|-------------|------------------|
-- | A           | 25          | 2                |
-- | B           | 40          | 3                |

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- customer_id 	total_points
-- B 	94
-- A 	86
-- C 	36

SELECT
    sales.customer_id,
    SUM(
      CASE
        WHEN menu.product_name = 'sushi' THEN price * (2 * 10)
        ELSE price * 10
      END
    ) AS points
FROM dannys_diner.menu AS menu
LEFT JOIN dannys_diner.sales AS sales ON sales.product_id = menu.product_id
GROUP BY sales.customer_id
ORDER BY sales.customer_id;
 
-- | customer_id | total_points   |
-- |-------------|---------------|
-- | A           | 860           |
-- | B           | 940           |
-- | C           | 360           |

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January

WITH customer_points AS (
  SELECT
      sales.customer_id,
      CASE
        WHEN menu.product_name = 'sushi' OR members.join_date IS NOT NULL THEN price * (2 * 10)
        ELSE price * 10
      END AS points
  FROM dannys_diner.sales AS sales
  LEFT JOIN dannys_diner.menu AS menu ON menu.product_id = sales.product_id
  LEFT JOIN dannys_diner.members AS members ON 
  members.customer_id = sales.customer_id AND 
  sales.order_date >= members.join_date AND
  sales.order_date < members.join_date + interval '1 week'
  WHERE sales.order_date < '2021-02-01'
)
SELECT
  	customer_id,
    SUM(points) as total_points_at_end_of_2021_01
FROM customer_points
WHERE customer_id IN ('A', 'B')
GROUP BY customer_id
ORDER BY customer_id;

-- | customer_id | total_points_at_end_of_2021_01  |
-- |-------------|---------------------------------|
-- | A           | 1370                            |
-- | B           | 820                             |

-- 11. Recreate the following table output using the available data:

SELECT
  sales.customer_id,
  sales.order_date,
  menu.product_name,
  menu.price,
  CASE WHEN sales.order_date > members.join_date::DATE THEN 'N'
    ELSE 'Y'
  END AS member
FROM dannys_diner.sales AS sales
LEFT JOIN dannys_diner.menu AS  menu
  ON sales.product_id = menu.product_id
LEFT JOIN dannys_diner.members AS members
  ON members.customer_id = sales.customer_id
ORDER BY
  sales.customer_id,
  sales.order_date;

-- | customer_id | order_date               | product_name | price | member |
-- |-------------|--------------------------|--------------|-------|--------|
-- | A           | 2021-01-01 | curry        | 15    | Y      |
-- | A           | 2021-01-01 | sushi        | 10    | Y      |
-- | A           | 2021-01-07 | curry        | 15    | Y      |
-- | A           | 2021-01-10 | ramen        | 12    | N      |
-- | A           | 2021-01-11 | ramen        | 12    | N      |
-- | A           | 2021-01-11 | ramen        | 12    | N      |
-- | B           | 2021-01-01 | curry        | 15    | Y      |
-- | B           | 2021-01-02 | curry        | 15    | Y      |
-- | B           | 2021-01-04 | sushi        | 10    | Y      |
-- | B           | 2021-01-11 | sushi        | 10    | N      |
-- | B           | 2021-01-16 | ramen        | 12    | N      |
-- | B           | 2021-02-01 | ramen        | 12    | N      |
-- | C           | 2021-01-01 | ramen        | 12    | N      |
-- | C           | 2021-01-01 | ramen        | 12    | N      |
-- | C           | 2021-01-07 | ramen        | 12    | N      |

-- 12. Danny also requires further information about the ranking of customer products, 
-- but he purposely does not need the ranking for non-member purchases 
-- so he expects null ranking values for the records when customers are not yet part of the loyalty program.

WITH joint_sales AS (
SELECT
  sales.customer_id,
  sales.order_date,
  menu.product_name,
  menu.price,
  CASE
    WHEN sales.order_date >= members.join_date THEN 'Y'
    ELSE 'N'
  END AS member
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu
  ON sales.product_id = menu.product_id
LEFT JOIN dannys_diner.members
  ON sales.customer_id = members.customer_id
)
SELECT
  customer_id,
  order_date,
  product_name,
  price,
  member,
  CASE
    WHEN member = 'Y'
    THEN
      DENSE_RANK() OVER (PARTITION BY customer_id, member ORDER BY order_date)
    ELSE
      NULL
  END AS ranking
FROM joint_sales
ORDER BY customer_id, order_date; 