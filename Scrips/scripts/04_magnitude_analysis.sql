/*
===============================================================================
Phân tích độ lớn dữ liệu (Magnitude Analysis)
===============================================================================
Mục đích:
    - Định lượng dữ liệu và nhóm kết quả theo các dimension cụ thể.
    - Hiểu được sự phân bố dữ liệu giữa các danh mục.

Các hàm SQL được sử dụng:
    - Hàm tổng hợp: SUM(), COUNT(), AVG()
    - GROUP BY, ORDER BY
===============================================================================
*/

-- Tìm tổng số khách hàng theo từng quốc gia
SELECT
    country,
    COUNT(customer_key) AS total_customers
FROM dim_customers
GROUP BY country
ORDER BY total_customers DESC;

-- Tìm tổng số khách hàng theo giới tính
SELECT
    gender,
    COUNT(customer_key) AS total_customers
FROM dim_customers
GROUP BY gender
ORDER BY total_customers DESC;

-- Tìm tổng số sản phẩm theo từng danh mục
SELECT
    category,
    COUNT(product_key) AS total_products
FROM dim_products
GROUP BY category
ORDER BY total_products DESC;

-- Chi phí trung bình của mỗi danh mục là bao nhiêu?
SELECT
    category,
    AVG(cost) AS avg_cost
FROM dim_products
GROUP BY category
ORDER BY avg_cost DESC;

-- Tổng doanh thu tạo ra từ mỗi danh mục là bao nhiêu?
SELECT
    p.category,
    SUM(f.sales_amount) AS total_revenue
FROM fact_sales f
LEFT JOIN dim_products p
    ON p.product_key = f.product_key
GROUP BY p.category
ORDER BY total_revenue DESC;

-- Tổng doanh thu tạo ra bởi từng khách hàng
SELECT
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

-- Phân bố số lượng sản phẩm đã bán theo quốc gia
SELECT
    c.country,
    SUM(f.quantity) AS total_sold_items
FROM fact_sales f
LEFT JOIN dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY c.country
ORDER BY total_sold_items DESC;
