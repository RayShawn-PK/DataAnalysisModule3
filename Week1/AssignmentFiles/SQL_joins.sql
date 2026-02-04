USE coffeeshop_db;

-- =========================================================
-- JOINS & RELATIONSHIPS PRACTICE
-- =========================================================

-- Q1) Join products to categories: list product_name, category_name, price.
SELECT p.name AS product_name, c.name AS category_name, p.price
FROM products p
INNER JOIN categories c
ON p.category_id = c.category_id;

-- Q2) For each order item, show: order_id, order_datetime, store_name,
--     product_name, quantity, line_total (= quantity * products.price).
--     Sort by order_datetime, then order_id.
SELECT oi.order_id, o.order_datetime, s.name AS store_name, p.name AS product_name, oi.quantity, oi.quantity*p.price AS line_price
FROM orders o
INNER JOIN order_items oi
ON o.order_id = oi.order_id
INNER JOIN products p 
ON oi.product_id = p.product_id
INNER JOIN stores s
ON o.store_id = s.store_id
ORDER BY o.order_datetime, oi.order_id;

-- Q3) Customer order history (PAID only):
--     For each order, show customer_name, store_name, order_datetime,
--     order_total (= SUM(quantity * products.price) per order).
SELECT o.order_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name, s.name AS store_name, o.order_datetime, SUM(oi.quantity*p.price) AS order_total
FROM orders o
INNER JOIN order_items oi
ON o.order_id = oi.order_id
INNER JOIN products p 
ON oi.product_id = p.product_id
INNER JOIN stores s
ON o.store_id = s.store_id
INNER JOIN customers c
ON o.customer_id = c.customer_id
WHERE o.status = 'paid'
GROUP BY o.order_id
;

-- Q4) Left join to find customers who have never placed an order.
--     Return first_name, last_name, city, state.
SELECT c.first_name, c.last_name, c.city, c.state
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id
WHERE o.order_id < '1'
;

-- Q5) For each store, list the top-selling product by units (PAID only).
--     Return store_name, product_name, total_units.
--     Hint: Use a window function (ROW_NUMBER PARTITION BY store) or a correlated subquery.
WITH TopSelling AS(
SELECT
	oi.product_id,
    oi.quantity,
	ROW_NUMBER() OVER(
	PARTITION BY oi.product_id
    ORDER BY oi.quantity DESC) AS rn
    FROM order_items oi)
SELECT s.name AS store_name, p.name AS product_name, COUNT(oi.quantity) AS total_units
FROM stores s
INNER JOIN orders o
ON s.store_id = o.store_id
INNER JOIN order_items oi
ON o.order_id = oi.order_id
INNER JOIN products p
ON oi.product_id = p.product_id 
INNER JOIN TopSelling ts
ON oi.product_id = ts.product_id
AND ts.rn = 1
GROUP BY store_name
;
    
-- Q6) Inventory check: show rows where on_hand < 12 in any store.
--     Return store_name, product_name, on_hand.
SELECT s.name AS store_name, p.name AS product_name, i.on_hand
FROM stores s
INNER JOIN inventory i
ON s.store_id = i.store_id
INNER JOIN products p
ON i.product_id = p.product_id
HAVING on_hand < '12';



-- Q7) Manager roster: list each store's manager_name and hire_date.
--     (Assume title = 'Manager').
SELECT s.name AS store_name, CONCAT(e.first_name,' ',e.last_name) AS manager_name, e.hire_date
FROM stores s
INNER JOIN employees e
ON s.store_id = e.store_id
WHERE e.title = 'Manager';

-- Q8) Using a subquery/CTE: list products whose total PAID revenue is above
--     the average PAID product revenue. Return product_name, total_revenue.

-- Q9) Churn-ish check: list customers with their last PAID order date.
--     If they have no PAID orders, show NULL.
--     Hint: Put the status filter in the LEFT JOIN's ON clause to preserve non-buyer rows.

-- Q10) Product mix report (PAID only):
--     For each store and category, show total units and total revenue (= SUM(quantity * products.price)).
