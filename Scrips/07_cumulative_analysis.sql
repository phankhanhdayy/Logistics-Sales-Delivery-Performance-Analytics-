/*
===============================================================================
Phân tích luỹ kế (Cumulative Analysis)
===============================================================================
Mục đích:
    - Tính toán tổng luỹ kế hoặc trung bình trượt cho các chỉ số quan trọng.
    - Theo dõi hiệu suất theo thời gian dưới dạng tích luỹ.
    - Hữu ích cho việc phân tích tăng trưởng hoặc xác định xu hướng dài hạn.

Các hàm SQL được sử dụng:
    - Hàm cửa sổ: SUM() OVER(), AVG() OVER()
===============================================================================
*/

-- Tính tổng doanh thu theo từng năm
-- và tổng doanh thu luỹ kế theo thời gian
SELECT
    order_date,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
    AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_price
FROM
(
    SELECT 
        DATETRUNC(year, order_date) AS order_date,
        SUM(sales_amount) AS total_sales,
        AVG(price) AS avg_price
    FROM fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(year, order_date)
) t;

