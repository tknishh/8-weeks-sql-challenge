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
