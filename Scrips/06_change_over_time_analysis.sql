/*
===============================================================================
Phân tích biến động theo thời gian (Change Over Time Analysis)
===============================================================================
Mục đích:
    - Theo dõi xu hướng, tăng trưởng và sự thay đổi của các chỉ số quan trọng theo thời gian.
    - Phục vụ phân tích chuỗi thời gian và xác định tính mùa vụ.
    - Đo lường mức tăng trưởng hoặc suy giảm trong các giai đoạn cụ thể.

Các hàm SQL được sử dụng:
    - Hàm xử lý ngày: DATEPART(), DATETRUNC(), FORMAT()
    - Hàm tổng hợp: SUM(), COUNT(), AVG()
===============================================================================
*/

-- Phân tích hiệu suất bán hàng theo thời gian
-- Các hàm xử lý ngày cơ bản
SELECT
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);

-- Sử dụng DATETRUNC()
SELECT
    DATETRUNC(month, order_date) AS order_date,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
ORDER BY DATETRUNC(month, order_date);

-- Sử dụng FORMAT()
SELECT
    FORMAT(order_date, 'yyyy-MMM') AS order_date,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM fact_sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT(order_date, 'yyyy-MMM')
ORDER BY FORMAT(order_date, 'yyyy-MMM');
