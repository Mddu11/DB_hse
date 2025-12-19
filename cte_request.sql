WITH product_revenue AS (
    SELECT
        oi.product_id,
        SUM(oi.quantity * oi.price_at_order) AS total_revenue
    FROM order_items oi
    GROUP BY oi.product_id
)
SELECT
    p.product_id,
    p.name AS product_name,
    pr.total_revenue
FROM product_revenue pr
JOIN products p ON p.product_id = pr.product_id
ORDER BY pr.total_revenue DESC
LIMIT 5;
