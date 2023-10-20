/*
Use a single SQL query to transform the product_hierarchy and product_prices datasets to the product_details table.

Hint: you may want to consider using a recursive CTE to solve this problem!
*/

/*
1.
`product_hierarchy`

| id  | parent_id  | level_text           | level_name |
|-----|------------|----------------------|------------|
| 1   |            | Womens               | Category   |
| 2   |            | Mens                 | Category   |
| 3   | 1          | Jeans                | Segment    |
| 4   | 1          | Jacket               | Segment    |
| 5   | 2          | Shirt                | Segment    |
| 6   | 2          | Socks                | Segment    |
| 7   | 3          | Navy Oversized       | Style      |
| 8   | 3          | Black Straight       | Style      |
| 9   | 3          | Cream Relaxed        | Style      |
| 10  | 4          | Khaki Suit           | Style      |
| 11  | 4          | Indigo Rain          | Style      |
| 12  | 4          | Grey Fashion         | Style      |
| 13  | 5          | White Tee            | Style      |
| 14  | 5          | Teal Button Up       | Style      |
| 15  | 5          | Blue Polo            | Style      |
| 16  | 6          | Navy Solid           | Style      |
| 17  | 6          | White Striped        | Style      |
| 18  | 6          | Pink Fluro Polkadot  | Style      |
*/

/*
`product_prices`
| id  | product_id  | price |
|-----|-------------|-------|
| 7   | c4a632      | 13    |
| 8   | e83aa3      | 32    |
| 9   | e31d39      | 10    |
| 10  | d5e9a6      | 23    |
| 11  | 72f5d4      | 19    |
| 12  | 9ec847      | 54    |
| 13  | 5d267b      | 40    |
| 14  | c8d436      | 10    |
| 15  | 2a2353      | 57    |
| 16  | f084eb      | 36    |
| 17  | b9a74d      | 17    |
| 18  | 2feb6b      | 29    |
...
*/

/*
`product_details`

| product_id  | price  | product_name                   | category_id  | segment_id  | style_id  | category_name  | segment_name  | style_name     |
|-------------|--------|--------------------------------|--------------|-------------|-----------|----------------|---------------|----------------|
| c4a632      | 13     | Navy Oversized Jeans - Womens  | 1            | 3           | 7         | Womens         | Jeans         | Navy Oversized |
| e83aa3      | 32     | Black Straight Jeans - Womens  | 1            | 3           | 8         | Womens         | Jeans         | Black Straight |
| e31d39      | 10     | Cream Relaxed Jeans - Womens   | 1            | 3           | 9         | Womens         | Jeans         | Cream Relaxed  |
| d5e9a6      | 23     | Khaki Suit Jacket - Womens     | 1            | 4           | 10        | Womens         | Jacket        | Khaki Suit     |
| 72f5d4      | 19     | Indigo Rain Jacket - Womens    | 1            | 4           | 11        | Womens         | Jacket        | Indigo Rain    |
*/

DROP TABLE IF EXISTS temp_product_details;
CREATE TEMP TABLE temp_product_details AS
WITH RECURSIVE output_table
(id, category_id, segment_id, style_id, category_name, segment_name, style_name)
AS (

  SELECT
    id,
    id AS category_id,
    NULL::INTEGER AS segment_id,
    NULL::INTEGER AS style_id,
    level_text AS category_name,
    NULL AS segment_name,
    NULL AS style_name
  FROM balanced_tree.product_hierarchy
  WHERE parent_id IS NULL

  UNION ALL

  SELECT
    ph.id,
    CASE 
      WHEN ph.level_name = 'Category' THEN ph.id
      ELSE ot.category_id
    END,
    CASE 
      WHEN ph.level_name = 'Segment' THEN ph.id
      ELSE ot.segment_id
    END,
    CASE 
      WHEN ph.level_name = 'Style' THEN ph.id
      ELSE ot.style_id
    END,
    ot.category_name,
    CASE 
      WHEN ph.level_name = 'Segment' THEN ph.level_text
      ELSE ot.segment_name
    END,
    CASE 
      WHEN ph.level_name = 'Style' THEN ph.level_text
      ELSE ot.style_name
    END
  FROM output_table ot
  INNER JOIN balanced_tree.product_hierarchy ph
    ON ot.id = ph.parent_id
)
SELECT 
  pp.product_id, 
  pp.price, 
  ot.style_name || ' ' || ot.segment_name || ' - ' || ot.category_name AS product_name,
  ot.category_id,
  ot.segment_id,
  ot.style_id,
  ot.category_name,
  ot.segment_name,
  ot.style_name
FROM output_table ot
INNER JOIN balanced_tree.product_prices pp
  ON ot.id = pp.id
WHERE ot.style_name IS NOT NULL;

SELECT * FROM temp_product_details
;

/*
| product_id  | price  | product_name                      | category_id  | segment_id  | style_id  | category_name  | segment_name  | style_name          |
|-------------|--------|-----------------------------------|--------------|-------------|-----------|----------------|---------------|---------------------|
| c4a632      | 13     | Navy Oversized Jeans - Womens     | 1            | 3           | 7         | Womens         | Jeans         | Navy Oversized      |
| e83aa3      | 32     | Black Straight Jeans - Womens     | 1            | 3           | 8         | Womens         | Jeans         | Black Straight      |
| e31d39      | 10     | Cream Relaxed Jeans - Womens      | 1            | 3           | 9         | Womens         | Jeans         | Cream Relaxed       |
| d5e9a6      | 23     | Khaki Suit Jacket - Womens        | 1            | 4           | 10        | Womens         | Jacket        | Khaki Suit          |
| 72f5d4      | 19     | Indigo Rain Jacket - Womens       | 1            | 4           | 11        | Womens         | Jacket        | Indigo Rain         |
| 9ec847      | 54     | Grey Fashion Jacket - Womens      | 1            | 4           | 12        | Womens         | Jacket        | Grey Fashion        |
| 5d267b      | 40     | White Tee Shirt - Mens            | 2            | 5           | 13        | Mens           | Shirt         | White Tee           |
| c8d436      | 10     | Teal Button Up Shirt - Mens       | 2            | 5           | 14        | Mens           | Shirt         | Teal Button Up      |
| 2a2353      | 57     | Blue Polo Shirt - Mens            | 2            | 5           | 15        | Mens           | Shirt         | Blue Polo           |
| f084eb      | 36     | Navy Solid Socks - Mens           | 2            | 6           | 16        | Mens           | Socks         | Navy Solid          |
| b9a74d      | 17     | White Striped Socks - Mens        | 2            | 6           | 17        | Mens           | Socks         | White Striped       |
| 2feb6b      | 29     | Pink Fluro Polkadot Socks - Mens  | 2            | 6           | 18        | Mens           | Socks         | Pink Fluro Polkadot |
*/