/*
===============================================================================
Phân tích phân khúc dữ liệu (Data Segmentation Analysis)
===============================================================================
Mục đích:
    - Nhóm dữ liệu thành các danh mục có ý nghĩa để tạo insight theo mục tiêu.
    - Phục vụ phân khúc khách hàng, phân loại sản phẩm hoặc phân tích theo khu vực.

Các hàm SQL được sử dụng:
    - CASE: Xây dựng logic phân khúc tùy chỉnh.
    - GROUP BY: Nhóm dữ liệu theo từng phân khúc.
===============================================================================
*/

/* Phân khúc sản phẩm theo khoảng chi phí
và đếm số lượng sản phẩm trong mỗi phân khúc */
WITH product_segments AS (
    SELECT
        product_key,
        product_name,
        cost,
        CASE 
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost BETWEEN 100 AND 500 THEN '100-500'
            WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
            ELSE 'Above 1000'
        END AS cost_range
    FROM dim_products
)
SELECT 
    cost_range,
    COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;

/* Nhóm khách hàng thành ba phân khúc dựa trên hành vi chi tiêu:
    - VIP: Khách hàng có lịch sử mua hàng ít nhất 12 tháng và chi tiêu hơn €5,000.
    - Regular: Khách hàng có lịch sử mua hàng ít nhất 12 tháng nhưng chi tiêu ≤ €5,000.
    - New: Khách hàng có thời gian mua hàng dưới 12 tháng.
Và tính tổng số khách hàng trong mỗi nhóm
*/
WITH customer_spending AS (
    SELECT
        c.customer_key,
        SUM(f.sales_amount) AS total_spending,
        MIN(order_date) AS first_order,
        MAX(order_date) AS last_order,
        DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
    FROM fact_sales f
    LEFT JOIN dim_customers c
        ON f.customer_key = c.customer_key
    GROUP BY c.customer_key
)
SELECT 
    customer_segment,
    COUNT(customer_key) AS total_customers
FROM (
    SELECT 
        customer_key,
        CASE 
            WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM customer_spending
) AS segmented_customers
GROUP BY customer_segment
ORDER BY total_customers DESC;
