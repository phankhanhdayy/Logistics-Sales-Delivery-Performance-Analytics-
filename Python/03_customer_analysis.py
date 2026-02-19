
import pandas as pd

# ======================================================
# ĐỌC DỮ LIỆU
# ======================================================

customers = pd.read_csv("gold.report_customers.csv")
sales = pd.read_csv("gold.fact_sales.csv")

sales.columns = sales.columns.str.strip().str.lower()
sales["order_date"] = pd.to_datetime(sales["order_date"])

# ======================================================
# GHÉP DỮ LIỆU
# ======================================================

df = sales.merge(customers, on="customer_key", how="left")

# ======================================================
# KPI THEO KHÁCH HÀNG
# ======================================================

customer_kpi = df.groupby("customer_key").agg(
    tong_doanh_thu=("sales_amount", "sum"),
    tong_so_don=("order_number", "nunique"),
    tong_so_luong=("quantity", "sum"),
    don_dau_tien=("order_date", "min"),
    don_gan_nhat=("order_date", "max")
)

print("========== KPI KHÁCH HÀNG ==========")
print(customer_kpi.head())

# ======================================================
# TOP 10 KHÁCH HÀNG GIÁ TRỊ NHẤT
# ======================================================

top_customers = customer_kpi.sort_values(
    "tong_doanh_thu", ascending=False
).head(10)

print("\n========== TOP 10 KHÁCH HÀNG ==========")
print(top_customers)

# ======================================================
# KHÁCH HÀNG MỚI vs KHÁCH HÀNG QUAY LẠI
# ======================================================

customer_kpi["loai_khach_hang"] = customer_kpi["tong_so_don"].apply(
    lambda x: "Khách quay lại" if x > 1 else "Khách mua 1 lần"
)

print("\n========== PHÂN LOẠI KHÁCH HÀNG ==========")
print(customer_kpi["loai_khach_hang"].value_counts())

# ======================================================
# GIÁ TRỊ VÒNG ĐỜI KHÁCH HÀNG (CLV CƠ BẢN)
# ======================================================

customer_kpi["thoi_gian_mua_hang"] = (
    customer_kpi["don_gan_nhat"] - customer_kpi["don_dau_tien"]
).dt.days

customer_kpi["thoi_gian_mua_hang"] = customer_kpi["thoi_gian_mua_hang"].replace(0, 1)

customer_kpi["clv"] = (
    customer_kpi["tong_doanh_thu"] / customer_kpi["thoi_gian_mua_hang"]
)

print("\n========== CLV (GIÁ TRỊ VÒNG ĐỜI KHÁCH HÀNG) ==========")
print(customer_kpi["clv"].sort_values(ascending=False).head(10))

# ======================================================
# PHÂN TÍCH RFM
# ======================================================

snapshot_date = df["order_date"].max()

rfm = df.groupby("customer_key").agg({
    "order_date": lambda x: (snapshot_date - x.max()).days,
    "order_number": "nunique",
    "sales_amount": "sum"
})

rfm.columns = ["recency", "frequency", "monetary"]

rfm["r_score"] = pd.qcut(rfm["recency"], 4, labels=[4,3,2,1])
rfm["f_score"] = pd.qcut(rfm["frequency"].rank(method="first"), 4, labels=[1,2,3,4])
rfm["m_score"] = pd.qcut(rfm["monetary"], 4, labels=[1,2,3,4])

rfm["phan_khuc_rfm"] = (
    rfm["r_score"].astype(str)
    + rfm["f_score"].astype(str)
    + rfm["m_score"].astype(str)
)

print("\n========== PHÂN KHÚC KHÁCH HÀNG THEO RFM ==========")
print(rfm.head())

print("\nHOÀN THÀNH PHÂN TÍCH KHÁCH HÀNG")
