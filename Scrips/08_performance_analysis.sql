/*
===============================================================================
Phân tích hiệu suất (Year-over-Year, Month-over-Month)
===============================================================================
Mục đích:
    - Đo lường hiệu suất của sản phẩm, khách hàng hoặc khu vực theo thời gian.
    - Phục vụ việc so sánh chuẩn (benchmark) và xác định các đối tượng hoạt động tốt.
    - Theo dõi xu hướng và tăng trưởng theo từng năm.

Các hàm SQL được sử dụng:
    - LAG(): Truy cập dữ liệu của dòng trước đó.
    - AVG() OVER(): Tính giá trị trung bình trong từng partition.
    - CASE: Xây dựng logic điều kiện để phân tích xu hướng.
===============================================================================
*/

/* Phân tích hiệu suất theo năm của sản phẩm bằng cách so sánh doanh số hiện tại
với doanh số trung bình của chính sản phẩm đó và doanh số của năm trước */
WITH yearly_product_sales AS (
    SELECT
        YEAR(f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM fact_sales f
    LEFT JOIN dim_products p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY 
        YEAR(f.order_date),
        p.product_name
)
SELECT
    order_year,
    product_name,
    current_sales,

    AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
    current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,

    CASE 
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
        ELSE 'Avg'
    END AS avg_change,

    -- Phân tích theo năm (Year-over-Year)
    LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS py_sales,
    current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,

    CASE 
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
        ELSE 'No Change'
    END AS py_change

FROM yearly_product_sales
ORDER BY product_name, order_year;
