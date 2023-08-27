-- Q1. What is the total amount each customer spent at the restaurant?

SELECT
	s.customer_id,
    SUM(m.price) as total_spend
FROM dannys_diner.sales s
JOIN dannys_diner.menu m ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY total_spend DESC;

-- Q2. How many days has each customer visited the restaurant?

SELECT
	customer_id,
    COUNT(DISTINCT order_date) as num_days
FROM dannys_diner.sales
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?

WITH first_order as(
SELECT
	s.customer_id,
    m.product_name,
  	DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) as order_num
FROM dannys_diner.sales s
JOIN dannys_diner.menu m ON s.product_id = m.product_id)

SELECT customer_id, product_name FROM first_order
WHERE order_num = 1
GROUP BY customer_id, product_name;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT product_name, COUNT(s.product_id) as num_purchases
FROM dannys_diner.sales s
JOIN dannys_diner.menu m ON s.product_id = m.product_id
GROUP BY product_name
ORDER BY num_purchases DESC
LIMIT 1;

-- 5. Which item was the most popular for each customer?

WITH fav_product as(
SELECT 
	s.customer_id, 
    m.product_name, 
    COUNT(s.product_id) as buy_freq,
    DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY COUNT(s.product_id) DESC) as popularity_level
FROM dannys_diner.sales s
JOIN dannys_diner.menu m ON s.product_id = m.product_id
GROUP BY customer_id, product_name)

SELECT customer_id, product_name, buy_freq
FROM fav_product
WHERE popularity_level = 1;

-- 6. Which item was purchased first by the customer after they became a member?

WITH first_order as(
SELECT
	s.customer_id,
    m.product_name,
  	DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) as order_num
FROM dannys_diner.sales s
JOIN dannys_diner.menu m ON s.product_id = m.product_id
JOIN dannys_diner.members me ON me.customer_id = s.customer_id 
  AND s.order_date > me.join_date)

SELECT customer_id, product_name FROM first_order
WHERE order_num = 1
GROUP BY customer_id, product_name;

-- 7. Which item was purchased just before the customer became a member?

WITH first_order as(
SELECT
	s.customer_id,
    m.product_name,
  	ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC) as order_num
FROM dannys_diner.sales s
JOIN dannys_diner.menu m ON s.product_id = m.product_id
JOIN dannys_diner.members me ON me.customer_id = s.customer_id 
  AND s.order_date < me.join_date)

SELECT customer_id, product_name FROM first_order
WHERE order_num = 1
GROUP BY customer_id, product_name;

-- 8. What is the total items and amount spent for each member before they became a member?

SELECT
	s.customer_id,
    COUNT(s.product_id) as total_items,
    SUM(m.price) as total_spend
FROM dannys_diner.sales s
JOIN dannys_diner.menu m ON s.product_id = m.product_id
JOIN dannys_diner.members me ON me.customer_id = s.customer_id 
  AND s.order_date < me.join_date
GROUP BY s.customer_id
ORDER BY s.customer_id ASC;

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT 
	s.customer_id,
	SUM(CASE WHEN s.product_id = 1 THEN (m.price*10)*2 ELSE m.price*10 END) as points
FROM dannys_diner.sales s
INNER JOIN dannys_diner.menu m ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;

-- 10. In the first week after a customer joins the program (including their join date) 
--     they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

WITH dates_cte AS (
  SELECT 
    customer_id, 
      join_date, 
      join_date + 6 AS valid_date, 
      DATE_TRUNC(
        'month', '2021-01-31'::DATE)
        + interval '1 month' 
        - interval '1 day' AS last_date
  FROM dannys_diner.members
)

SELECT 
  sales.customer_id, 
  SUM(CASE
    WHEN menu.product_name = 'sushi' THEN 2 * 10 * menu.price
    WHEN sales.order_date BETWEEN dates.join_date AND dates.valid_date THEN 2 * 10 * menu.price
    ELSE 10 * menu.price END) AS points
FROM dannys_diner.sales
INNER JOIN dates_cte AS dates
  ON sales.customer_id = dates.customer_id
  AND dates.join_date <= sales.order_date
  AND sales.order_date <= dates.last_date
INNER JOIN dannys_diner.menu
  ON sales.product_id = menu.product_id
GROUP BY sales.customer_id;