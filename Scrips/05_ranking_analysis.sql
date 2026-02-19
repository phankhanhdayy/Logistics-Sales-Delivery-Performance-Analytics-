/*
===============================================================================
Phân tích xếp hạng (Ranking Analysis)
===============================================================================
Mục đích:
    - Xếp hạng các đối tượng (ví dụ: sản phẩm, khách hàng) dựa trên hiệu suất hoặc các chỉ số khác.
    - Xác định các đối tượng hoạt động tốt nhất hoặc kém nhất.

Các hàm SQL được sử dụng:
    - Hàm xếp hạng dạng cửa sổ: RANK(), DENSE_RANK(), ROW_NUMBER(), TOP
    - Mệnh đề: GROUP BY, ORDER BY
===============================================================================
*/

-- 5 sản phẩm tạo ra doanh thu cao nhất
-- Xếp hạng đơn giản
SELECT TOP 5
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM fact_sales f
LEFT JOIN dim_products p
    ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC;

-- Xếp hạng nâng cao và linh hoạt bằng Window Function
SELECT *
FROM (
    SELECT
        p.product_name,
        SUM(f.sales_amount) AS total_revenue,
        RANK() OVER (ORDER BY SUM(f.sales_amount) DESC) AS rank_products
    FROM fact_sales f
    LEFT JOIN dim_products p
        ON p.product_key = f.product_key
    GROUP BY p.product_name
) AS ranked_products
WHERE rank_products <= 5;

-- 5 sản phẩm có doanh thu thấp nhất
SELECT TOP 5
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM fact_sales f
LEFT JOIN dim_products p
    ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue;

-- Top 10 khách hàng tạo ra doanh thu cao nhất
SELECT TOP 10
    c.customer_key,
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) AS total_revenue
FROM fact_sales f
LEFT JOIN dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_revenue DESC;

-- 3 khách hàng có số lượng đơn hàng ít nhất
SELECT TOP 3
    c.customer_key,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT order_number) AS total_orders
FROM fact_sales f
LEFT JOIN
