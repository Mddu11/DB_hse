SELECT
    u.user_id,
    u.full_name,
    o.order_id,
    o.order_date,
    o.status AS order_status,
    p.payment_status,
    p.amount AS payment_amount
FROM users u
INNER JOIN orders o 
    ON o.user_id = u.user_id
LEFT JOIN payments p 
    ON p.order_id = o.order_id
ORDER BY o.order_date;
