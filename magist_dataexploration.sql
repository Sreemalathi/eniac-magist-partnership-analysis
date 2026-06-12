
-- -------------------------------------------------------------------------------------------------
-- MAGIST - Database exploration
-- -------------------------------------------------------------------------------------------------

-- 1. How many orders are there in the dataset? 
select COUNT(*) FROM orders;

-- 2. Are orders actually delivered? 
-- Look at the columns in the orders table: one of them is called order_status. 
-- Find out how many orders are delivered and how many are cancelled, unavailable, or in any other status by grouping and aggregating this column.

SELECT order_status, COUNT(order_status) FROM orders
GROUP BY order_status;

SELECT  order_status, COUNT(order_status) AS ordercount,
ROUND((COUNT(order_status)/(SELECT COUNT(*) FROM orders) *100),2) AS percent
FROM orders
GROUP BY order_status;


-- 3. Is Magist having user growth? 
-- A platform losing users left and right isn’t going to be very useful to us. 
-- It would be a good idea to check for the number of orders grouped by year and month. 
-- Tip: you can use the functions YEAR() and MONTH() to separate the year and the month of the order_purchase_timestamp.
select count(*) from orders;

SELECT YEAR(order_purchase_timestamp) AS yearpurchased,
MONTH(order_purchase_timestamp) AS monthpurchased,
COUNT(order_id) AS countcust FROM orders
GROUP BY yearpurchased,monthpurchased ORDER BY yearpurchased, monthpurchased;

-- 4. How many products are there on the products table? (Make sure that there are no duplicate products.)
SELECT * FROM products;

SELECT COUNT(DISTINCT product_id) FROM products;

-- 5. Which are the categories with the most products? 

SELECT product_category_name, COUNT(product_id) AS prodcnt FROM products
GROUP BY product_category_name ORDER BY prodcnt DESC;

-- 6. How many of those products were present in actual transactions? 
-- The products table is a “reference” of all the available products. 
-- Have all these products been involved in orders? Check out the order_items table to find out!


SELECT COUNT(DISTINCT product_id) FROM Products WHERE product_id NOT IN(
SELECT DISTINCT product_id FROM order_items);

SELECT COUNT(DISTINCT product_id) FROM order_items WHERE product_id IN(
SELECT DISTINCT product_id FROM products);


-- 7. What’s the price for the most expensive and cheapest products? 

SELECT MAX(price), MIN(price) FROM order_items;

SELECT AVG(price) FROM order_items;

-- Looking for the maximum and minimum values is also a good way to detect extreme outliers.
-- 8. What are the highest and lowest payment values?

SELECT MAX(payment_value),MIN(payment_value) FROM order_payments;