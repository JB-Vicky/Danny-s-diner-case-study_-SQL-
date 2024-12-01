
CREATE SCHEMA dannys_diner;

 use dannys_diner;
 
CREATE TABLE dannys_diner.sales1 (
  customer_id VARCHAR(1),  
  order_date DATE,        
  product_id INT          
);

INSERT INTO dannys_diner.sales1 (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', 1),
  ('A', '2021-01-01', 2),
  ('A', '2021-01-07', 2),
  ('A', '2021-01-10', 3),
  ('A', '2021-01-11', 3),
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
  
  select * from Sales1;
  
 CREATE TABLE menu (
  product_id INT,          
  product_name VARCHAR(50), 
  price INT                
);

INSERT INTO menu (product_id, product_name, price)
VALUES
  (1, 'sushi', 10),
  (2, 'curry', 15),
  (3, 'ramen', 12);
  
  CREATE TABLE members (
  customer_id VARCHAR(1),  
  join_date DATE           
);

INSERT INTO members (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  select * from Sales1;
  select *from menu;
  select * from members;
  
 --------------------------------------------------------------------------------------------------------------------
  
#1. What is the total amount each customer spent at the restaurant?
#2. How many days has each customer visited the restaurant?
#3. What was the first item from the menu purchased by each customer?
#4. What is the most purchased item on the menu and how many times was it purchased by all customers?
#5. Which item was the most popular for each customer?
#6. Which item was purchased first by the customer after they became a member?
#7. Which item was purchased just before the customer became a member?
#8. What is the total items and amount spent for each member before they became a member?
#9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier, how many points would each customer have?
#10. In the first week after a customer joins the program (including their join date), they earn 2x points on all items, not just sushi. How many points do customers A and B have at the end of January?


#1. What is the total amount each customer spent at the restaurant?

CREATE VIEW CustomerTotalAmountSpent AS
SELECT 
    s.customer_id, 
    SUM(m.price) AS total_amount_spent
FROM sales1 AS s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id;

# Query to Retrieve  - 

SELECT * FROM CustomerTotalAmountSpent;
-------------------------------------------------------------------

#2. How many days has each customer visited the restaurant?

CREATE VIEW CustomerVisitDays AS
SELECT 
    customer_id, 
    COUNT(DISTINCT order_date) AS visit_days
FROM sales1
GROUP BY customer_id;

# Query to Retrieve  - 

SELECT * FROM CustomerVisitDays;
---------------------------------------------------------------------

#3. What was the first item from the menu purchased by each customer?

CREATE VIEW FirstProductPurchased AS
SELECT 
    s.customer_id, 
    m.product_name, 
    ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS rownum
FROM sales1 s
JOIN menu m ON s.product_id = m.product_id;
SELECT customer_id, product_name
FROM FirstProductPurchased
WHERE rownum = 1;

# Query to Retrieve  - 

SELECT * FROM FirstProductPurchased;
----------------------------------------------------------------

 #4. What is the most purchased item on the menu and how many times was it purchased by all customers?
 
CREATE VIEW MostOrderedProduct AS
SELECT m.product_name, 
       COUNT(m.product_name) AS order_count
FROM sales1 s
JOIN menu m ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY COUNT(m.product_name) DESC
LIMIT 1;

# Query to Retrieve  - 

SELECT * FROM MostOrderedProduct;
-----------------------------------------------

#5. Which item was the most popular for each customer?

CREATE VIEW MostOrderedProductByCustomer AS
WITH CTE AS (
    SELECT 
        s.customer_id, 
        m.product_name,
        COUNT(*) AS Order_Count,
        DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY COUNT(*) DESC) AS rn
    FROM sales1 s
    JOIN menu m ON s.product_id = m.product_id
    GROUP BY s.customer_id, m.product_name
)
SELECT customer_id, product_name
FROM CTE
WHERE rn = 1;

# Query to Retrieve  - 

SELECT * FROM MostOrderedProductByCustomer;
------------------------------------------------------------

#6. Which item was purchased first by the customer after they became a member?

CREATE VIEW FirstProductPurchasedAfterJoin AS
WITH orders AS (
    SELECT 
        s.customer_id, m.product_name, s.order_date, mb.join_date,
        DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS rn
    FROM menu m
    JOIN sales1 s ON m.product_id = s.product_id
    JOIN members mb ON s.customer_id = mb.customer_id
    WHERE s.order_date > mb.join_date
)
SELECT customer_id, product_name
FROM orders
WHERE rn = 1;

# Query to Retrieve  - 
SELECT * FROM FirstProductPurchasedAfterJoin;

--------------------------------------------------

#7. Which item was purchased just before the customer became a member?

CREATE VIEW LastProductBeforeJoin AS
WITH orders AS (
    SELECT 
        s.customer_id, 
        m.product_name, 
        s.order_date, 
        mb.join_date,
        DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS rn
    FROM menu m
    JOIN sales1 s ON m.product_id = s.product_id
    JOIN members mb ON s.customer_id = mb.customer_id
    WHERE s.order_date < mb.join_date
)
SELECT customer_id, product_name
FROM orders
WHERE rn = 1;

# Query to Retrieve  - 

SELECT * FROM LastProductBeforeJoin;

---------------------------------------------------------------------


 #8. What is the total items and amount spent for each member before they became a member?
 
CREATE VIEW CustomerOrderSummaryBeforeJoin AS
SELECT 
    s.customer_id,
    COUNT(m.product_id) AS total_item_order,
    SUM(m.price) AS total_amount_spent
FROM menu m
JOIN sales1 s ON m.product_id = s.product_id
JOIN members mb ON s.customer_id = mb.customer_id
WHERE s.order_date < mb.join_date
GROUP BY s.customer_id;

# Query to Retrieve  - 

SELECT * FROM CustomerOrderSummaryBeforeJoin;

-----------------------------------------------------------------------

 #9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier, how many points would each customer have?
 
select * from Sales1;
select* from menu;
select * from members;

CREATE VIEW CustomerPoints AS
with cte as(
select s.customer_id, m.product_name, m.price,
case 
when m.product_name = 'sushi' then m.price*10*2
else m.price*10
end as points
from sales1 s
join menu m
on s.product_id = m.product_id
)
select customer_id, sum(points) as total_points
from cte
group by customer_id

# Query to Retrieve  - 

SELECT * FROM CustomerPoints;

----------------------------------------------------------------


#10. In the first week after a customer joins the program (including their join date), they earn 2x points on all items, not just sushi. 
#How many points do customers A and B have at the end of January?

CREATE VIEW CustomerPointsSummary AS
with cte as(
SELECT 
    s.customer_id, m.product_name, m.price, s.order_date, mb.join_date,
    CASE
        WHEN s.order_date BETWEEN mb.join_date AND DATE_ADD(mb.join_date, INTERVAL 7 DAY) THEN m.price * 10 * 2
        WHEN m.product_name = 'sushi' THEN m.price * 10 * 2
        ELSE m.price * 10
    END AS points
FROM menu m
JOIN sales1 s
ON s.product_id = m.product_id
JOIN members mb
ON s.customer_id = mb.customer_id
WHERE s.order_date < '2021-02-01'
)
select customer_id, sum(points) as total_points
from cte 
group by customer_id

# Query to Retrieve  - 

SELECT * FROM CustomerPointsSummary;




  