CREATE DATABASE my_database;


-- Create the sales table
CREATE TABLE sales (
    customer_id VARCHAR(1),
    order_date DATE,
    product_id INT
);

-- Insert sample data into the sales table
INSERT INTO sales (customer_id, order_date, product_id)
VALUES
('A', '2021-01-01', 1),
('A', '2021-01-01', 2),
('A', '2021-01-07', 2),
('A', '2021-01-10', 3),
('A', '2021-01-11', 3),
('B', '2021-01-01', 2),
('B', '2021-01-02', 2),
('B', '2021-01-04', 1),
('B', '2021-01-11', 1),
('B', '2021-01-16', 3),
('B', '2021-02-01', 3),
('C', '2021-01-01', 3),
('C', '2021-01-01', 3),
('C', '2021-01-07', 3);

-- Create the menu table
CREATE TABLE menu (
    product_id INT,
    product_name VARCHAR(10),
    price DECIMAL(5,2)
);

-- Insert sample data into the menu table
INSERT INTO menu (product_id, product_name, price)
VALUES
(1, 'sushi', 10.00),
(2, 'curry', 15.00),
(3, 'ramen', 12.00);

-- Create the members table
CREATE TABLE members (
    customer_id VARCHAR(1),
    join_date DATE
);

-- Insert sample data into the members table
INSERT INTO members (customer_id, join_date)
VALUES
('A', '2021-01-07'),
('B', '2021-01-09');

-- 1. What is the total amount each customer spent at the restaurant?
SELECT SUM(m.price) AS total_amount , s.customer_id AS customer
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id;

-- 2. How many days has each customer visited the restaurant?
-- 3. What was the first item from the menu purchased by each customer?
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?