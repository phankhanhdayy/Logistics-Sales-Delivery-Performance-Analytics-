/*
===============================================================================
Khám phá các bảng Dimension
===============================================================================
Mục đích:
    - Khám phá cấu trúc của các bảng dimension.
	
Các hàm SQL được sử dụng:
    - DISTINCT
    - ORDER BY
===============================================================================
*/

-- Lấy danh sách các quốc gia duy nhất mà khách hàng đến từ
SELECT DISTINCT 
    country 
FROM dim_customers
ORDER BY country;

-- Lấy danh sách duy nhất của category, subcategory và product
SELECT DISTINCT 
    category, 
    subcategory, 
    product_name 
FROM dim_products
ORDER BY category, subcategory, product_name;
