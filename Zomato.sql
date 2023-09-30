CREATE DATABASE zomatoDB;
USE zomatoDB;

DROP TABLE IF EXISTS goldusers_signup;
CREATE TABLE goldusers_signup(
userid INTEGER,
gold_signup_date DATE
);

INSERT INTO goldusers_signup(userid, gold_signup_date) VALUES(1, '09-22-2017'),
															 (3, '04-21-2017');
															 
DROP TABLE IF EXISTS users;
CREATE TABLE users(
userid INTEGER,
signup_date DATE
);

INSERT INTO users(userid, signup_date) VALUES(1, '09-02-2014'),
											 (2, '01-15-2015'),
											 (3, '04-11-2014');

DROP TABLE IF EXISTS sales;
CREATE TABLE sales(
userid INTEGER,
created_date DATE,
product_id INTEGER
);

INSERT INTO sales(userid, created_date, product_id) VALUES(1, '04-19-2017', 2),
														  (3, '12-18-2019', 1),
														  (2, '07-20-2020', 3),
														  (1, '10-23-2019', 2),
														  (1, '03-19-2018', 3),
														  (3, '12-20-2016', 2),
														  (1, '11-09-2016', 1),
														  (1, '05-20-2016', 3),
														  (2, '09-24-2017', 1),
														  (1, '03-11-2017', 2),
														  (1, '03-11-2016', 1),
														  (3, '11-10-2016', 1),
														  (3, '12-07-2017', 2),
														  (3, '12-15-2016', 2),
														  (2, '11-08-2017', 2),
														  (2, '09-10-2018', 3);

DROP TABLE IF EXISTS product;
CREATE TABLE product(
productid INTEGER,
productName TEXT,
price INTEGER
);

INSERT INTO product(productid, productName, price) VALUES(1,'p1', 980),
														 (2,'p2', 870),
														 (3,'p3', 330);


SELECT * FROM users;
SELECT * FROM product;
SELECT * FROM sales;
SELECT * FROM goldusers_signup;

--What is the total amount each customer spent on Zomato?

SELECT a.userid, SUM(b.price) AS total_sale FROM sales a INNER JOIN product b 
ON a.product_id = b.productid GROUP BY a.userid

--How many days has each customer visited Zomato?

SELECT userid, COUNT(DISTINCT created_date) AS 'distinct days' FROM sales GROUP BY userid;

--What was the first product purchased by each customer?

SELECT * FROM
(SELECT *, RANK() OVER(PARTITION BY userid ORDER BY created_date) AS rnk FROM sales) 
a WHERE rnk = 1;

--What is the most purchased item on the menu and how many times was it purchased by all customer?


SELECT userid, COUNT(product_id) FROM sales WHERE product_id=
(SELECT TOP 1 product_id FROM sales GROUP BY product_id ORDER BY COUNT(product_id) DESC)
GROUP BY userid

--Which item was most popular for each customer?

SELECT * FROM
(SELECT *, RANK() OVER(PARTITION BY userid ORDER BY cnt DESC) rnk FROM
(SELECT userid, product_id, COUNT(product_id) cnt FROM sales GROUP BY product_id , userid)a)b
WHERE rnk = 1

-- Which item was purchased first by the customer after they became a member?

SELECT * FROM 
(SELECT c.*, RANK() OVER(PARTITION by userid ORDER BY created_date) rnk FROM 
(SELECT b.userid, b.created_date,b.product_id, a.gold_signup_date FROM goldusers_signup a
INNER JOIN sales b ON a.userid = b.userid AND created_date>=gold_signup_date) c) d
WHERE rnk=1;

--Which item was purchased just before the customer became a member?

SELECT * FROM
(SELECT c.*, RANK() OVER(PARTITION BY userid ORDER BY created_date DESC)rnk FROM
(SELECT a.userid, a.created_date, a.product_id, b.gold_signup_date FROM sales a 
INNER JOIN goldusers_signup b ON a.userid = b.userid AND created_date <= gold_signup_date)c)d
WHERE rnk =1;

-- What is the total orders and amount spent for each member before they became a member?

SELECT userid, COUNT(created_date) AS total_order, SUM(price) AS total_spent FROM
(SELECT c.*, d.price FROM
(SELECT a.userid, a.created_date, a.product_id, b.gold_signup_date FROM sales a 
INNER JOIN goldusers_signup b ON a.userid = b.userid AND created_date <= gold_signup_date)c 
INNER JOIN product d ON c.product_id= d.productid) e GROUP BY userid 


-- If buying each product generates points for eg 5rs=2 zomato point and each product has 
-- different purchasing points for eg for p1 5rs=1 zomato point , for p2 10rs= 5zomato point
-- and p3 5rs=1zomato point

-- Calculate points collected by each customers and for which product most points have been 
-- given till now?


SELECT userid, SUM(total_points)*2.5 total_money_earned FROM 
(SELECT e.*, amt/points AS total_points FROM
(SELECT d.*, CASE WHEN product_id = 1 THEN 5 WHEN product_id=2 THEN 2 WHEN product_id=3 THEN 5
ELSE 0 END AS points FROM
(SELECT c.userid, c.product_id, SUM(price) AS amt FROM 
(SELECT a.*, b.price FROM sales a INNER JOIN product b ON a.product_id = b.productid)c
GROUP BY userid, product_id)d)e)f GROUP BY userid;


SELECT * FROM
(SELECT *, RANK() OVER(ORDER BY total_points_earned DESC) rnk FROM
(SELECT product_id, SUM(total_points) total_points_earned FROM 
(SELECT e.*, amt/points AS total_points FROM
(SELECT d.*, CASE WHEN product_id = 1 THEN 5 WHEN product_id=2 THEN 2 WHEN product_id=3 THEN 5
ELSE 0 END AS points FROM
(SELECT c.userid, c.product_id, SUM(price) AS amt FROM 
(SELECT a.*, b.price FROM sales a INNER JOIN product b ON a.product_id = b.productid)c
GROUP BY userid, product_id)d)e)f GROUP BY product_id)g)i WHERE rnk=1 ;


-- In the first one year after a customer joins the gold program (including their join date)
-- irrespective of what the customer has purchased they earn 5 zomato points for every 10rs
-- spent who earn 1 or 3 and what was their points earnings in their first year?

1zp = 2rs
0.5zp = 1rs

SELECT c.*, d.price*0.5 AS total_points_earned FROM 
(SELECT a.*, b.gold_signup_date FROM sales a INNER JOIN goldusers_signup b ON 
a.userid=b.userid AND a.created_date>= b.gold_signup_date 
AND a.created_date<= DATEADD(YEAR,1,gold_signup_date))c INNER JOIN product d 
ON c.product_id = d.productid;

--Rank all the transaction of the customer?

SELECT *, RANK() OVER(PARTITION BY userid ORDER BY created_date) rnk FROM sales;


-- Rank all the transactions of each member whenever they are a zomato gold member for every
-- non gold member transaction mark as NA.

SELECT d.*, CASE WHEN rnk=0 THEN 'NA' ELSE rnk END AS rnkk FROM
(SELECT c.*,CAST((CASE WHEN gold_signup_date is NULL THEN 0 ELSE RANK() OVER(PARTITION BY userid 
ORDER BY created_date DESC) END) AS VARCHAR) AS rnk FROM
(SELECT a.*, b.gold_signup_date FROM sales a LEFT JOIN goldusers_signup b 
ON a.userid = b.userid AND created_date>= gold_signup_date)c)d;

