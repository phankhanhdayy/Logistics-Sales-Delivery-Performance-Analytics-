/*
===============================================================================
Báo cáo khách hàng (Customer Report)
===============================================================================
Mục đích:
    - Báo cáo này tổng hợp các chỉ số và hành vi quan trọng của khách hàng.

Điểm nổi bật:
    1. Thu thập các trường thông tin thiết yếu như tên, tuổi và chi tiết giao dịch.
    2. Phân khúc khách hàng theo nhóm (VIP, Regular, New) và nhóm độ tuổi.
    3. Tổng hợp các chỉ số ở cấp độ khách hàng:
       - tổng số đơn hàng
       - tổng doanh thu
       - tổng số lượng sản phẩm đã mua
       - tổng số sản phẩm
       - vòng đời khách hàng (tháng)
    4. Tính toán các KPI quan trọng:
       - recency (số tháng kể từ đơn hàng gần nhất)
       - giá trị đơn hàng trung bình
       - mức chi tiêu trung bình theo tháng
===============================================================================
*/

-- =============================================================================
-- Tạo Report: report_customers
-- =============================================================================
IF OBJECT_ID('report_customers', 'V') IS NOT NULL
    DROP VIEW report_customers;
GO

CREATE VIEW report_customers AS

WITH base_query AS(
/*---------------------------------------------------------------------------
1) Truy vấn nền: Lấy các cột dữ liệu chính từ các bảng
---------------------------------------------------------------------------*/
SELECT
    f.order_number,
    f.product_key,
    f.order_date,
    f.sales_amount,
    f.quantity,
    c.customer_key,
    c.customer_number,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    DATEDIFF(year, c.birthdate, GETDATE()) AS age
FROM fact_sales f
LEFT JOIN dim_customers c
    ON c.customer_key = f.customer_key
WHERE order_date IS NOT NULL
),

customer_aggregation AS (
/*---------------------------------------------------------------------------
2) Tổng hợp theo khách hàng: Tính toán các chỉ số chính ở cấp độ khách hàng
---------------------------------------------------------------------------*/
SELECT 
    customer_key,
    customer_number,
    customer_name,
    age,
    COUNT(DISTINCT order_number) AS total_orders,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT product_key) AS total_products,
    MAX(order_date) AS last_order_date,
    DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_query
GROUP BY 
    customer_key,
    customer_number,
    customer_name,
    age
)

SELECT
    customer_key,
    customer_number,
    customer_name,
    age,

    CASE 
         WHEN age < 20 THEN 'Under 20'
         WHEN age BETWEEN 20 AND 29 THEN '20-29'
         WHEN age BETWEEN 30 AND 39 THEN '30-39'
         WHEN age BETWEEN 40 AND 49 THEN '40-49'
         ELSE '50 and above'
    END AS age_group,

    CASE 
        WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment,

    last_order_date,
    DATEDIFF(month, last_order_date, GETDATE()) AS recency,
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    lifespan,

    -- Tính giá trị đơn hàng trung bình (AOV)
    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_value,

    -- Tính mức chi tiêu trung bình theo tháng
    CASE 
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_spend

FROM customer_aggregation;
