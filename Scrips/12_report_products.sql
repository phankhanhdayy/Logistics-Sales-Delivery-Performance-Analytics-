/*
===============================================================================
Báo cáo sản phẩm (Product Report)
===============================================================================
Mục đích:
    - Báo cáo này tổng hợp các chỉ số và hành vi quan trọng của sản phẩm.

Điểm nổi bật:
    1. Thu thập các trường thông tin thiết yếu như tên sản phẩm, danh mục, danh mục con và chi phí.
    2. Phân khúc sản phẩm theo doanh thu để xác định High-Performer, Mid-Range hoặc Low-Performer.
    3. Tổng hợp các chỉ số ở cấp độ sản phẩm:
       - tổng số đơn hàng
       - tổng doanh thu
       - tổng số lượng đã bán
       - tổng số khách hàng (không trùng lặp)
       - vòng đời sản phẩm (tháng)
    4. Tính toán các KPI quan trọng:
       - recency (số tháng kể từ lần bán gần nhất)
       - doanh thu trung bình mỗi đơn hàng (AOR)
       - doanh thu trung bình theo tháng
===============================================================================
*/

-- =============================================================================
-- Tạo Report: report_products
-- =============================================================================
IF OBJECT_ID('report_products', 'V') IS NOT NULL
    DROP VIEW report_products;
GO

CREATE VIEW report_products AS

WITH base_query AS (
/*---------------------------------------------------------------------------
1) Truy vấn nền: Lấy các cột dữ liệu chính từ fact_sales và dim_products
---------------------------------------------------------------------------*/
    SELECT
        f.order_number,
        f.order_date,
        f.customer_key,
        f.sales_amount,
        f.quantity,
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost
    FROM fact_sales f
    LEFT JOIN dim_products p
        ON f.product_key = p.product_key
    WHERE order_date IS NOT NULL
),

product_aggregations AS (
/*---------------------------------------------------------------------------
2) Tổng hợp theo sản phẩm: Tính toán các chỉ số chính ở cấp độ sản phẩm
---------------------------------------------------------------------------*/
SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
    MAX(order_date) AS last_sale_date,
    COUNT(DISTINCT order_number) AS total_orders,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)), 1) AS avg_selling_price
FROM base_query
GROUP BY
    product_key,
    product_name,
    category,
    subcategory,
    cost
)

/*---------------------------------------------------------------------------
3) Truy vấn cuối: Kết hợp toàn bộ kết quả sản phẩm
---------------------------------------------------------------------------*/
SELECT 
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    last_sale_date,
    DATEDIFF(MONTH,
