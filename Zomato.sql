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

SELECT * FROM product;
SELECT * FROM sales;
SELECT * FROM users;
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