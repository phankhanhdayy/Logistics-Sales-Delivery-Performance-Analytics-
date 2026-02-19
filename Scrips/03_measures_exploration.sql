/*
===============================================================================
Khám phá các chỉ số đo lường (Key Metrics)
===============================================================================
Mục đích:
    - Tính toán các chỉ số tổng hợp (ví dụ: tổng, trung bình) để có insight nhanh.
    - Xác định xu hướng tổng thể hoặc phát hiện các điểm bất thường.

Các hàm SQL được sử dụng:
    - COUNT(), SUM(), AVG()
===============================================================================
*/

-- Tìm tổng doanh thu
SELECT SUM(sales_amount) AS total_sales FROM fact_sales

-- Tìm tổng số lượng sản phẩm đã bán
SELECT SUM(quantity) AS total_quantity FROM fact_sales

-- Tìm giá bán trung bình
SELECT AVG(price) AS avg_price FROM fact_sales

-- Tìm tổng số đơn hàng
SELECT COUNT(order_number) AS total_orders FROM fact_sales
SELECT COUNT(DISTINCT order_number) AS total_orders FROM fact_sales

-- Tìm tổng số sản phẩm
SELECT COUNT(product_name) AS total_products FROM dim_products

-- Tìm tổng số khách hàng
SELECT COUNT(customer_key) AS total_customers FROM dim_customers;

-- Tìm số khách hàng đã từng đặt hàng
SELECT COUNT(DISTINCT customer_key) AS total_customers FROM fact_sales;

-- Tạo báo cáo hiển thị toàn bộ các chỉ số kinh doanh quan trọng
SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM fact_sales
UNION ALL
SELECT 'Total Quantity', SUM(quantity) FROM fact_sales
UNION ALL
SELECT 'Average Price', AVG(price) FROM fact_sales
UNION ALL
SELECT 'Total Orders', COUNT(DISTINCT order_number) FROM fact_sales
UNION ALL
SELECT 'Total Products', COUNT(DISTINCT product_name) FROM dim_products
UNION ALL
SELECT 'Total Customers', COUNT(customer_key) FROM dim_customers;
