## Анализ производительности SQL-запроса
# 1. Выбранный запрос

Для анализа производительности был выбран запрос бизнес-аналитики:
«Определение топ-5 товаров по суммарной выручке».

Запрос используется для выявления наиболее прибыльных товаров и объединяет данные из таблиц order_items и products, выполняя агрегацию и сортировку по рассчитанному показателю выручки.

# 2. План выполнения до оптимизации
EXPLAIN ANALYZE
WITH product_revenue AS (
    SELECT
        oi.product_id,
        SUM(oi.quantity * oi.price_at_order) AS total_revenue
    FROM order_items oi
    GROUP BY oi.product_id
)
SELECT
    p.product_id,
    p.name,
    pr.total_revenue
FROM product_revenue pr
JOIN products p ON p.product_id = pr.product_id
ORDER BY pr.total_revenue DESC
LIMIT 5;


Ключевые проблемы в исходном плане выполнения:

Seq Scan на таблице order_items, что приводит к последовательному сканированию всей таблицы

Использование HashAggregate для группировки без поддержки индекса

Hash Join при соединении с таблицей products

Дополнительные затраты на сортировку результата по суммарной выручке

Рост стоимости выполнения при увеличении объёма данных

# 3. Предложенные оптимизации
3.1 Создание индексов

На основе анализа плана выполнения были предложены следующие индексы:

idx_order_items_product_id — для ускорения группировки и соединения по product_id

Использование первичного ключа таблицы products для ускорения JOIN операций

CREATE INDEX idx_order_items_product_id
ON order_items(product_id);

3.2 Логика выбора индексов

Индексы были выбраны на основании:

поля, используемого в агрегатной функции и GROUP BY (product_id);

поля, используемого в JOIN (product_id);

частого использования таблицы order_items в аналитических запросах;

потенциально большого объёма данных в таблице позиций заказов.

# 4. План выполнения после оптимизации
EXPLAIN ANALYZE
WITH product_revenue AS (
    SELECT
        oi.product_id,
        SUM(oi.quantity * oi.price_at_order) AS total_revenue
    FROM order_items oi
    GROUP BY oi.product_id
)
SELECT
    p.product_id,
    p.name,
    pr.total_revenue
FROM product_revenue pr
JOIN products p ON p.product_id = pr.product_id
ORDER BY pr.total_revenue DESC
LIMIT 5;

После создания индекса план выполнения изменился, и PostgreSQL стал эффективнее использовать доступные структуры данных.
## 5. Ключевые улучшения:

Использование индекса вместо Seq Scan
Последовательное сканирование таблицы order_items было заменено индексным доступом.

Снижение стоимости агрегации
Уменьшено количество обрабатываемых строк на этапе группировки.

Ускорение JOIN операций
Соединение с таблицей products стало менее затратным по стоимости выполнения.