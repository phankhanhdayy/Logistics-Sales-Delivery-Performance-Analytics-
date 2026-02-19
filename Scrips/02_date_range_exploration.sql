/*
===============================================================================
Khám phá khoảng thời gian dữ liệu
===============================================================================
Mục đích:
    - Xác định các mốc thời gian của những dữ liệu quan trọng.
    - Hiểu được phạm vi dữ liệu lịch sử.

Các hàm SQL được sử dụng:
    - MIN(), MAX(), DATEDIFF()
===============================================================================
*/

-- Xác định ngày đặt hàng đầu tiên, ngày đặt hàng cuối cùng và tổng khoảng thời gian theo tháng
SELECT 
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS order_range_months
FROM fact_sales;

-- Tìm khách hàng lớn tuổi nhất và nhỏ tuổi nhất dựa trên ngày sinh
SELECT
    MIN(birthdate) AS oldest_birthdate,
    DATEDIFF(YEAR, MIN(birthdate), GETDATE()) AS oldest_age,
    MAX(birthdate) AS youngest_birthdate,
    DATEDIFF(YEAR, MAX(birthdate), GETDATE()) AS youngest_age
FROM dim_customers;
