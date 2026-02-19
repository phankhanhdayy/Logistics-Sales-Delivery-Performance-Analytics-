
import pandas as pd

# ======================================================
# ĐỌC DỮ LIỆU
# ======================================================

products = pd.read_csv("gold.report_products.csv")
customers = pd.read_csv("gold.report_customers.csv")
sales = pd.read_csv("gold.fact_sales.csv")

# ======================================================
# CHUẨN HOÁ TÊN CỘT
# ======================================================

sales.columns = sales.columns.str.strip().str.lower()

# ======================================================
# CHUYỂN ĐỔI KIỂU NGÀY
# ======================================================

sales["order_date"] = pd.to_datetime(sales["order_date"])

# ======================================================
# KPI TỔNG QUAN
# ======================================================

total_revenue = sales["sales_amount"].sum()
total_orders = sales["order_number"].nunique()
total_customers = sales["customer_key"].nunique()

aov = total_revenue / total_orders
revenue_per_customer = total_revenue / total_customers

print("========== KPI TỔNG QUAN ==========")
print("Tổng doanh thu:", total_revenue)
print("Tổng số đơn hàng:", total_orders)
print("Tổng số khách hàng:", total_customers)
print("Giá trị trung bình mỗi đơn (AOV):", aov)
print("Doanh thu trên mỗi khách hàng:", revenue_per_customer)

# ======================================================
# TỶ LỆ KHÁCH HÀNG QUAY LẠI
# ======================================================

customer_orders = sales.groupby("customer_key")["order_number"].nunique()

repeat_customers = (customer_orders > 1).sum()
one_time_customers = (customer_orders == 1).sum()

repeat_rate = repeat_customers / total_customers * 100

print("\n========== GIỮ CHÂN KHÁCH HÀNG ==========")
print("Khách mua nhiều hơn 1 lần:", repeat_customers)
print("Khách mua 1 lần:", one_time_customers)
print("Tỷ lệ khách quay lại (%):", repeat_rate)

# ======================================================
# DOANH THU THEO THÁNG
# ======================================================

monthly_revenue = sales.resample("ME", on="order_date")["sales_amount"].sum()
mom_growth = monthly_revenue.pct_change() * 100

print("\n========== DOANH THU THEO THÁNG ==========")
print(monthly_revenue)

print("\n========== TĂNG TRƯỞNG MOM (%) ==========")
print(mom_growth)

# ======================================================
# THÁNG TỐT NHẤT & TỆ NHẤT
# ======================================================

print("\n========== HIỆU SUẤT ==========")
print("Tháng có doanh thu cao nhất:", monthly_revenue.idxmax())
print("Tháng có doanh thu thấp nhất:", monthly_revenue.idxmin())

# ======================================================
# MỨC ĐỘ TẬP TRUNG DOANH THU (TOP 10% KHÁCH HÀNG)
# ======================================================

customer_revenue = sales.groupby("customer_key")["sales_amount"].sum()

top_10pct_cutoff = int(len(customer_revenue) * 0.1)
top_customers = customer_revenue.sort_values(ascending=False).head(top_10pct_cutoff)

concentration_ratio = top_customers.sum() / total_revenue * 100

print("\n========== MỨC ĐỘ TẬP TRUNG DOANH THU ==========")
print("Doanh thu từ top 10% khách hàng (%):", concentration_ratio)

# ======================================================
# PHÂN KHÚC KHÁCH HÀNG THEO GIÁ TRỊ
# ======================================================

customer_segment = pd.qcut(
    customer_revenue,
    q=3,
    labels=["Giá trị thấp", "Giá trị trung bình", "Giá trị cao"],
    duplicates="drop"
)

segment_summary = customer_revenue.groupby(customer_segment).sum()

print("\n========== PHÂN KHÚC KHÁCH HÀNG ==========")
print(segment_summary)

print("\nHOÀN THÀNH PHÂN TÍCH KPI")
