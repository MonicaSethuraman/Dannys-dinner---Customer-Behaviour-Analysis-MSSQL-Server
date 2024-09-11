# Dannys-dinner---Customer-Behaviour-Analysis-MSSQL-Server

SQL project and the data used was part of a case study provide dataset [here](https://8weeksqlchallenge.com/case-study-1/). It focuses on examining patterns, trends, and factors influencing customer spending in order to gain insights into their preferences, purchasing habits, and potential areas for improvement in menu offerings or marketing strategies in a dining establishment.

![image](https://github.com/user-attachments/assets/dd1e6401-805b-4e31-bc4a-a779f00c2b15)


## Background
Danny seriously loves Japanese food so in the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: sushi, curry and ramen. Danny’s Diner is in need of your assistance to help the restaurant stay afloat - the restaurant has captured some very basic data from their few months of operation but have no idea how to use their data to help them run the business.

## Problem Statement
Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favorite. Having this deeper connection with his customers will help him deliver a better and more personalized experience for his loyal customers.

He plans on using these insights to help him decide whether he should expand the existing customer loyalty program - additionally he needs help to generate some basic datasets so his team can easily inspect the data without needing to use SQL.

Danny has provided you with a sample of his overall customer data due to privacy issues - but he hopes that these examples are enough for you to write fully functioning SQL queries to help him answer his questions!

## Entity Relationship Diagram

Danny has shared with you 3 key datasets for this case study:

- sales
- menu
- members

![image](https://github.com/user-attachments/assets/f816c306-6a3c-4033-9d29-6cf2c147b554)


## Skills Applied
Window Functions
CTEs
Aggregations
JOINs
Write scripts to generate basic reports that can be run every period

## Tables Used

### sales Table

The sales table captures all customer_id level purchases with an corresponding order_date and product_id information for when and what menu items were ordered.

| customer_id | order_date | product_id |
|-------------|------------|------------|
| A           | 2021-01-01 | 1          |
| A           | 2021-01-01 | 2          |
| A           | 2021-01-07 | 2          |
| A           | 2021-01-10 | 3          |
| A           | 2021-01-11 | 3          |
| A           | 2021-01-11 | 3          |
| B           | 2021-01-01 | 2          |
| B           | 2021-01-02 | 2          |
| B           | 2021-01-04 | 1          |
| B           | 2021-01-11 | 1          |
| B           | 2021-01-16 | 3          |
| B           | 2021-02-01 | 3          |
| C           | 2021-01-01 | 3          |
| C           | 2021-01-01 | 3          |
| C           | 2021-01-07 | 3          |

### menu Table

The menu table maps the product_id to the actual product_name and price of each menu item.

| product_id | product_name | price |
|------------|--------------|-------|
| 1          | sushi        | 10    |
| 2          | curry        | 15    |
| 3          | ramen        | 12    |

### members Table

The final members table captures the join_date when a customer_id joined the beta version of the Danny’s Diner loyalty program.

| customer_id | join_date   |
|-------------|-------------|
| A           | 2021-01-07  |
| B           | 2021-01-09  |

## Questions Explored
1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
8. What is the total items and amount spent for each member before they became a member?
9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

## Some interesting queries
Q1. What is the total amount each customer spent at the restaurant?



```sql
SELECT
SUM(m.price) AS total_amount ,
s.customer_id AS customer
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id;
```
Q2. How many days has each customer visited the restaurant?



```sql
SELECT
customer_id,
COUNT(DISTINCT order_date) AS customer_visits 
FROM sales 
GROUP BY customer_id;
```

Q3. What was the first item from the menu purchased by each customer?

```sql
WITH RankedPurchases AS (
    SELECT 
        s.customer_id, 
        m.product_name, 
        s.order_date,
        ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.order_date ASC) AS row_num
    FROM sales s
    JOIN menu m ON s.product_id = m.product_id
)
SELECT customer_id, product_name, order_date
FROM RankedPurchases
WHERE row_num = 1;
```
Q4. What is the most purchased item on the menu and how many times was it purchased by all customers?

```sql

SELECT 
    m.product_name, 
    COUNT(s.product_id) AS purchase_count
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY purchase_count DESC
LIMIT 1;

```

Q5 - Which item was the most popular for each customer?

### SQL Query

```sql
with popular as (
SELECT 
    m.product_name, 
    COUNT(s.product_id) AS popular_item,
    ROW_NUMBER() OVER (PARTITION BY m.product_name ORDER BY COUNT(s.product_id) DESC) AS row_num
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY m.product_name
)
SELECT product_name ,popular_item
FROM popular 
WHERE 
    row_num = 1;
```

Q6. Which item was purchased first by the customer after they became a member?

```sql
 WITH FirstPurchase AS (
    SELECT 
        s.customer_id, 
        s.order_date, 
        s.product_id,
        ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.order_date ASC) AS row_num
    FROM 
        sales s JOIN members mb ON s.customer_id = mb.customer_id
    WHERE 
        s.order_date >= mb.join_date
)
SELECT 
    fp.customer_id, 
    m.product_name, 
    fp.order_date
FROM 
    FirstPurchase fp
JOIN 
    menu m ON fp.product_id = m.product_id
WHERE 
    fp.row_num = 1;
```
#### WHERE s.order_date >= mb.join_date: Ensures that only purchases made after the customer became a member are considered.


Q7. Which item was purchased just before the customer became a member?

```sql
WITH LastPurchaseBeforeMembership AS (
    SELECT 
        s.customer_id, 
        s.order_date, 
        s.product_id,
        ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS row_num
    FROM 
        sales s
    JOIN 
        members mb ON s.customer_id = mb.customer_id
    WHERE 
        s.order_date < mb.join_date
)
SELECT 
    fp.customer_id, 
    m.product_name, 
    fp.order_date
FROM 
    LastPurchaseBeforeMembership fp
JOIN 
    menu m ON fp.product_id = m.product_id
WHERE 
    fp.row_num = 1;
```
Q8. What is the total items and amount spent for each member before they became a member?

```sql

SELECT 
    s.customer_id, 
    COUNT(s.product_id) AS total_items_purchased,
    SUM(m.price) AS total_amount_spent
FROM 
    sales s
JOIN 
    menu m ON s.product_id = m.product_id
JOIN 
    members mb ON s.customer_id = mb.customer_id
WHERE 
    s.order_date < mb.join_date
GROUP BY 
    s.customer_id;

```


Q9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

```sql

SELECT 
    s.customer_id, 
    SUM(
        CASE 
            WHEN m.product_name = 'sushi' THEN m.price * 20 -- 2x points for sushi
            ELSE m.price * 10 -- 10 points per $1 for all other products
        END
    ) AS total_points
FROM 
    sales s
JOIN 
    menu m ON s.product_id = m.product_id
GROUP BY 
    s.customer_id;
```


Q10 - In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

```sql
SELECT s.customer_id, SUM(
    CASE 
        WHEN s.order_date BETWEEN mb.join_date AND DATEADD(day, 7, mb.join_date) THEN m.price*20
        WHEN m.product_name = 'sushi' THEN m.price*20 
        ELSE m.price*10 
    END) AS total_points
FROM dbo.sales s
JOIN dbo.menu m ON s.product_id = m.product_id
LEFT JOIN dbo.members mb ON s.customer_id = mb.customer_id
WHERE s.customer_id IN ('A', 'B') AND s.order_date <= '2021-01-31'
GROUP BY s.customer_id;
```

Bonus Q2 - Danny also requires further information about the ranking of products. he purposely does not need the ranking of non member purchases so he expects NULL ranking values for customers who are not yet part of the loyalty program.

```sql
WITH customers_data AS (
  SELECT 
    s.customer_id, 
    s.order_date,  
    m.product_name, 
    m.price,
    CASE
      WHEN s.order_date < mb.join_date THEN 'N'
      WHEN s.order_date >= mb.join_date THEN 'Y'
      ELSE 'N' 
    END AS member
  FROM sales s
  LEFT JOIN members mb
    ON s.customer_id = mb.customer_id
  JOIN menu m
    ON s.product_id = m.product_id
)
SELECT 
  *, 
  CASE
    WHEN member = 'N' THEN NULL
    ELSE RANK() OVER(
      PARTITION BY customer_id, member
      ORDER BY order_date) 
  END AS ranking
FROM customers_data
ORDER BY customer_id, order_date;
```
## Insights
- Customer B is the most frequent visitor with 6 visits in Jan 2021.
- Danny’s Diner’s most popular item is ramen, followed by curry and sushi.
- Customer A loves ramen, Customer C loves only ramen whereas Customer B seems to enjoy sushi, curry and ramen equally.



