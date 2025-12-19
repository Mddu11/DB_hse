SELECT
    o.user_id,
    o.order_id,
    o.order_date,
    ROW_NUMBER() OVER (
        PARTITION BY o.user_id
        ORDER BY o.order_date
    ) AS order_sequence_number,
    COUNT(o.order_id) OVER (
        PARTITION BY o.user_id
    ) AS total_orders_by_user
FROM orders o
ORDER BY o.user_id, o.order_date;
