 USE coffeeshop_db;

-- =========================================================
-- SUBQUERIES & NESTED LOGIC PRACTICE
-- =========================================================

-- Q1) Scalar subquery (AVG benchmark):
--     List products priced above the overall average product price.
--     Return product_id, name, price.

SELECT product_id, name, price
FROM products
WHERE price > (
	SELECT AVG(price)
    FROM products
);

-- Q2) Scalar subquery (MAX within category):
--     Find the most expensive product(s) in the 'Beans' category.
--     (Return all ties if more than one product shares the max price.)
--     Return product_id, name, price.

SELECT product_id, name, price
FROM products
WHERE price = (
	SELECT MAX(p.price)
    FROM products p
    LEFT JOIN categories c ON p.category_id = c.category_id WHERE c.name = 'Beans'
);


-- Q3) List subquery (IN with nested lookup):
--     List customers who have purchased at least one product in the 'Merch' category.
--     Return customer_id, first_name, last_name.
--     Hint: Use a subquery to find the category_id for 'Merch', then a subquery to find product_ids.

SELECT DISTINCT c.customer_id, c.first_name, c.last_name
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE oi.product_id IN (
				SELECT category_id
                FROM products
                WHERE category_id = (
					SELECT category_id 
                    FROM categories
                    WHERE name = 'Merch'
                    )
				);

-- Q4) List subquery (NOT IN / anti-join logic):
--     List products that have never been ordered (their product_id never appears in order_items).
--     Return product_id, name, price.

SELECT p.product_id, p.name, p.price
FROM products p
WHERE p.product_id NOT IN(
	SELECT oi.product_id
    FROM order_items oi);

 
-- Q5) Table subquery (derived table + compare to overall average):
--     Build a derived table that computes total_units_sold per product
--     (SUM(order_items.quantity) grouped by product_id).
--     Then return only products whose total_units_sold is greater than the
--     average total_units_sold across all products.
--     Return product_id, product_name, total_units_sold.

SELECT t.product_id,
       t.name AS product_name,
       a.total_items_sold
	FROM (
    SELECT product_id, name
    FROM products
    GROUP BY product_id
) t
JOIN (
    SELECT SUM(quantity) AS total_items_sold, product_id
    FROM order_items
    GROUP BY product_id
) a
ON t.product_id = a.product_id
HAVING SUM(a.total_items_sold) > (
	SELECT AVG(avg_quantity)
    FROM(
		SELECT SUM(quantity) AS avg_quantity
        FROM order_items)z);
