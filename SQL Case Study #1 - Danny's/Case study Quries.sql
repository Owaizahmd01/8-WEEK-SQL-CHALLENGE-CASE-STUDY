/* AUTHOR   - Owaiz Ahammed
 Tool Used  - MYSQL Workbench 8.0 CE
 Created on - Feb'2023*/
 
# Creating a separate database using MYSQL WORKBENCH 8.0 CE

CREATE DATABASE dannys_diner;
use dannys_diner;

CREATE TABLE IF NOT EXISTS orders(
  `customer_id` VARCHAR(1),
  `order_date` DATE,
  `product_id` INTEGER
);
INSERT INTO orders VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 
 SELECT * FROM ORDERS;

CREATE TABLE IF NOT EXISTS menu (
  `product_id` INTEGER,
  `product_name` VARCHAR(5),
  `price` INTEGER
);
INSERT INTO menu
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  
  SELECT * FROM MENU;

CREATE TABLE IF NOT EXISTS members(
  `customer_id` VARCHAR(1),
  `join_date` DATE
);
INSERT INTO members
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  SELECT * FROM MEMBERS;
  
  
  SELECT * FROM ORDERS;
/*       ------OUTPUT ------
|customer_id |	order_date  | product_id   |
------------ | ------------ | -----------
|A	     |  2021-01-01  |	 1        |
|A	     |  2021-01-01  |	 2        |
|A	     |  2021-01-07  |	 2        |
|A	     |	2021-01-10  |	 3        |
|A	     |	2021-01-11  |	 3        |
|A	     |	2021-01-11  |	 3        |
|B	     |	2021-01-01  |	 2        |
|B	     |	2021-01-02  |	 2        |
|B	     |	2021-01-04  |	 1        |
|B	     |	2021-01-11  |	 1        |
|B	     |	2021-01-16  |	 3        |
|B	     |	2021-02-01  |	 3        |
|C	     |	2021-01-01  |	 3        |
|C	     |	2021-01-01  |	 3        |
|C	     |	2021-01-07  |	 3        |
*/
select * from members;
/*     ------  OUTPUT -------
|customer_id |	order_date  |product_id |
------------ | ------------ | -----------
|A	     |  2021-01-01  |	 1      |
|A	     |  2021-01-01  |	 2      |
|A	     |  2021-01-07  |	 2      |
*/
select * from menu;
/*     ------  OUTPUT -------
|customer_id |	order_date  |product_id |
------------ | ------------ | -----------
|A	     |  2021-01-01  |	 1      |
|A	     |  2021-01-01  |	 2      |
|A	     |  2021-01-07  |	 2      |
*/


  --------------------------------------------------------------------------
-- CASE STUDY QUESTIONS --
-------------------------------------------------------------------------

-- Q1.What is the total amount each customer spent at the restaurant?*/
/* --------- SOLUTION --------- */
SELECT CUSTOMER_ID, M.PRODUCT_ID, SUM(PRICE) AS TOTAL_AMOUNT
FROM ORDERS O LEFT JOIN MENU M
ON O.PRODUCT_ID = M.PRODUCT_ID
GROUP BY CUSTOMER_ID;

-- Q2. How many days has each customer visited the restaurant?
/* --------- SOLUTION --------- */

SELECT CUSTOMER_ID, COUNT(DISTINCT ORDER_DATE) AS VISITED_DAYS
FROM ORDERS 
GROUP BY 1;

-- Q3. What was the first item from the menu purchased by each customer?
/* --------- SOLUTION --------- */
SELECT CUSTOMER_ID, PRODUCT_NAME, COUNT(DISTINCT(PRODUCT_ID)) AS PURCHASE_COUNT
FROM( 
     SELECT 
           CUSTOMER_ID,
		   PRODUCT_NAME,
		   O.PRODUCT_ID,
           O.ORDER_DATE,
           DENSE_RANK() OVER(PARTITION BY CUSTOMER_ID ORDER BY PRODUCT_NAME DESC) AS RNK
           FROM ORDERS O JOIN MENU M
           ON O.PRODUCT_ID = M.PRODUCT_ID) A  
           WHERE A.RNK=1
           GROUP BY 1;
           
           
 -- Q4. What is the most purchased item on the menu and how many times was it purchased by all customers?
/* --------- SOLUTION --------- */
SELECT PRODUCT_NAME, COUNT(PRODUCT_ID) AS MOST_PURCHASED
FROM (
     SELECT 
          CUSTOMER_ID,
          M.PRODUCT_ID,
          PRODUCT_NAME,
          DENSE_RANK() OVER(PARTITION BY CUSTOMER_ID ORDER BY PRODUCT_ID DESC) AS RNK
          FROM ORDERS O JOIN MENU M
          ON O.PRODUCT_ID = M.PRODUCT_ID) A
          WHERE RNK = 1;
         
-- Q5. Which item was the most popular for each customer?
/* --------- SOLUTION --------- */
SELECT CUSTOMER_ID, GROUP_CONCAT(PRODUCT_NAME) AS "POPULAR_PRODUCTS"
FROM(
   SELECT 
       CUSTOMER_ID,
       PRODUCT_NAME,
       O.PRODUCT_ID,
       DENSE_RANK() OVER(PARTITION BY CUSTOMER_ID ORDER BY COUNT(O.PRODUCT_ID) DESC) AS RNK
       FROM ORDERS O JOIN MENU M
       ON O.PRODUCT_ID = M.PRODUCT_ID
       GROUP BY 1,2) A
       WHERE A.RNK =1
       GROUP BY 1;
       
-- Q6. Which item was purchased first by the customer after they became a member?
/* --------- SOLUTION --------- */
SELECT CUSTOMER_ID, PRODUCT_NAME
FROM(
    SELECT
        MS.CUSTOMER_ID,
        M.PRODUCT_NAME,
        O.ORDER_DATE,
        MS.JOIN_DATE,
        DENSE_RANK() OVER(PARTITION BY MS.CUSTOMER_ID ORDER BY ORDER_DATE ASC) AS RNK
		FROM MEMBERS MS 
        JOIN ORDERS O ON O.CUSTOMER_ID = MS.CUSTOMER_ID
        JOIN MENU M ON O.PRODUCT_ID = M.PRODUCT_ID
        WHERE O.ORDER_DATE >= MS.JOIN_DATE) A
	WHERE A.RNK=1
    GROUP BY 1;
        
-- Q7. Which item was purchased just before the customer became a member?
/* --------- SOLUTION --------- */
SELECT * FROM ORDERS;
SELECT * FROM MENU;
SELECT * FROM MEMBERS;
SELECT CUSTOMER_ID, GROUP_CONCAT(PRODUCT_NAME) AS "ITEM_PURCHASED"
FROM(
    SELECT
       O.CUSTOMER_ID,
       M.PRODUCT_ID,
       PRODUCT_NAME,
       DENSE_RANK() OVER(PARTITION BY MS.CUSTOMER_ID ORDER BY ORDER_DATE) AS RNK
       FROM ORDERS O
       JOIN MENU M ON O.PRODUCT_ID = M.PRODUCT_ID
       JOIN MEMBERS MS ON O.CUSTOMER_ID = MS.CUSTOMER_ID
       WHERE O.ORDER_DATE >= MS.JOIN_DATE) A
       WHERE A.RNK =1
       GROUP BY 1;
       
-- Q8. What are the total items and amount spent for each member before they became a member?
/* --------- SOLUTION --------- */
WITH CTE AS
      (SELECT O.CUSTOMER_ID,
              O.ORDER_DATE,
              MS.JOIN_DATE,
              M.PRODUCT_NAME, 
              M.PRICE
              FROM MEMBERS MS
              JOIN ORDERS O ON O.CUSTOMER_ID = MS.CUSTOMER_ID
              JOIN MENU   M ON M.PRODUCT_ID  = O.PRODUCT_ID
              WHERE ORDER_DATE < JOIN_DATE
              ORDER BY 1,2)
SELECT 
	CUSTOMER_ID, 
    GROUP_CONCAT(PRODUCT_NAME) AS PURCHASED_ITEM,
    COUNT(PRODUCT_NAME) AS TOTAL_ITEMS,
    SUM(PRICE) AS TOTAL_AMOUNT
FROM CTE
GROUP BY CUSTOMER_ID
ORDER BY CUSTOMER_ID;

/* Q9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - 
--how many points would each customer have?*/
/* --------- SOLUTION --------- */
WITH CTE AS
(SELECT *,
       (CASE WHEN PRODUCT_NAME = 'SUSHI' THEN PRICE*20
		    ELSE PRICE*10
	   END) AS TOTAL_POINTS
       FROM MENU M)
       
SELECT DISTINCT O.CUSTOMER_ID,
       SUM(C.TOTAL_POINTS) OVER(PARTITION BY O.CUSTOMER_ID) AS TOTAL_POINTS
       FROM ORDERS O
       JOIN CTE C ON C.PRODUCT_ID = O.PRODUCT_ID
       ORDER BY 1;

/* Q10. In the first week after a customer joins the program (including their join date) 
they earn 2x points on all items, not just sushi - 
how many points do customer A and B have at the end of January?*/
 /*------ SOLUTION --------- */
SELECT
        S.CUSTOMER_ID
	,SUM(CASE
                 WHEN (DATEDIFF(DAY, ME.JOIN_DATE, S.ORDER_DATE) BETWEEN 0 AND 7) OR (M.PRODUCT_ID = 1) THEN M.PRICE * 20
                 ELSE M.PRICE * 10
              END) AS POINTS
FROM MEMBERS AS ME
    INNER JOIN SALES AS S ON S.CUSTOMER_ID = ME.CUSTOMER_ID
    INNER JOIN MENU AS M ON M.PRODUCT_ID = S.PRODUCT_ID
WHERE S.ORDER_DATE >= ME.JOIN_DATE AND S.ORDER_DATE <= CAST('2021-01-31' AS DATE)
GROUP BY S.CUSTOMER_ID
  
  
  
  
  
