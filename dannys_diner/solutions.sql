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