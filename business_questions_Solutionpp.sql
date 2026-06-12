
USE magist;

/*****
In relation to the products:
techproducts:
'computers_accessories','telephony','electronics','consoles_games', 'audio', 
'fixed_telephony','computers', 'tablets_printing_image', 'pc_gamer'
*****/

-- How many products of these tech categories have been sold (within the time window of the database snapshot)? 

SELECT product_category_name_english,
    COUNT(DISTINCT oi.product_id) AS tech_products_sold
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
JOIN product_category_name_translation pc USING (product_category_name)
WHERE product_category_name_english 
IN ('computers_accessories','telephony','electronics','consoles_games', 'audio', 
'fixed_telephony','computers', 'tablets_printing_image', 'pc_gamer')
GROUP BY product_category_name_english 
ORDER BY tech_products_sold DESC;



-- What percentage does that represent from the overall number of products sold?15.27%

WITH techproduct AS
(
SELECT COUNT(oi.product_id) AS tech_sold
FROM order_items oi
JOIN products p USING(product_id)
JOIN product_category_name_translation pc USING (product_category_name)
WHERE pc.product_category_name_english 
IN('computers', 'computers_accessories', 'consoles_games', 'electronics', 'pc_gamer', 'tablets_printing_image', 'audio', 'telephony', 'fixed_telephony')
),
totalproduct AS
(
SELECT COUNT(oi.product_id) AS total_sold
FROM order_items oi
JOIN products p USING(product_id)
JOIN product_category_name_translation pc USING (product_category_name)
)
SELECT tech_sold,total_sold, ROUND((tech_sold/total_sold)*100,2) AS tech_percentage_sold 
FROM techproduct,totalproduct;


-- What’s the average price of the products being sold?120.65Tech:110.22

SELECT ROUND(AVG(price),2) FROM order_items;

SELECT ROUND(AVG(oi.price), 2) AS avg_tech_price
FROM order_items oi
JOIN products p USING(product_id)
JOIN product_category_name_translation pc USING(product_category_name)
WHERE pc.product_category_name_english 
IN ('computers','computers_accessories','consoles_games','electronics',
'pc_gamer','tablets_printing_image','audio','telephony','fixed_telephony');

-- Are expensive tech products popular? *
-- * TIP: Look at the function CASE WHEN to accomplish this task.
SELECT 
    CASE 
        WHEN oi.price < 50 THEN 'Cheap'
        WHEN oi.price < 100 THEN 'Moderate'
        WHEN oi.price < 500 THEN 'Expensive'
        ELSE 'Very Expensive'
    END AS price_range,
    COUNT(oi.product_id) AS tech_products_sold
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
JOIN product_category_name_translation pc USING (product_category_name)
WHERE product_category_name_english 
IN ('computers_accessories','telephony','electronics','consoles_games', 'audio', 
'fixed_telephony','computers', 'tablets_printing_image', 'pc_gamer')
GROUP BY price_range
ORDER BY tech_products_sold DESC;

/*****
In relation to the sellers:
*****/

-- How many months of data are included in the magist database?
-- sep-2016 to Oct 2018, 25 months data

SELECT DATE_FORMAT(MIN(order_purchase_timestamp),'%M-%Y')AS firstorder, DATE_FORMAT(MAX(order_purchase_timestamp),'%M-%Y') AS lastorder,
TIMESTAMPDIFF(MONTH,MIN(order_purchase_timestamp),MAX(order_purchase_timestamp)) AS duration FROM orders;

-- How many sellers are there? 
-- 15.7% of the overall are Tech sellers

SELECT COUNT(seller_id) FROM sellers;

SELECT COUNT(DISTINCT s.seller_id) num_techsellers
FROM sellers s
JOIN order_items oi USING(seller_id)
JOIN products p USING(product_id)
JOIN product_category_name_translation pc USING(product_category_name)
WHERE pc.product_category_name_english 
IN('computers', 'computers_accessories', 'consoles_games', 'electronics', 'pc_gamer', 'tablets_printing_image', 'audio', 'telephony', 'fixed_telephony')
;

--  What percentage of overall sellers are Tech sellers?15.7%
WITH total_techsellers AS(
SELECT COUNT(DISTINCT s.seller_id) num_techsellers
FROM sellers s
JOIN order_items oi USING(seller_id)
JOIN products p USING(product_id)
JOIN product_category_name_translation pc USING(product_category_name)
WHERE pc.product_category_name_english 
IN('computers', 'computers_accessories', 'consoles_games', 'electronics', 'pc_gamer', 'tablets_printing_image', 'audio', 'telephony', 'fixed_telephony')
)
SELECT ROUND(num_techsellers/(SELECT COUNT(seller_id) FROM sellers)*100,2) AS percentage_techsellers
FROM total_techsellers; 


/*****
In relation to the delivery time:
*****/

-- What’s the average time between the order being placed and the product being delivered?
-- 13 days on an avg(tech) 

SELECT AVG(TIMESTAMPDIFF(DAY, order_purchase_timestamp,order_delivered_customer_date)) AS avg_deliverytime
FROM orders o
JOIN order_items oi USING(order_id)
JOIN products p USING(product_id)
JOIN product_category_name_translation pc USING (product_category_name)
WHERE pc.product_category_name_english 
IN('computers', 'computers_accessories', 'consoles_games', 'electronics', 'pc_gamer', 'tablets_printing_image', 'audio', 'telephony', 'fixed_telephony')
;

-- How many orders are delivered on time vs orders delivered with a delay?
SELECT order_status, COUNT(order_status) AS numorders
FROM orders
GROUP BY  order_status;

-- How many orders are delivered on time vs orders delivered with a delay?(techproducts)
-- On time: 15408 → 91%
-- Delayed: 1390 → 8%
-- NULL: 401 → orders not yet delivered or missing data

SELECT 
CASE
WHEN order_delivered_customer_date<=order_estimated_delivery_date THEN 'on_time_delivery'
WHEN order_delivered_customer_date>order_estimated_delivery_date THEN 'delayed'
END AS deliverystatus,
COUNT(*) AS num_orders
FROM orders o
JOIN order_items oi USING(order_id)
JOIN products p USING(product_id)
JOIN product_category_name_translation pc USING (product_category_name)
WHERE pc.product_category_name_english 
IN('computers', 'computers_accessories', 'consoles_games', 'electronics', 'pc_gamer', 'tablets_printing_image', 'audio', 'telephony', 'fixed_telephony')
GROUP BY deliverystatus;

