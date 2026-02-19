/*
===============================================================================
Phân tích tỷ trọng đóng góp (Part-to-Whole Analysis)
===============================================================================
Mục đích:
    - So sánh hiệu suất hoặc các chỉ số giữa các dimension hoặc các giai đoạn thời gian.
    - Đánh giá sự khác biệt giữa các danh mục.
    - Hữu ích cho A/B testing hoặc so sánh theo khu vực.

Các hàm SQL được sử dụng:
    - SUM(), AVG(): Tổng hợp giá trị để so sánh.
    - Hàm cửa sổ: SUM() OVER() để tính tổng toàn bộ.
===============================================================================
*/

-- Danh mục nào đóng góp nhiều nhất vào tổng doanh thu?
WITH category_sales AS (
    SELECT
        p.category,
        SUM(f.sales_amount) AS total_sales
    FROM fact_sales f
    LEFT JOIN dim_products p
        ON p.product_key = f.product_key
    GROUP BY p.category
)
SELECT
    category,
    total_sales,
    SUM(total_sales) OVER () AS overall_sales,
    ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100, 2) AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC;
