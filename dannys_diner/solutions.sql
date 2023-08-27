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

